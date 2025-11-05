#!/usr/bin/env bash
set -euo pipefail

(( $# <= 2 )) || { >&2 echo "Usage: $0 [PRERELEASE_SOURCE] [GIT_TAG]"; exit 1; }
prerelease_source="${1:-nightly}"
git_tag="${2:-}"
FORCE_RELEASE="${FORCE_RELEASE:-}"

GNU_DATE="date"
if [[ "$OSTYPE" == "darwin"* ]]; then
    GNU_DATE=gdate
fi

if [[ $FORCE_RELEASE != "" || $git_tag =~ ^v[0-9.]+$ ]]; then
    echo -n
elif [[ $git_tag =~ ^v[0-9.]+-pre. ]]; then
    echo -n "pre.${git_tag#*-pre.}"
else
    # Use last commit date rather than build date to avoid ending up with builds for
    # different platforms having different version strings (and therefore producing different bytecode)
    # if the CI is triggered just before midnight.
    # NOTE: The -local suffix makes git not use the timezone from the commit but instead convert to
    # local one, which we explicitly set to UTC.
    # NOTE: git --date is supposed to support the %-m/%-d format too, but it does not seem to
    # work on Windows. Without it we get leading zeros for month and day.
    last_commit_date=$(TZ=UTC git show --quiet --date="format-local:%Y-%m-%d" --format="%cd")
    last_commit_date_stripped=$("$GNU_DATE" --date "$last_commit_date" "+%Y.%-m.%-d")
    echo -n "${prerelease_source}.${last_commit_date_stripped}"
fi
