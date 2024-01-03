if [ -n "${pres_custom_script}" ]; then
  echo "Executing ${pres_custom_script}"
  eval "${pres_custom_script}"
else
  echo "Pre Task is skipped."
fi