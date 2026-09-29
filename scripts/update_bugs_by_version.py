#!/usr/bin/env python3

"""Regenerate the known-bugs lists from the human-editable YAML source.

docs/bugs.yaml is the only file meant to be edited by hand.
This script generates docs/bugs.json from it and docs/bugs_by_version.json
from the result and the release dates in the Changelog.
It updates the files in place.
Running with --check instead verifies that regenerating would not change any
of the files, without modifying them. CI uses this to make sure that the
generated files stay up to date.

A new entry in bugs.yaml may leave the "uid" field empty, in which case the
next free uid of the current year is assigned.
An entry whose fix is not released yet must use "next" as its "fixed"
version.
Such entries are omitted from the generated files until the release.
During the release, when the version from CMakeLists.txt receives its
release date in the Changelog, "next" is replaced with that version.
Pre-releases never resolve "next", only a dated Changelog heading for the
version from CMakeLists.txt does.
"""

import argparse
import difflib
import itertools
import json
import re
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

import yaml


ROOT_PATH = Path(__file__).resolve().parent.parent
BUGS_YAML = ROOT_PATH / "docs" / "bugs.yaml"
BUGS_JSON = ROOT_PATH / "docs" / "bugs.json"
BUGS_BY_VERSION = ROOT_PATH / "docs" / "bugs_by_version.json"
CHANGELOG = ROOT_PATH / "Changelog.md"
CMAKE_LISTS = ROOT_PATH / "CMakeLists.txt"


def comp(version_string):
    return [int(component) for component in version_string.split(".")]


def released_versions(changelog_path):
    """All versions with a release date in the Changelog, mapped to the date."""
    return dict(re.findall(
        r"^### (\S+) \((\d+-\d+-\d+)\)$",
        changelog_path.read_text(encoding="utf8"),
        re.MULTILINE,
    ))


def version_being_released(changelog_path, cmake_path):
    """
    The version from CMakeLists.txt if it already has a release date in the
    Changelog, i.e. if a release is being made, and None otherwise.
    """
    dated_versions = released_versions(changelog_path)
    project_version_match = re.search(
        r'^\s*set\(PROJECT_VERSION "(\d+\.\d+\.\d+)"\)\s*$',
        cmake_path.read_text(encoding="utf8"),
        re.MULTILINE,
    )
    if project_version_match is None:
        sys.exit(f"Could not find PROJECT_VERSION in {cmake_path}.")
    project_version = project_version_match.group(1)
    if len(dated_versions) != 0 and max(dated_versions, key=comp) == project_version:
        return project_version
    return None


def assign_uids(yaml_text, bugs):
    """
    Fill in the next free uid of the current year for every entry with an
    empty "uid" field.
    """
    year = datetime.now(timezone.utc).year
    uid_matches = (
        re.match(rf"^SOL-{year}-(\d+)$", bug.get("uid") or "")
        for bug in bugs
    )
    last_sequence = max(
        (int(match.group(1)) for match in uid_matches if match is not None),
        default=0,
    )
    sequence = itertools.count(last_sequence + 1)
    return re.sub(
        r"^-[ \t]+uid:[ \t]*$",
        lambda _: f"- uid: SOL-{year}-{next(sequence)}",
        yaml_text,
        flags=re.MULTILINE,
    )


