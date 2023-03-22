function peOptionContext {
  local contextFile=$1
  shift
  local args=("$@")
  local contextArgs=()

  # read raw args file
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

      eval "args=($(peArgsAddPair "$key" "$value" "${args[@]}"))"

    fi
  done

  for arg in "${args[@]}" ; do echo "'$arg'" ; done

}