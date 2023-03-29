function peOptionRun {

  local exec="$1"
  shift
  local verbose="$1"
  shift
  local devMode="$1"
  shift
  local args=("$@")
  local execFile=
  local verboseCmd=
  local devModeCmd=

  # read command from file
  [[ -f "$PE_CONTEXT_PATH/execs/$exec" ]] && readarray -t execFile < "$PE_CONTEXT_PATH/execs/$exec"

  # pass verbose argument
  [[ $verbose = true ]] && verboseCmd=" verbose"

  # pass devMode argument
  [[ $devMode = true ]] && devModeCmd=" dev-mode"

  # remove empty values
  local execArgs=()
  for arg in "${args[@]}" ; do [[ ! "$arg" = "[#]" ]] && execArgs=("${execArgs[@]}" "$arg") ; done

  # double package to restore original shape and wrap with wildcards
  eval "execArgs=($(peArgsWrap $(peArgsWrap "${execArgs[@]}")))"

  eval commands=
  eval "commands=($(peArgsWrap $(peArgsWrap "${execFile[@]}")))"


  # execute as subcommand
  local command="pe$verboseCmd$devModeCmd clear ${execArgs[*]} - ${commands[*]}"
  [[ $verbose = true ]] && echo "EXE: $command"
  ! eval "$command" && exit 1
  [[ $verbose = true ]] && echo "EXE: DONE"

}