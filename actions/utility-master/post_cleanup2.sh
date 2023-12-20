#!/usr/bin/env bash
echo "input22 is ${POST_CLEAN}"
echo "path22 is ${clean_path}"
if [ "${POST_CLEAN}" == true ]; then
  echo "Running222 post-job cleanup..."
  if [ "${clean_path}" != 'false' ]; then
    rm -rf ${clean_path}
    echo "Cleaned222 ${clean_path}"
  fi
  # set -o errexit -o nounset -o xtrace -o pipefail
  # shopt -s inherit_errexit nullglob dotglob

  # rm -rf "${HOME:?}"/* "${GITHUB_WORKSPACE:?}"/*

  # if test "${RUNNER_DEBUG:-0}" != '1'; then
  #   set +o xtrace
  # fi
else
  echo "Post cleanup is skipped.2222"
fi