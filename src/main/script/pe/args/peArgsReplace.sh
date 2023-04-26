function peArgsReplace {
  local target="$1" ; shift

  local __return=()
  local __target=()

  # copy from source reference
  stdArraysCopy $target __target

  for input in "${__target[@]}" ; do

    local result=

    while : ; do

  #    echo "----------------------------------"

      # find everything before expression
      local before=
      before="${input/"<<#"*/}"

      # add it to result
      result="$result$before"

      # remove it from input
      input="${input/"$before"/}"

      # find expression
      local expr=${input/"#>>"*/}
      expr=${expr/"<<#"/}
  #    echo "EXPR: $expr"
      local originalExpr="<<#$expr#>>"

      # find everything after expression
      local after=${input/"<<#$expr#>>"/}

      # left after in input
      input="$after"

      if [[ -n "$expr" ]]; then

        local isKeyExpression=false
        local isConditional=false
        local isRequired=false
        local isEmptyReplacement=false
        local isReplacement=false

        local exprWithoutEmptyReplacement=
        local emptyReplacement=

        local exprWithoutReplacement=
        local replacement=

        # check if expression returns key (not input)
        if [[ "$expr" =~ ^#.*#$ ]]; then
          isKeyExpression=true
          expr="<<$expr>>"
          expr=${expr/"#>>"/}
          expr=${expr/"<<#"/}
  #        echo "KEY EXPR: $expr"
        fi

        # check if expression is conditional
        if [[ "$expr" =~ ^\?.* ]]; then
          isConditional=true
          expr="${expr/\?/}"
  #        echo "CONDITIONAL"
        fi

        # check if expression is required
        if [[ "$expr" =~ ^\!.* ]]; then
          isRequired=true
          expr="${expr/\!/}"
  #        echo "REQUIRED"
        fi

        # check if there is empty replacement
        if [[ "$expr" =~ .*:\?.* ]]; then

          # empty replacement cannot be combined with conditinal or required expression
          if [[ $isConditional = true ]] || [[ $isRequired = true ]]; then
            echo "ERROR: Empty replacement is not available for conditional/required expression ($originalExpr)"
            exit 1
          fi

          isEmptyReplacement=true
          exprWithoutEmptyReplacement=${expr/:\?*/}
          emptyReplacement=${expr/"$exprWithoutEmptyReplacement:?"/}
  #        echo "OR ELSE: $emptyReplacement"

        fi

        # check if there is key replacement
        if [[ "$expr" =~ .*\|.* ]]; then

          # key replacement may be only combined with key expression
          [[ $isKeyExpression = false ]]    && echo "ERROR: Replacement is not available for value expression ($originalExpr)" && exit 1

          # key replacement cannot be combined with empty replacement expression
          [[ $isEmptyReplacement = true ]]  && echo "ERROR: Replacement cannot be combined with empty replacement expression ($originalExpr)" && exit 1

          isReplacement=true
          exprWithoutReplacement=${expr/\|*/}
          replacement=${expr/"$exprWithoutReplacement|"/}
  #        echo "REPLACEMENT: $replacement"

        fi

        [[ $isEmptyReplacement = true ]] && expr="$exprWithoutEmptyReplacement"
        [[ $isReplacement = true ]]      && expr="$exprWithoutReplacement"

        local keyValuePair=()
        peArgsChooseKey "$expr" keyValuePair "$@"
        [[ "${#keyValuePair[@]}" -gt 2 ]] && echo "ERROR: cannot replace ($originalExpr), found more than one matching key." && exit 1

        local key="${keyValuePair[0]}"
        local value="${keyValuePair[1]}"
        [[ $value = "[#]" ]] && value=

  #      echo "KEY  : $key"
  #      echo "VALUE: $value"

        # if it is key expression
        if [[ $isKeyExpression = true ]]; then
          # and key is empty
          if [[ -z "$key" ]]; then
            # if is not conditional
            if [[ $isConditional = false ]] ; then
              # and is required - throw an error
              [[ $isRequired = true ]] && echo "ERROR: Required expression: key not found ($originalExpr)" && exit 1
              # or has empty replacement - replace it
              [[ $isEmptyReplacement = true ]] && key="$emptyReplacement"
              # or is not conditional and has replacement = replace it
              [[ $isReplacement = true ]] && key="$replacement"
            fi
          else
            [[ $isReplacement = true ]] && key="$replacement"
          fi
          # add key to expression
          result="$result$key"

        # if it is value expression
        else
          # and value is empty
          if [[ -z "$value" ]]; then
            # if is not conditional
            if [[ $isConditional = false ]] ; then
              # and is required - throw an error
              [[ $isRequired = true ]] && echo "ERROR: Required expression: value not found ($originalExpr)" && exit 1
              # or has empty replacement - replace it
              [[ $isEmptyReplacement = true ]] && value="$emptyReplacement"
            fi
          fi
          # add value to expression
          result="$result$value"

        fi

      fi

      # finish loop if input is empty
      [[ -z "$input" ]]  && break;

    done

    __return+=("$result")

  done

  stdArraysCopy __return $target

  # <<#?key#>>                      return value for key, if there is no value then ommit
  # <<#key#>>                       return value for key, if there is no value then return empty string
  # <<#key:?orElse#>>               return value for key, if there is no value then return "orElse"
  # <<#!key#>>                      return value for key, if there is no value then finish with error

  # <<##?key##>>                    return key, if there is no key then ommmit
  # <<##key##>>                     return key, if there is no key then return empty string
  # <<##key?:orElse##>>             return key, if there is no key then return "orElse"
  # <<##!key##>>                    return key, if there is no key then finish with error
  # <<##...key|replacement##>>      return replacement if there is a key
}