function peOptionContextList {

  # search expression from arg
  local search=${1/context-list/}
  local search=${search/\//}

  # array of files in $PE_CONTEXT_PATH/context
  local contextFiles=
  mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/context")

  for file in "${contextFiles[@]}"
  do

    # print if nothing to search or context file name like search expression
    if [[ -z "$search" ]] || [[ "$file" =~ $search ]]; then
      echo -e "${C_GREEN}Context: ${C_WHITE}$file${C_RESET}"

      local contextArgs=()
      # read raw args file
      readarray -t contextArgs < "$PE_CONTEXT_PATH/context/$file"

      peArgsWrap contextArgs "${contextArgs[@]}"

      echo
      local type="key"
      for it in "${contextArgs[@]}"
      do
        if [[ $type = "key" ]]; then
          key="$it"
          type="value"
        elif [[ $type = "value" ]]; then
          value="$it"
          [[ "$value" = "[#]" ]] && value=
          type="key"

          # print in pretty format
          printf "${C_YELLOW}   KEY  ${C_RESET}: %s"  "$key"
          echo
          printf "${C_YELLOW}   VALUE${C_RESET}: %s" "$value"
          echo
          echo

        fi
      done

    fi
  done

  exit 0

}