function peArgsAddPair {
    local argKey="$1"   ; shift
    local argValue="$1" ; shift
    local target="$1"   ; shift

    local __return=()
    local targetCopy=()

    # copy from source reference
    stdArraysCopy $target targetCopy

    # if there is no value then set empty replacement as arg value
    [[ $(peArgsIsPairKeyValue "$argKey" "$argValue") = false ]] && argValue="[#]"

    local key=
    local value=
    local type="key"
    local isNew=true

    for it in "${targetCopy[@]}"
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
        __return+=("$key")
        __return+=("$value")
      fi

    done

    # if there were nothing to replace add new value
    [[ $isNew = true ]] && __return+=("$argKey")
    [[ $isNew = true ]] && __return+=("$argValue")

    # copy by reference
    stdArraysCopy __return $target

}