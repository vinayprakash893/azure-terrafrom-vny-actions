#!/usr/bin/env bash
#!/usr/bin/env bash
echo "Executing ${post_custom_script}"
eval "${post_custom_script}"

# echo "input is ${post_clean}"
# echo "path is ${clean_path}"
# if [ "${post_clean}" == true ]; then
#   echo "Running post-job cleanup..."
#   if [ "${clean_path}" != 'false' ]; then
#     rm -rf ${clean_path}
#     echo "Cleaned ${clean_path}"
#   fi
#   # set -o errexit -o nounset -o xtrace -o pipefail
#   # shopt -s inherit_errexit nullglob dotglob

#   # rm -rf "${HOME:?}"/* "${GITHUB_WORKSPACE:?}"/*

#   # if test "${RUNNER_DEBUG:-0}" != '1'; then
#   #   set +o xtrace
#   # fi
# else
#   echo "Post cleanup is skipped."
# fi