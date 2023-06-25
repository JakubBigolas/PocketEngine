
# wrap each argument replacing each each sensitive char with escape

function peArgsWrapStatic {
  local target="$1" ; shift

  local __result=()

  replacement="'\''"

  for arg in "$@" ; do
    arg="${arg//"'"/$replacement}"
    __result+=("'$arg'")
  done

  stdArraysCopy __result $target

}