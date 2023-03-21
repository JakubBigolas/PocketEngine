function main {
  local home=$1
  shift
  local args=()
  local startArgs=()
  local setArgsEnabled=true
  local storeArgs=false
  local storeDefaultArgs=false
  local execution=false
  local verbose=false
  local contextFile="context"

  # read default variables first
  [[ -f "$home/context/default" ]] && args=($(peOptionContext "$home/context/default" ${args[@]}))
  local defaultArgs=(${args[@]})

  while [[ $# -gt 0 ]]; do
    case $1 in

      help) # print help page
        peOptionHelp
        exit 0
        ;;

      version) # print version info
        peOptionVersion
        exit 0
        ;;

      verbose) # print command before execution
        verbose=true;
        shift
        ;;

      context) # read all stored variables
        args=($(peOptionContext "$home/context/context" ${args[@]}))
        shift
        ;;

      context-list) # read all available contexts
        ls "$home/context"
        exit 0
        ;;

      context/*) # read all stored variables from specific context
        contextFile=${1/"context/"/}
        [[ -z $contextFile ]] && contextFile="context"
        args=($(peOptionContext "$home/context/$contextFile" ${args[@]}))
        shift
        ;;

      store) # store all set variables
        storeArgs=true
        shift
        ;;

      store/*) # store all set variables in specific context
        storeArgs=true
        contextFile=${1/"store/"/}
        [[ -z $contextFile ]] && contextFile="context"
        shift
        ;;

      default) # store all set variables as default
        storeDefaultArgs=true
        shift
        ;;

      unset) # remove variable key/value (only one after unset)
        setArgsEnabled=false
        shift
        ;;

      set)
        setArgsEnabled=true
        shift
        ;;

      clear) # unset stored
        args=()
        shift
        ;;

      cleanup) # unset all stored variables values it is executed immediately end interrupt further execution
        [[ -f "$home/context/context" ]] && rm "$home/context/context"
        [[ -f "$home/context/default" ]] && rm "$home/context/default"
        exit 0
        ;;

      cleanup/*)# unset all stored variables values in specific context, it is executed immediately end interrupt further execution
        contextFile=${1/"store/"/}
        [[ -z $contextFile ]] && contextFile="context"
        [[ -f "$home/context/$contextFile" ]] && rm "$home/context/$contextFile"
        exit 0
        ;;


      # --------------------------------------------------------------------------------------------------------------------------------
      -) # start sub execution process
        execution=true
        startArgs=(${args[@]})
        [[ $storeArgs = true        ]] && echo "${args[@]}" > "$home/context/$contextFile"
        [[ $storeDefaultArgs = true ]] && echo "${args[@]}" > "$home/context/default"

        local mode="none"
        local app=
        local cmd=

        while [[ $# -gt 0 ]]; do
          case $1 in
            set)
              if [[ $mode = "new" ]]; then
                mode="set"
                shift
              fi
              ;;
            unset)
              if [[ $mode = "new" ]]; then
                mode="unset"
                shift
              fi
              ;;
            reset)
              if [[ $mode = "new" ]]; then
                args=(${startArgs[@]})
                mode="set"
                shift
              fi
              ;;
            clear)
              if [[ $mode = "new" ]]; then
                args=()
                mode="set"
                shift
              fi
              ;;
            -)
                mode="new"
                shift
              ;;
            --)
                mode="renew"
                shift
              ;;
            *)



              while [[ $# -gt 0 ]]; do
                case $1 in
                  -|--)
                    break
                    ;;
                  *)

                    if [[ $mode = "set" ]]; then # add argument
                      args=($(peArgsAddPair "$1" "$2" ${args[@]}))
                      [[ $(peArgsIsPairKeyValue "$1" "$2") = "true" ]] && shift
                      shift

                    elif [[ $mode = "unset" ]]; then # remove variable key
                      args=($(peArgsRemoveKey "$1" ${args[@]}))
                      shift

                    elif [[ $mode = "new" ]]; then # start new command
                      app="$1"
                      mode="cmd"
                      cmd=
                      shift

                    elif [[ $mode = "renew" ]]; then # start new execution of last command
                      mode="cmd"
                      cmd=

                    elif [[ $mode = "cmd" ]]; then # add to cmd
                      local value="$1"
                      [[ "$value" =~ " " ]] && value="\"$value\""
                      [[ ! -z $cmd ]] && cmd="$cmd $value"
                      [[ -z $cmd   ]] && cmd="$value"
                      shift
                    fi
                    ;;

                esac
              done

              [[ $mode = "cmd" ]] && [[ $verbose = true ]] && echo "CMD: $app $(peArgsUnwrap ${args[@]}) $cmd"
              ! eval "$app $(peArgsUnwrap ${args[@]}) $cmd" && exit 1



          esac
        done
        exit 0
        ;;
        # --------------------------------------------------------------------------------------------------------------------------------


      *)
        # add argument
        if [[ $setArgsEnabled = true ]]; then
          args=($(peArgsAddPair "$1" "$2" ${args[@]}))
          [[ $(peArgsIsPairKeyValue "$1" "$2") = "true" ]] && shift

        # remove argument
        else
          args=($(peArgsRemoveKey "$1" ${args[@]}))

        fi

        shift
        ;;

    esac
  done

#  echo " ${args[@]}"
  [[ $execution = false ]] && peArgsUnwrap ${args[@]}
  [[ $execution = false ]] && [[ $storeArgs = true        ]] && echo "${args[@]}" > "$home/context/$contextFile"
  [[ $execution = false ]] && [[ $storeDefaultArgs = true ]] && echo "${args[@]}" > "$home/context/default"

}