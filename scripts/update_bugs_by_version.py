#!/usr/bin/env python3

"""Regenerate the known-bugs lists from the human-editable YAML source.

docs/bugs.yaml is the only file meant to be edited by hand.
This script generates docs/bugs.json from it and docs/bugs_by_version.json
from the result and the release dates in the Changelog.
It updates the files in place and signals failure in CI if that results in
changes, which makes sure that the generated files stay up to date.

A new entry in bugs.yaml may leave the "uid" field empty, in which case the
next free uid of the current year is assigned.
An entry whose fix is not released yet must use "next" as its "fixed"
version.
Such entries are omitted from the generated files until the release.
During the release, when the version from CMakeLists.txt receives its
release date in the Changelog, "next" is replaced with that version.
"""

import itertools
import json
import re
import sys
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
        r'set\(PROJECT_VERSION "(\d+\.\d+\.\d+)"\)',
        cmake_path.read_text(encoding="utf8"),
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
        r"^- uid:[ \t]*$",
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
        new_text = re.sub(r"^(  fixed:) next$", rf"\g<1> {release}", new_text, flags=re.MULTILINE)
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


if __name__ == "__main__":
    update_bugs_by_version(update_bugs())
