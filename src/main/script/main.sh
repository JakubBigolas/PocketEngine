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

  [[ ! -d "$PE_CONTEXT_PATH/context" ]] && PE_CONTEXT_PATH="$home/context"

  # read default variables first
  [[ -f "$PE_CONTEXT_PATH/context/default" ]] && eval "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/default" "${args[@]}"))"

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

      contexts) # simple list of stored contexts
        ls "$PE_CONTEXT_PATH/context"
        exit 0
        ;;

      context-list|context-list/*) # list of contexts with caption (filtered)
        peOptionContextList "$1"
        ;;

      context) # read all stored variables from 'context'
        eval "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/context" "${args[@]}"))"
        shift
        ;;

      context/*|c/*) # read all stored variables from specific context
        contextFile=${1/"context/"/}
        contextFile=${contextFile/"c/"/}
        [[ -z $contextFile ]] && contextFile="context"
#        echo "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"))"
        eval "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"))"
        shift
        ;;

      context-rm/*) # remove stored context file
        contextFile=${1/"context-rm/"/}
        [[ -f "$PE_CONTEXT_PATH/context/$contextFile" ]] && rm "$PE_CONTEXT_PATH/context/$contextFile"
        exit 0
        ;;

      store) # store all set variables
        storeArgs=true
        shift
        ;;

      store/*|s/*) # store all set variables in specific context
        storeArgs=true
        contextFile=${1/"store/"/}
        contextFile=${contextFile/"s/"/}
        [[ -z $contextFile ]] && contextFile="context"
        shift
        ;;

      default) # store all set variables as default
        storeDefaultArgs=true
        shift
        ;;

      exec-list|exec-list/*)
        peOptionExecList "$1"
        exit 0
        ;;

      execs)
        ls "$PE_CONTEXT_PATH/execs"
        exit 0
        ;;

      exec-rm/*) # remove stored context file
        contextFile=${1/"exec-rm/"/}
        [[ -f "$PE_CONTEXT_PATH/execs/$contextFile" ]] && rm "$PE_CONTEXT_PATH/execs/$contextFile"
        exit 0
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
        [[ -f "$PE_CONTEXT_PATH/context/context" ]] && rm "$PE_CONTEXT_PATH/context/context"
        [[ -f "$PE_CONTEXT_PATH/context/default" ]] && rm "$PE_CONTEXT_PATH/context/default"
        exit 0
        ;;

      context-path)
        echo "$PE_CONTEXT_PATH"
        exit 0
        ;;


      # --------------------------------------------------------------------------------------------------------------------------------
      -) # start sub execution process
        execution=true
        startArgs=("${args[@]}")
        [[ $storeArgs = true        ]] && peArgsStore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"
        [[ $storeDefaultArgs = true ]] && peArgsStore "$PE_CONTEXT_PATH/context/default" "${args[@]}"

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
                args=("${startArgs[@]}")
                mode="set"
                shift
              fi
              ;;
            choose)
              if [[ $mode = "new" ]]; then
                args=()
                mode="choose"
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
            save-as)
              local exec="$2"
              shift
              shift
              shift
              [[ -f "$PE_CONTEXT_PATH/execs/$exec" ]] && rm "$PE_CONTEXT_PATH/execs/$exec"
              for arg in "$@" ; do echo "$arg" >> "$PE_CONTEXT_PATH/execs/$exec" ; done
              exit 0
              ;;
            run)
              peOptionRun "$2" "$verbose" "${args[@]}"
              shift
              shift
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
                      eval "args=($(peArgsAddPair "$1" "$2" "${args[@]}"))"
                      [[ $(peArgsIsPairKeyValue "$1" "$2") = "true" ]] && shift
                      shift

                    elif [[ $mode = "unset" ]]; then # remove variable key
                      eval "args=($(peArgsRemoveKey "$1" "${args[@]}"))"
                      shift

                    elif [[ $mode = "choose" ]]; then # remove variable key
                      local chosen=()
                      eval "chosen=($(peArgsChooseKey "$1" "${startArgs[@]}"))"
                      args=("${args[@]}" "${chosen[@]}")
                      shift

                    elif [[ $mode = "new" ]]; then # start new command
                      app=$1
#                      app="$(peArgsWrap "$1")"
                      mode="cmd"
                      cmd=
                      shift

                    elif [[ $mode = "renew" ]]; then # start new execution of last command
                      mode="cmd"
                      cmd=

                    elif [[ $mode = "cmd" ]]; then # add to cmd
                      local value=$1
                      value=$(peArgsWrap "$1")
                      [[ -n $cmd ]] && cmd="$cmd $value" || cmd="$value"
                      shift
                    fi
                    ;;

                esac
              done

              local packagedArgs=()
              eval "packagedArgs=($(peArgsWrap $(peArgsWrap "${args[@]}")))"
              local command="$app $(peArgsUnwrap "${packagedArgs[@]}") $cmd"
              [[ $mode = "cmd" ]] && [[ $verbose = true ]] && echo "CMD: $command"
              [[ $mode = "cmd" ]] && ! eval "$command" && exit 1

          esac
        done
        exit 0
        ;;
        # --------------------------------------------------------------------------------------------------------------------------------


      *)
        # add argument
        if [[ $setArgsEnabled = true ]]; then
          eval "args=($(peArgsAddPair "$1" "$2" "${args[@]}"))"
          [[ $(peArgsIsPairKeyValue "$1" "$2") = "true" ]] && shift
        # remove argument
        else
          eval "args=($(peArgsRemoveKey "$1" "${args[@]}"))"
        fi

        shift
        ;;

    esac
  done

  if [[ $execution = false ]]; then
#    for arg in "${args[@]}" ; do echo -e "ARG: ${C_BG_BLUE}$arg${C_RESET}" ; done
    peArgsUnwrap "${args[@]}"
    [[ $storeArgs = true        ]] && peArgsStore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"
    [[ $storeDefaultArgs = true ]] && peArgsStore "$PE_CONTEXT_PATH/context/default" "${args[@]}"
  fi

}