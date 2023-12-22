#!/usr/bin/env bash
echo "myfile"
#!/usr/bin/env bash
echo "input is ${pre_clean}"
echo "path is ${clean_path}"
echo "Executing ${pre_custom_script}"
eval "${pre_custom_script}"

if [ "${pre_clean}" == true ]; then
  echo "Running pre-job cleanup..."
  if [ "${clean_path}" != 'false' ]; then
    rm -rf ${clean_path}
    echo "Cleaned ${clean_path}"
  fi

else
  echo "pre cleanup is skipped."
fi