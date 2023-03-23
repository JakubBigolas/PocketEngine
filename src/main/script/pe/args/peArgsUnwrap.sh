function peArgsUnwrap {
  local args=()

  for arg in "$@"
  do # remove internal args
    [[ ! "$arg" =~ ^\[#.*\]$ ]] && [[ ! "$arg" =~ ^\"\[#.*\]\"$ ]] && args=("${args[@]}" "$arg")
  done

  echo " ${args[*]}"
}