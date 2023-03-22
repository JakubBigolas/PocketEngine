function peArgsRemoveKey {
    local newArgs=()
    local argKey="$1"
    shift

    # for key is array split and iterate
    if [[ $(peArgsIsArray "$argKey") = true ]]; then
      local split=("${argKey//[\[\],]/ }")
      newArgs=("$@")
      for sval in "${split[@]}"
      do
        eval "newArgs=($(peArgsRemoveKey "$sval" "${newArgs[@]}"))"
      done

      for it in "${newArgs[@]}" ; do echo "'$it'" ; done

    # if key is single regular value
    else

      local key=
      local value=
      local type="key"



      for it in "$@"
      do

        # for key remember and switch to value
        if [[ $type = "key" ]]; then
          key="$it"
          type="value"

        # for value do checks and switch to key
        elif [[ $type = "value" ]]; then
          value="$it"
          type="key"

          local keyWithoutValue="${key/=*/}"
          local argKeyWithoutValue="${argKey/=*/}"

          # not left if keys are the same with or without '='
          if [[ ! "$key" = "$argKey" ]] && [[ ! "$keyWithoutValue" = "$argKeyWithoutValue" ]]; then
            echo "'$key'"
            echo "'$value'"
          fi

        fi

      done



    fi
}