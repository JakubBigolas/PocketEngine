function peArgsUnwrap {
  local target="$1" ; shift

  local __result=()

  for arg in "$@"
  do # remove internal args
    if [[ ! "$arg" =~ ^\[#.*\]$ ]] && [[ ! "$arg" =~ ^\"\[#.*\]\"$ ]] ; then
      __result+=("$arg")
    fi
  done

  stdArraysCopy __result $target
}