function peOptionContextList {
  local search=${1/context-list/}
  local search=${search/\//}
  local contextFiles=
  mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/context")
  for file in "${contextFiles[@]}"
  do
    if [[ -z "$search" ]] || [[ "$file" =~ $search ]]; then
      echo -e "${C_GREEN}Context: ${C_WHITE}$file${C_RESET}"
      echo ""
      cat "$PE_CONTEXT_PATH/context/$file"
      echo ""
    fi
  done
  exit 0
}