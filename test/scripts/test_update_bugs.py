#!/usr/bin/env python3

"""Tests for the known-bugs list generation."""

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
        bugs = update_bugs_by_version.update_bugs(yaml_path, json_path, changelog_path, cmake_path)
        return yaml_path.read_text(encoding="utf8"), json.loads(json_path.read_text(encoding="utf8")), bugs

    def test_generates_equivalent_json(self):
        """Verify that generated JSON preserves the existing bug data."""
        bugs_yaml = Path(__file__).parent.parent.parent / "docs" / "bugs.yaml"
        expected_json = Path(__file__).parent.parent.parent / "docs" / "bugs.json"

        with tempfile.TemporaryDirectory() as temp_dir:
            # Use a copy of the source so that the test can never modify it.
            yaml_copy = Path(temp_dir) / "bugs.yaml"
            yaml_copy.write_text(bugs_yaml.read_text(encoding="utf8"), encoding="utf8")
            output_json = Path(temp_dir) / "bugs.json"

            update_bugs_by_version.update_bugs(yaml_copy, output_json)

            generated = json.loads(output_json.read_text(encoding="utf8"))
            expected = json.loads(expected_json.read_text(encoding="utf8"))

            self.assertEqual(generated, expected)

    def test_assigns_next_free_uid(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, _, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE)

            self.assertIn(f"- uid: SOL-{YEAR}-3", yaml_text)

    def test_assigns_sequential_uids(self):
        another_entry = BUGS_YAML.replace("NewBug", "ThirdBug").split("\n\n", maxsplit=1)[0]
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, _, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE, BUGS_YAML + "\n" + another_entry + "\n")

            self.assertIn(f"- uid: SOL-{YEAR}-3", yaml_text)
            self.assertIn(f"- uid: SOL-{YEAR}-4", yaml_text)

    def test_omits_unreleased_fix(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, generated, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE)

            self.assertIn("fixed: next", yaml_text)
            self.assertEqual([bug["name"] for bug in generated], ["OldBug"])

    def test_resolves_next_at_release(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, generated, _ = self._update(temp_dir, CHANGELOG_AT_RELEASE)

            self.assertNotIn("fixed: next", yaml_text)
            self.assertIn("fixed: 0.9.2", yaml_text)
            self.assertEqual([bug["name"] for bug in generated], ["NewBug", "OldBug"])
            self.assertEqual(generated[0]["fixed"], "0.9.2")

    def test_missing_fixed_is_an_error(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            with self.assertRaises(SystemExit):
                self._update(temp_dir, CHANGELOG_MID_CYCLE, BUGS_YAML.replace("  fixed: next\n", ""))

    def test_preserves_yaml_formatting(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            yaml_text, _, _ = self._update(temp_dir, CHANGELOG_MID_CYCLE)

            self.assertEqual(yaml_text, BUGS_YAML.replace("- uid:\n", f"- uid: SOL-{YEAR}-3\n"))

    def test_bugs_by_version(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            _, _, bugs = self._update(temp_dir, CHANGELOG_AT_RELEASE)
            output_path = Path(temp_dir) / "bugs_by_version.json"
            changelog_path = Path(temp_dir) / "Changelog.md"

            update_bugs_by_version.update_bugs_by_version(bugs, output_path, changelog_path)

            versions = json.loads(output_path.read_text(encoding="utf8"))
            self.assertEqual(sorted(versions["0.9.0"]["bugs"]), ["NewBug", "OldBug"])
            self.assertEqual(sorted(versions["0.9.1"]["bugs"]), ["NewBug"])
            self.assertEqual(versions["0.9.2"]["bugs"], [])


if __name__ == "__main__":
    unittest.main()
