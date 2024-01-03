if [ -n "${custom_script}" ]; then
  echo "Executing ${custom_script}"
  eval "${custom_script}"
else
  echo "No Script to Execute."
fi