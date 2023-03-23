function peArgsChooseKey {
    local newArgs=()
    local argKey="$1"
    shift

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

        # not left if keys are the same with or without '='
        if [[ "$key" == "$argKey" ]] || [[ "$keyWithoutValue" = "$argKey" ]]; then
          peArgsWrap "$key"
          peArgsWrap "$value"
          break
        fi

      fi

    done

}