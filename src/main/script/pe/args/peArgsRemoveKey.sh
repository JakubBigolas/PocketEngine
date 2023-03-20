function peArgsRemoveKey {
    local newArgs=()
    local argKey="$1"
    shift

    # for key is array split and iterate
    if [[ $(peArgsIsArray "$argKey") = true ]]; then
      local split=(${argKey//[\[\],]/ })
      newArgs=($@)
      for sval in ${split[@]}
      do
        newArgs=($(peArgsRemoveKey "$sval" "" ${newArgs[@]}))
      done

    # if key is single regular value
    else

      local key=
      local value=
      local type="key"



      for it in $@
      do

        # for key remember and swith to value
        if [[ $type = "key" ]]; then
          key="$it"
          type="value"

        # for value do checks and swith to key
        elif [[ $type = "value" ]]; then
          value="$it"
          type="key"

          local keyWithoutValue="${key/=*/}"
          local argKeyWithoutValue="${argKey/=*/}"

          # not left if keys are the same with or without '='
          [[ ! "$key" = "$argKey" ]] && [[ ! "$keyWithoutValue" = "$argKeyWithoutValue" ]] && newArgs=(${newArgs[@]} "$key" "$value")

        fi

      done



    fi

    # return
    echo " ${newArgs[@]}"
}