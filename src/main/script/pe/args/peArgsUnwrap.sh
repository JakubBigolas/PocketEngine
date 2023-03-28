function peArgsUnwrap {
  local args=()

  for arg in "$@"
  do # remove internal args
    [[ ! "$arg" =~ ^\[#.*\]$ ]] && [[ ! "$arg" =~ ^\"\[#.*\]\"$ ]] && args=("${args[@]}" "$arg")
  done

  local unwrap=" ${args[*]}"
  local unwrap=${unwrap//\\\`/\`} # \` -> `
  local unwrap=${unwrap//\\\$/\$} # \$ -> $
  echo " $unwrap"
}