def update_bugs(
    input_path=BUGS_YAML,
    output_path=BUGS_JSON,
    changelog_path=CHANGELOG,
    cmake_path=CMAKE_LISTS,
):
    """
    Assign uids and resolve released fixes in the YAML source, then
    generate the JSON bug list from it and return the generated list.
    """
    yaml_text = input_path.read_text(encoding="utf8")
    bugs = yaml.safe_load(yaml_text)

    new_text = assign_uids(yaml_text, bugs)
    release = version_being_released(changelog_path, cmake_path)
    if release is not None:
        new_text = re.sub(
            r"^([ \t]+fixed:)[ \t]*next[ \t]*$",
            rf"\g<1> {release}",
            new_text,
            flags=re.MULTILINE,
        )
    if new_text != yaml_text:
        input_path.write_text(new_text, encoding="utf8")
        bugs = yaml.safe_load(new_text)

    for bug in bugs:
        if not bug.get("uid"):
            sys.exit(f'Could not assign a uid to "{bug["name"]}". Use an empty "uid:" line in the entry.')
        if not bug.get("fixed"):
            sys.exit(f'Missing "fixed" version for {bug["uid"]}. Use "next" for a fix that is not released yet.')

    pending_bugs = [bug["uid"] for bug in bugs if bug["fixed"] == "next"]
    if len(pending_bugs) != 0:
        print(
            "NOTE: bug list entries pending a release, not published yet: " + ", ".join(pending_bugs),
            file=sys.stderr,
        )

    published_bugs = [bug for bug in bugs if bug["fixed"] != "next"]
    output_path.write_text(
        json.dumps(
            published_bugs,
            sort_keys=False,
            indent=4,
            separators=(",", ": "),
        ) + "\n",
        encoding="utf8",
    )
    return published_bugs


def update_bugs_by_version(
    bugs,
    output_path=BUGS_BY_VERSION,
    changelog_path=CHANGELOG,
):
    """Generate the list of bugs per released compiler version."""
    versions = {
        version: {"released": date}
        for version, date in released_versions(changelog_path).items()
    }
    for key, value in versions.items():
        value["bugs"] = []
        for bug in bugs:
            if "introduced" in bug and comp(bug["introduced"]) > comp(key):
                continue
            if comp(bug["fixed"]) <= comp(key):
                continue
            value["bugs"] += [bug["name"]]

    output_path.write_text(json.dumps(
        versions,
        sort_keys=True,
        indent=4,
        separators=(",", ": ")
    ), encoding="utf8")


def check_up_to_date(
    yaml_path=BUGS_YAML,
    json_path=BUGS_JSON,
    by_version_path=BUGS_BY_VERSION,
    changelog_path=CHANGELOG,
    cmake_path=CMAKE_LISTS,
):
    """
    Regenerate the bug lists in a temporary directory and fail if the result
    differs from the existing files.
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        yaml_copy = Path(temp_dir) / "bugs.yaml"
        yaml_copy.write_text(yaml_path.read_text(encoding="utf8"), encoding="utf8")
        json_output = Path(temp_dir) / "bugs.json"
        by_version_output = Path(temp_dir) / "bugs_by_version.json"

        bugs = update_bugs(yaml_copy, json_output, changelog_path, cmake_path)
        update_bugs_by_version(bugs, by_version_output, changelog_path)

        stale_files = []
        for regenerated_file, current_file in (
            (yaml_copy, yaml_path),
            (json_output, json_path),
            (by_version_output, by_version_path),
        ):
            regenerated_text = regenerated_file.read_text(encoding="utf8")
            current_text = current_file.read_text(encoding="utf8")
            if regenerated_text == current_text:
                continue
            if current_file.is_relative_to(ROOT_PATH):
                display_name = str(current_file.relative_to(ROOT_PATH))
            else:
                display_name = str(current_file)
            stale_files.append(display_name)
            sys.stderr.writelines(difflib.unified_diff(
                current_text.splitlines(keepends=True),
                regenerated_text.splitlines(keepends=True),
                fromfile=display_name,
                tofile=f"{display_name} (regenerated)",
            ))
    if len(stale_files) != 0:
        sys.exit(
            "Out of date: " + ", ".join(stale_files) + ". "
            "Run scripts/update_bugs_by_version.py and commit the changes."
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Only verify that the generated files are up to date, without modifying them.",
    )
    if parser.parse_args().check:
        check_up_to_date()
    else:
        update_bugs_by_version(update_bugs())
