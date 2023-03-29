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
      echo -e "${C_GREEN}Context: ${C_WHITE}$file${C_RESET}"

      # read raw args file
      readarray -t contextArgs < "$PE_CONTEXT_PATH/execs/$file"

      echo
      printf "${C_WHITE} >"
      local format="${C_I_BLUE}"
      # print in pretty format
      for it in "${contextArgs[@]}"
      do

          [[ "$it" = "-"    ]] && echo && printf "${C_WHITE} >"  && format="${C_I_BLUE}"
          [[ "$it" = "--"   ]] && echo && printf "${C_WHITE} >>"
          [[ ! "$it" = "-"  ]] && [[ ! "$it" = "--" ]] && printf "${format} %s" "$it" && format="${C_RESET}"

      done
      echo
      echo

    fi
  done
  exit 0

}