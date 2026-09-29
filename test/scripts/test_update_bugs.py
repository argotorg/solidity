#!/usr/bin/env python3

"""Tests for the known-bugs list generation."""

import contextlib
import io
import json
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path

import update_bugs_by_version

YEAR = datetime.now(timezone.utc).year

BUGS_YAML = f"""- uid:
  name: NewBug
  summary: s
  description: >-
    Two
    sentences.
  link: ""
  introduced: 0.4.0
  fixed: next
  severity: low

- uid: SOL-{YEAR}-2
  name: OldBug
  summary: s
  description: d
  link: l
  introduced: 0.9.0
  fixed: 0.9.1
  severity: low
"""

CHANGELOG_MID_CYCLE = """### 0.9.2 (unreleased)

### 0.9.1 (2026-01-01)

### 0.9.0 (2025-06-01)
"""

CHANGELOG_AT_RELEASE = CHANGELOG_MID_CYCLE.replace("0.9.2 (unreleased)", "0.9.2 (2026-06-01)")

CMAKE_LISTS = 'set(PROJECT_VERSION "0.9.2")\n'


class UpdateBugsTest(unittest.TestCase):
    """Test generation of the bug lists from the YAML source."""

    @staticmethod
    def _update(temp_dir, changelog, bugs_yaml=BUGS_YAML):
        yaml_path = Path(temp_dir) / "bugs.yaml"
        json_path = Path(temp_dir) / "bugs.json"
        changelog_path = Path(temp_dir) / "Changelog.md"
        cmake_path = Path(temp_dir) / "CMakeLists.txt"
        yaml_path.write_text(bugs_yaml, encoding="utf8")
        changelog_path.write_text(changelog, encoding="utf8")
        cmake_path.write_text(CMAKE_LISTS, encoding="utf8")
        stderr = io.StringIO()
        with contextlib.redirect_stderr(stderr):
            bugs = update_bugs_by_version.update_bugs(yaml_path, json_path, changelog_path, cmake_path)
        return (
            yaml_path.read_text(encoding="utf8"),
            json.loads(json_path.read_text(encoding="utf8")),
            bugs,
            stderr.getvalue(),
        )

    def test_repo_files_are_up_to_date(self):
        """Verify that regenerating the bug lists from the committed files does not change them."""
        docs_path = Path(__file__).parent.parent.parent / "docs"

        with tempfile.TemporaryDirectory() as temp_dir:
            # Use a copy of the source so that the test can never modify it.
            yaml_copy = Path(temp_dir) / "bugs.yaml"
            yaml_copy.write_text((docs_path / "bugs.yaml").read_text(encoding="utf8"), encoding="utf8")
            json_output = Path(temp_dir) / "bugs.json"
            by_version_output = Path(temp_dir) / "bugs_by_version.json"

            with contextlib.redirect_stderr(io.StringIO()):
                bugs = update_bugs_by_version.update_bugs(yaml_copy, json_output)
                update_bugs_by_version.update_bugs_by_version(bugs, by_version_output)

            for generated, committed in [
                (yaml_copy, docs_path / "bugs.yaml"),
                (json_output, docs_path / "bugs.json"),
                (by_version_output, docs_path / "bugs_by_version.json"),
            ]:
                self.assertEqual(
                    generated.read_text(encoding="utf8"),
                    committed.read_text(encoding="utf8"),
                    f"{committed.name} is out of date. Regenerate it with scripts/update_bugs_by_version.py.",
                )

    def test_assigns_next_free_uid(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, _, _, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE)

            self.assertIn(f"- uid: SOL-{YEAR}-3", yaml_text)

    def test_assigns_sequential_uids(self):
        another_entry = BUGS_YAML.replace("NewBug", "ThirdBug").split("\n\n", maxsplit=1)[0]
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, _, _, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE, BUGS_YAML + "\n" + another_entry + "\n")

            self.assertIn(f"- uid: SOL-{YEAR}-3", yaml_text)
            self.assertIn(f"- uid: SOL-{YEAR}-4", yaml_text)

    def test_omits_unreleased_fix(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, generated, _, notes = self._update(temp_dir, CHANGELOG_MID_CYCLE)

            self.assertIn("fixed: next", yaml_text)
            self.assertEqual([bug["name"] for bug in generated], ["OldBug"])
            self.assertIn(f"not published yet: SOL-{YEAR}-3", notes)

    def test_resolves_next_at_release(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, generated, _, notes = self._update(temp_dir, CHANGELOG_AT_RELEASE)

            self.assertNotIn("fixed: next", yaml_text)
            self.assertIn("fixed: 0.9.2", yaml_text)
            self.assertEqual([bug["name"] for bug in generated], ["NewBug", "OldBug"])
            self.assertEqual(generated[0]["fixed"], "0.9.2")
            self.assertEqual(notes, "")

    def test_tolerates_whitespace_in_edited_lines(self):
        yaml_variant = BUGS_YAML.replace("- uid:\n", "- uid:  \n").replace("  fixed: next\n", "  fixed:   next  \n")
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, generated, _, _ = self._update(temp_dir, CHANGELOG_AT_RELEASE, yaml_variant)

            self.assertIn(f"- uid: SOL-{YEAR}-3", yaml_text)
            self.assertIn("fixed: 0.9.2", yaml_text)
            self.assertEqual(generated[0]["fixed"], "0.9.2")

    def test_missing_fixed_is_an_error(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            with self.assertRaises(SystemExit):
                self._update(temp_dir, CHANGELOG_MID_CYCLE, BUGS_YAML.replace("  fixed: next\n", ""))

    def test_preserves_yaml_formatting(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, _, _, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE)

            self.assertEqual(yaml_text, BUGS_YAML.replace("- uid:\n", f"- uid: SOL-{YEAR}-3\n"))

    def test_bugs_by_version(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            _, _, bugs, _ = self._update(temp_dir, CHANGELOG_AT_RELEASE)
            output_path = Path(temp_dir) / "bugs_by_version.json"
            changelog_path = Path(temp_dir) / "Changelog.md"

            update_bugs_by_version.update_bugs_by_version(bugs, output_path, changelog_path)

            versions = json.loads(output_path.read_text(encoding="utf8"))
            self.assertEqual(sorted(versions["0.9.0"]["bugs"]), ["NewBug", "OldBug"])
            self.assertEqual(sorted(versions["0.9.1"]["bugs"]), ["NewBug"])
            self.assertEqual(versions["0.9.2"]["bugs"], [])


if __name__ == "__main__":
    unittest.main()
