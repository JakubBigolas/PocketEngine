function peArgsStore {
  local path="$1"
  shift

  if [[ -f "$path" ]]; then
    rm "$path"
  fi

  for arg in "$@"
  do
    printf "%s\n" "${arg//$'\n'/\n}" >> "$path"
  done

}