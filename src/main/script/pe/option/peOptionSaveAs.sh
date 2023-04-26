function peOptionSaveAs {
  local exec="$1" ; shift

  [[ -z "$exec" ]]    && echo "ERROR: nothing to save"            && exit 1
  [[ "$exec" = "-" ]] && echo "ERROR: name of execution required" && exit 1

  [[ -f "$PE_CONTEXT_PATH/execs/$exec" ]] && rm "$PE_CONTEXT_PATH/execs/$exec"

  for arg in "$@" ; do
    arg="${arg//$'\n'/\n}"
    echo "$arg" >> "$PE_CONTEXT_PATH/execs/$exec"
  done

}