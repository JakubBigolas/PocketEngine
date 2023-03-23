function peOptionExecList {
  local search=${1/exec-list/}
  local search=${search/\//}
  local contextFiles=
  mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/execs")
  for file in "${contextFiles[@]}"
  do
    if [[ -z "$search" ]] || [[ "$file" =~ $search ]]; then
      echo -e "${C_GREEN}Execution: ${C_WHITE}$file${C_RESET}"
      echo ""
      cat "$PE_CONTEXT_PATH/execs/$file"
      echo ""
    fi
  done
  exit 0
}