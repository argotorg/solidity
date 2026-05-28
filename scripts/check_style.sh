#!/usr/bin/env bash

set -eu

ERROR_LOG="$(mktemp -t check_style_XXXXXX.log)"

EXCLUDE_FILES=(
    # The line below is left unquoted to allow the shell globbing path expansion
    deps/*
    test/cmdlineTests/*/{err,output}
    "libsolutil/picosha2.h"
    "test/cmdlineTests/strict_asm_only_cr/input.yul"
    "test/libsolutil/UTF8.cpp"
    "test/libsolidity/syntaxTests/license/license_cr_endings.sol"
    "test/libsolidity/syntaxTests/license/license_crlf_endings.sol"
    "test/libsolidity/syntaxTests/license/license_whitespace_trailing.sol"
    "test/scripts/fixtures/smt_contract_with_crlf_newlines.sol"
    "test/scripts/fixtures/smt_contract_with_cr_newlines.sol"
    "test/scripts/fixtures/smt_contract_with_mixed_newlines.sol"
)
EXCLUDE_FILES_JOINED=$(printf "%s\|" "${EXCLUDE_FILES[@]}")
EXCLUDE_FILES_JOINED=${EXCLUDE_FILES_JOINED%??}

(
REPO_ROOT="$(dirname "$0")"/..
cd "$REPO_ROOT" || exit 1

function preparedGrep
{
    git grep -nIE "$1" -- '*.h' '*.cpp' ':!test/' | grep -v "${EXCLUDE_FILES_JOINED}"
    return $?
}

function addPrefix
{
    sed "s/^/[$1] /"
}

WHITESPACE=$(git grep -n -I -E "^.*[[:space:]]+$" |
    grep -v "test/libsolidity/ASTJSON\|test/compilationTests/zeppelin/LICENSE\|${EXCLUDE_FILES_JOINED}" || true
)

if [[ "$WHITESPACE" != "" ]]
then
    echo "Error: Trailing whitespace found:" | tee -a "$ERROR_LOG"
    echo "$WHITESPACE" | addPrefix "Trailing whitespace" | tee -a "$ERROR_LOG"
fi

FORMATERROR=$(
(
    preparedGrep "#include \"" | grep -E -v -e "license.h" -e "BuildInfo.h" | addPrefix "Use angle brackets for includes"
    preparedGrep "\<(if|for|while|switch)\(" | addPrefix "Missing space after keyword"
    preparedGrep "\<for\>[[:space:]]*\([^=]*\>[[:space:]]:[[:space:]].*\)" | addPrefix "Missing space before range-based for colon"
    preparedGrep "\<if\>[[:space:]]*\(.*\)[[:space:]]*\{[[:space:]]*$" | addPrefix "Opening brace on same line as if"
    preparedGrep "namespace .*\{" | addPrefix "Missing space before opening brace in namespace"
    preparedGrep "[,\(<][[:space:]]*const " | addPrefix "const should be on the right side of the type"
    preparedGrep "^[[:space:]]*(static)?[[:space:]]*const " | addPrefix "const should be on the right side of the type"
    preparedGrep "^ [^*]|[^*] 	|	 [^*]" | addPrefix "Use tabs for indentation"
    preparedGrep "[a-zA-Z0-9_][[:space:]]*[&][a-zA-Z_]" | grep -E -v "return [&]" | addPrefix "Reference ampersand should be left-aligned"
    preparedGrep "[a-zA-Z0-9_][[:space:]]*[*][a-zA-Z_]" | grep -E -v -e "return [*]" -e ":[0-9]+:[[:space:]]*\*[[:space:]]" -e "//" | addPrefix "Pointer star should be left-aligned"
    preparedGrep "move\(.+\)" | grep -v "std::move" | grep -E "[^a-z]move" | addPrefix "Use std::move"
    preparedGrep "forward\(.+\)" | grep -v "std::forward" | grep -E "[^a-z]forward" | addPrefix "Use std::forward"
) | grep -E -v -e "^\[[^]]*\] [a-zA-Z./]*:[0-9]*:[[:space:]]*/[/*]" || true
)

# Special error handling for `using namespace std;` exclusion, since said statement can be present in the test directory
# and its subdirectories, but is excluded in the above ruleset. In order to have consistent codestyle with regards to
# std namespace usage, test directory must also be covered.
FORMATSTDERROR=$(
(
    git grep -nIE "using namespace std;" -- '*.h' '*.cpp' | addPrefix "Do not use 'using namespace std'"
) || true
)

# Merge errors into single string
FORMATEDERRORS=$(printf '%s\n' "$FORMATERROR" "$FORMATSTDERROR" | grep -v '^$' || true)

if [[ "$FORMATEDERRORS" != "" ]]
then
    echo "Coding style error:" | tee -a "$ERROR_LOG"
    echo "$FORMATEDERRORS" | tee -a "$ERROR_LOG"
fi

if [[ -s "$ERROR_LOG" ]]
then
    exit 1
fi
)
