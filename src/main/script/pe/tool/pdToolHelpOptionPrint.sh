function pdToolHelpOptionPrint {
  local width=${3-16}
  printf " ${C_BLUE}%-${width}s ${C_RESET}%s\n" "$1" "$2"
}