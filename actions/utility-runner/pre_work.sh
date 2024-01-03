#!/usr/bin/env bash
echo "Executing ${pre_custom_script}"
eval "${pre_custom_script}"

if [ -n "${pre_custom_script}" ]; then
  eval "${pre_custom_script}"
else
  echo "Pre Task is skipped."
fi

# echo "pre_clean_input is ${pre_clean}"
# echo "pre_clean_path is ${clean_path}"
# if [ "${pre_clean}" == true ]; then
#   echo "Running pre-job cleanup..."
#   if [ "${clean_path}" != 'false' ]; then
#     rm -rf ${clean_path}
#     echo "Cleaned ${clean_path}"
#   fi

# else
#   echo "pre cleanup is skipped."
# fi