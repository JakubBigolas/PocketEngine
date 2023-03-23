function peArgsAddPair {
    local newArgs=()
    local argKey="$1"
    local argValue="$2"
    shift
    shift

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
        peArgsWrap "$key"
        peArgsWrap "$value"
      fi

    done

    # if there were nothing to replace add new value
    [[ $isNew = true ]] && peArgsWrap "$argKey"
    [[ $isNew = true ]] && peArgsWrap "$argValue"

}