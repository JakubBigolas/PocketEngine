function peArgsAddPair {
    local newArgs=()
    local argKey="$1"
    local argValue="$2"
    shift
    shift

    # for key is array split and iterate
    if [[ $(peArgsIsArray "$argKey") = true ]]; then
      local split=("${argKey//[\[\],]/ }")
      newArgs=("$@")
      for sval in "${split[@]}"
      do
        eval "newArgs=($(peArgsAddPair "$sval" "" "${newArgs[@]}"))"
      done

      for it in "${newArgs[@]}" ; do echo "'$it'" ; done

    # if key is single regular value
    else

      # if there is no value then set empty replacement as arg value
      [[ $(peArgsIsPairKeyValue "$argKey" "$argValue") = false ]] && argValue="[#]"

      local key=
      local value=
      local type="key"
      local isNew=true



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

          # if keys are the same replace value with arg value
          if [[ "$key" = "$argKey" ]]; then
            value="$argValue"
            isNew=false

          else

            # if keys without value after '=' are the same then replace key and value with args
            local keyWithoutValue="${key/=*/}"
            local argKeyWithoutValue="${argKey/=*/}"
            if [[ "$keyWithoutValue" = "$argKeyWithoutValue" ]]; then
              key="$argKey"
              value="$argValue"
              isNew=false

              # if new key has sign '=' then replace value with empty replacement however
              [[ ! "$argKeyWithoutValue" = "$argKey" ]] && value="[#]"

            fi

          fi

          # return calculated pair key value
          echo "'$key'"
          echo "'$value'"

        fi

      done



      # if there were nothing to replace add new value
      [[ $isNew = true ]] && echo "'$argKey'"
      [[ $isNew = true ]] && echo "'$argValue'"

    fi
}