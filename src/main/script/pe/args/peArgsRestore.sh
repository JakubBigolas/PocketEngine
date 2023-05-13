function peArgsRestore {
  local contextFile="$1" ; shift
  local target="$1"      ; shift

  # read raw args file
  local contextArgs=()
  [[ -f "$contextFile" ]] && readarray -t contextArgs < "$contextFile"

  local type="key"
  for it in "${contextArgs[@]}"
  do
    if [[ $type = "key" ]]; then
      key="$it"
      type="value"
    elif [[ $type = "value" ]]; then
      value="$it"
      type="key"

      # replace newline replacements with newline
      key="${key//\\n/$'\n'}"
      value="${value//\\n/$'\n'}"

      peArgsAddPair "$key" "$value" $target

    fi
  done

}