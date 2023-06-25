function stdArraysCopy {
  local source="$1" ; shift
  local target="$1" ; shift

  eval "$target=(\"\${$source[@]}\")"

}