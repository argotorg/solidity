#!/usr/bin/env python3

"""Tests for the known-bugs YAML to JSON generator."""

import json
import tempfile
import unittest
from pathlib import Path

import update_bugs_json

DOCS_DIR = Path(__file__).parent.parent.parent / "docs"

VALID_BUG_YAML = """\
- uid: SOL-2026-1
  name: SomeBug
  summary: >-
    Summary.
  description: >-
    Description.
  link: https://blog.soliditylang.org/
  introduced: 0.8.20
  fixed: 0.8.30
  publish: "2026-01-01"
  severity: low/medium
  conditions:
    viaIR: true
    evmVersion: ">=cancun"
  check:
    regex-source: "foo"
"""


class UpdateBugsTest(unittest.TestCase):
    """Test generation of the JSON bug list from YAML."""

    def test_generates_equivalent_json(self):
        """Verify that generated JSON preserves the existing bug data."""
        bugs_yaml = DOCS_DIR / "bugs.yaml"
        expected_json = DOCS_DIR / "bugs.json"

        with tempfile.TemporaryDirectory() as temp_dir:
            output_json = Path(temp_dir) / "bugs.json"

            update_bugs_json.update_bugs(bugs_yaml, output_json)

            generated = json.loads(output_json.read_text(encoding="utf8"))
            expected = json.loads(expected_json.read_text(encoding="utf8"))

            self.assertEqual(generated, expected)

    def test_bug_list_conforms_to_schema(self):
        update_bugs_json.validate_bugs(json.loads((DOCS_DIR / "bugs.json").read_text(encoding="utf8")))


class ValidateBugsTest(unittest.TestCase):
    """Test validation of the YAML bug list against the schema."""

    def assert_valid(self, bugs_yaml):
        with tempfile.TemporaryDirectory() as temp_dir:
            input_yaml = Path(temp_dir) / "bugs.yaml"
            output_json = Path(temp_dir) / "bugs.json"
            input_yaml.write_text(bugs_yaml, encoding="utf8")

            update_bugs_json.update_bugs(input_yaml, output_json)

    def assert_invalid(self, bugs_yaml, expected_message):
        with self.assertRaises(ValueError) as context:
            self.assert_valid(bugs_yaml)
        self.assertIn(expected_message, str(context.exception))

    def test_accepts_all_fields(self):
        self.assert_valid(VALID_BUG_YAML)

    def test_rejects_version_parsed_as_number(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace("fixed: 0.8.30", "fixed: 0.9"),
            "SOL-2026-1: fixed: 0.9 is not of type 'string'"
        )

    def test_rejects_unquoted_date(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace('publish: "2026-01-01"', "publish: 2026-01-01"),
            "SOL-2026-1: publish: datetime.date(2026, 1, 1) is not of type 'string'"
        )

    def test_rejects_invalid_date(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace('publish: "2026-01-01"', 'publish: "2026-13-01"'),
            "SOL-2026-1: publish: '2026-13-01' is not a 'date'"
        )

    def test_rejects_unknown_key(self):
        self.assert_invalid(
            VALID_BUG_YAML + "  fixedIn: 0.8.30\n",
            "SOL-2026-1: <entry>: Additional properties are not allowed ('fixedIn' was unexpected)"
        )

    def test_rejects_missing_key(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace("  severity: low/medium\n", ""),
            "SOL-2026-1: <entry>: 'severity' is a required property"
        )

    def test_rejects_unknown_severity(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace("severity: low/medium", "severity: critical"),
            "SOL-2026-1: severity: 'critical' is not one of"
        )

    def test_rejects_unknown_condition(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace("viaIR: true", "viaIr: true"),
            "SOL-2026-1: conditions: Additional properties are not allowed ('viaIr' was unexpected)"
        )

    def test_rejects_non_boolean_condition(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace("viaIR: true", "viaIR: yes please"),
            "SOL-2026-1: conditions.viaIR: 'yes please' is not of type 'boolean'"
        )

    def test_rejects_unknown_check(self):
        self.assert_invalid(
            VALID_BUG_YAML.replace("regex-source:", "source-regex:"),
            "SOL-2026-1: check: Additional properties are not allowed ('source-regex' was unexpected)"
        )

    def test_rejects_duplicate_name(self):
        self.assert_invalid(
            VALID_BUG_YAML + "\n" + VALID_BUG_YAML.replace("SOL-2026-1", "SOL-2026-2"),
            "Duplicate bug name: SomeBug"
        )


if __name__ == "__main__":
    unittest.main()
