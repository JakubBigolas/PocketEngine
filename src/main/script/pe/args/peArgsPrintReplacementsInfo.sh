peArgsPrintReplacementsInfo() {
  local source="$1"

  local keysExpressions=()
  local valuesExpressions=()
  local eachExpressions=()
  readarray -t keysExpressions   < <(echo "$(echo "$source" | grep --only-matching -P "<<##[^#].*?#>>")")
  readarray -t valuesExpressions < <(echo "$(echo "$source" | grep --only-matching -P "<<#[^#].*?#>>")")
  readarray -t eachExpressions   < <(echo "$(echo "$source" | grep --only-matching -P "<<###each:.*?#>>")")

  if [[ "${#keysExpressions}" -gt 0 ]] ; then
    echo " Key expressions:"

    local expressions=()
    for key in "${keysExpressions[@]}" ; do
      key="${key/#"<<##"/}"
      key="${key/%"##>>"/}"
      local required=
      local optional=
      local emptyReplacement=
      local replacement=
      [[ "$key" =~ ^[!]   ]] && required=" ${C_RED}(required)${C_RESET}" && key="${key/#"!"/}"
      [[ "$key" =~ ^[?]   ]] && optional=" ${C_BLUE}(optional)${C_RESET}" && key="${key/#"?"/}"
      [[ "$key" =~ [?][:] ]] && emptyReplacement=" or ${C_BLACK}${C_BG_YELLOW}${key/#*"?:"/}${C_RESET}" && key="${key/"?:"*/}"
      [[ "$key" =~ [|]    ]] && replacement=" replace with ${C_BLACK}${C_BG_YELLOW}${key/#*"|"/}${C_RESET}" && key="${key/"|"*/}"
      expressions+=("${C_BLACK}${C_BG_YELLOW}$key${C_RESET}$required$optional$emptyReplacement$replacement")
    done

    for it in "${expressions[@]}" ; do
      echo -e " - $it"
    done | sort -u
    
    echo
  fi

  if [[ "${#valuesExpressions}" -gt 0 ]] ; then
    echo " Value expressions:"

    local expressions=()
    for value in "${valuesExpressions[@]}" ; do
      value="${value/#"<<#"/}"
      value="${value/%"#>>"/}"
      local required=
      local optional=
      local emptyReplacement=
      [[ "$value" =~ ^[!]   ]] && required=" ${C_RED}(required)${C_RESET}" && value="${value/#"!"/}"
      [[ "$value" =~ ^[?]   ]] && optional=" ${C_BLUE}(optional)${C_RESET}" && value="${value/#"?"/}"
      [[ "$value" =~ [?][:] ]] && emptyReplacement=" or ${C_BLACK}${C_BG_YELLOW}${value/#*"?:"/}${C_RESET}" && value="${value/"?:"*/}"
      expressions+=("${C_BLACK}${C_BG_YELLOW}$value${C_RESET}$required$optional$emptyReplacement")
    done

    for it in "${expressions[@]}" ; do
      echo -e " - $it"
    done | sort -u

    echo
  fi

  if [[ "${#eachExpressions}" -gt 0 ]] ; then
    echo " Each loop expressions:"

    local expressions=()
    for key in "${eachExpressions[@]}" ; do
      key="${key/#"<<###each:"/}"
      key="${key/%"###>>"/}"
      expressions+=("${C_BLACK}${C_BG_YELLOW}$key${C_RESET}")
    done

    for it in "${expressions[@]}" ; do
      echo -e " - $it"
    done | sort -u

    echo
  fi

}