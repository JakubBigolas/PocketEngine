function peOptionExecList {

  # search expression from argument
  local search=${1/exec-list/}
  local search=${search/\//}

  # array of files from "$PE_CONTEXT_PATH/execs"
  local contextFiles=
  mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/execs")

  for file in "${contextFiles[@]}"
  do
    if [[ -z "$search" ]] || [[ "$file" =~ $search ]]; then
      echo -e "${C_GREEN}Execution: ${C_WHITE}$file${C_RESET}"

      local contextArgs=()
      # read raw args file
      readarray -t contextArgs < "$PE_CONTEXT_PATH/execs/$file"

      echo
      printf "${C_WHITE} >"
      local format="${C_I_BLUE}"
      local isApp=true
      local line=""
      # print in pretty format
      for it in "${contextArgs[@]}"
      do

          [[ "$it" = "-"    ]] && echo && printf "${C_WHITE} >"  && format="${C_I_BLUE}" && isApp=true
          [[ "$it" = "--"   ]] && echo && printf "${C_WHITE} >>"

          if [[ ! "$it" = "-"  ]] && [[ ! "$it" = "--" ]] ; then
            if [[ $isApp = false ]] ; then
              local itWrapped=("$it")
              peArgsWrap itWrapped "$it"
              it="${itWrapped[*]}"
              line+="$it"
            else
              isApp=false
            fi
            printf "${format} %s" "$it"
            format="${C_RESET}"
          fi

      done
      echo
      echo
      [[ -n "$line" ]] && peArgsPrintReplacementsInfo "$line"

    fi
  done
  exit 0

}