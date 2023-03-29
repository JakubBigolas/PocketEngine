function peArgsRestore {
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

      # evaluate in array-safe way
      eval "args=($(peArgsAddPair "$key" "$value" "${args[@]}"))"

    fi
  done

  # return in array-safe way
  for arg in "${args[@]}" ; do peArgsWrap "$arg" ; done

}