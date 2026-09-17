#!/usr/bin/env bash
set -e

function error
{
  echo >&2 "ERROR: ${1} Aborting." && false
}

function warning
{
  echo >&2 "WARNING: ${1}"
}

[[ $# == 2 ]] || error "Expected exactly 2 parameters: '${0} <IMAGE_NAME> <IMAGE_VARIANT>'."

IMAGE_NAME="${1}"
IMAGE_VARIANT="${2}"
DOCKERFILE="scripts/docker/${IMAGE_NAME}/Dockerfile.${IMAGE_VARIANT}"

echo "-- check_dockerfile_was_changed"

# exit, if the dockerfile was not changed.
if git diff --quiet origin/develop HEAD -- "${DOCKERFILE}"; then
  echo "${DOCKERFILE} was not changed. Nothing to do."
  exit 0
fi

echo "-- check_version"

PREV_VERSION=$(git diff origin/develop HEAD -- "${DOCKERFILE}" | grep -e '^\s*-LABEL\s\+version=".*"\s*$' | awk -F'"' '{ print $2 }')
NEXT_VERSION=$(git diff origin/develop HEAD -- "${DOCKERFILE}" | grep -e '^\s*+LABEL\s\+version=".*"\s*$' | awk -F'"' '{ print $2 }')

[[ $NEXT_VERSION != "" ]] || error "No version label defined in Dockerfile. You may need to add 'LABEL version' in '${DOCKERFILE}'."

[[ $PREV_VERSION != "" ]] || {
  warning "no previous version found. Will set \$PREV_VERSION = 0."
  PREV_VERSION=0
}

if [[ $((PREV_VERSION + 1)) != $((NEXT_VERSION)) ]]; then
  error "Version label in Dockerfile was not incremented. You may need to change 'LABEL version' in '${DOCKERFILE}'."
fi

echo "-- build_docker"

# This is a workaround: we run `docker build` twice to prevent the `layer does not exist` problem.
# See https://github.com/moby/moby/issues/37965.
docker build "scripts/docker/${IMAGE_NAME}" --file "scripts/docker/${IMAGE_NAME}/Dockerfile.${IMAGE_VARIANT}" --tag "${IMAGE_NAME}" ||
  docker build "scripts/docker/${IMAGE_NAME}" --file "scripts/docker/${IMAGE_NAME}/Dockerfile.${IMAGE_VARIANT}" --tag "${IMAGE_NAME}"

echo "-- test_docker @ '${PWD}'"

docker run \
  --rm \
  --volume "${PWD}:/project" \
  -u "$(id -u "${USER}"):$(id -g "${USER}")" \
  "${IMAGE_NAME}" \
  bash -c "/project/scripts/ci/${IMAGE_NAME}_test_${IMAGE_VARIANT}.sh"

