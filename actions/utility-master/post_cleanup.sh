#!/usr/bin/env bash
if [ "${POST_CLEAN}" == "true" ]; then
  echo "Running post-job cleanup..."
  set -o errexit -o nounset -o xtrace -o pipefail
  shopt -s inherit_errexit nullglob dotglob

  rm -rf "${HOME:?}"/* "${GITHUB_WORKSPACE:?}"/*

  if test "${RUNNER_DEBUG:-0}" != '1'; then
    set +o xtrace
  fi
else
  echo "Post cleanup is skipped."
fi