#!/usr/bin/env python3

"""Generate docs/bugs.json from the human-editable YAML bug list."""

import json
import sys
from collections import Counter
from pathlib import Path

import jsonschema
import yaml


ROOT_PATH = Path(__file__).resolve().parent.parent
BUGS_YAML = ROOT_PATH / "docs" / "bugs.yaml"
BUGS_JSON = ROOT_PATH / "docs" / "bugs.json"
BUGS_SCHEMA = ROOT_PATH / "docs" / "bugs.schema.json"


class BugListValidationError(Exception):
    pass


def validate_bugs(bugs, schema_path: Path = BUGS_SCHEMA):
    schema = json.loads(schema_path.read_text(encoding="utf8"))
    validator = jsonschema.Draft202012Validator(schema, format_checker=jsonschema.Draft202012Validator.FORMAT_CHECKER)

    messages = []
    for error in validator.iter_errors(bugs):
        path = list(error.absolute_path)
        if len(path) > 0 and isinstance(path[0], int) and isinstance(bugs[path[0]], dict):
            location = bugs[path[0]].get("uid", f"entry #{path[0]}")
        else:
            location = "<root>"
        field = ".".join(str(component) for component in path[1:]) or "<entry>"
        messages.append(f"{location}: {field}: {error.message}")

    if len(messages) == 0:
        # Uniqueness of a property across array items cannot be expressed in JSON schema.
        name_counts = Counter(bug["name"] for bug in bugs)
        messages += [f"Duplicate bug name: {name}" for name, count in name_counts.items() if count > 1]

    if len(messages) != 0:
        raise BugListValidationError("Invalid bug list:\n  " + "\n  ".join(messages))


def update_bugs(input_path=BUGS_YAML, output_path=BUGS_JSON, schema_path=BUGS_SCHEMA):
    """Generate the JSON bug list from the YAML source."""
    bugs = yaml.safe_load(input_path.read_text(encoding="utf8"))
    validate_bugs(bugs, schema_path)

    output_path.write_text(
        json.dumps(
            bugs,
            sort_keys=False,
            indent=4,
            separators=(",", ": "),
        ) + "\n",
        encoding="utf8",
    )


if __name__ == "__main__":
    try:
        update_bugs()
    except BugListValidationError as exception:
        print(f"{exception}", file=sys.stderr)
        sys.exit(1)
