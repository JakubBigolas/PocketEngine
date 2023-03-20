function peOptionContext {
  local contextFile=$1
  shift
  local args=($@)
  local contextArgs=()

  # read raw args file
  [[ -f "$contextFile" ]] && contextArgs=(`cat "$home/config/context"`)

  local type="key"
  for it in ${contextArgs[@]}
  do
    if [[ $type = "key" ]]; then
      key="$it"
      type="value"
    elif [[ $type = "value" ]]; then
      value="$it"
      type="key"

      args=($(peArgsAddPair "$key" "$value" ${args[@]}))

    fi
  done

  echo " ${args[@]}"
}