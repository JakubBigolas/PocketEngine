function peArgsStore {
  local path="$1"
  shift

  # delete old version
  if [[ -f "$path" ]]; then
    rm "$path"
  fi

  # print new version
  for arg in "$@"
  do
    printf "%s\n" "${arg//$'\n'/\n}" >> "$path"
  done

}