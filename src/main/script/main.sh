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
  [[ -f "$PE_CONTEXT_PATH/context/default" ]] && eval "args=($(peOptionContext "$PE_CONTEXT_PATH/context/default" "${args[@]}"))"

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
        eval "args=($(peOptionContext "$PE_CONTEXT_PATH/context/context" "${args[@]}"))"
        shift
        ;;

      c-list) # read all available contexts
        ls "$PE_CONTEXT_PATH/context"
        exit 0
        ;;

      context-list) # read all available contexts
        local contextFiles=
        mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/context")
        for file in "${contextFiles[@]}"
        do
          echo -e "${C_GREEN}Context: ${C_WHITE}$file${C_RESET}"
          echo ""
          cat "$PE_CONTEXT_PATH/context/$file"
          echo ""
        done
        exit 0
        ;;

      context/*|c/*) # read all stored variables from specific context

        contextFile=${1/"context/"/}
        contextFile=${contextFile/"c/"/}
        [[ -z $contextFile ]] && contextFile="context"
        eval "args=($(peOptionContext "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"))"
        shift
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

      cleanup/*)# unset all stored variables values in specific context, it is executed immediately end interrupt further execution
        contextFile=${1/"cleanup/"/}
        [[ -z $contextFile ]] && contextFile="context"
        [[ -f "$PE_CONTEXT_PATH/context/$contextFile" ]] && rm "$PE_CONTEXT_PATH/context/$contextFile"
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
            clear)
              if [[ $mode = "new" ]]; then
                args=()
                mode="set"
                shift
              fi
              ;;
            save-as)
              shift
              local exec="$1"
              shift
              shift
              echo "$@" > "$PE_CONTEXT_PATH/execs/$exec"
              exit 0
              ;;
            run)
              shift
              local exec="$1"
              shift
              local execFile=
              local verboseCmd=
              [[ -f "$PE_CONTEXT_PATH/execs/$exec" ]] && readarray -t execFile < "$PE_CONTEXT_PATH/execs/$exec"
              [[ $verbose = true ]] && verboseCmd=" verbose" && echo "EXEC: pe$verboseCmd clear ${args[*]} - ${execFile[*]}"
              eval "pe$verboseCmd clear ${args[*]} - ${execFile[*]}"
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
                      [[ -n $cmd ]] && cmd="$cmd $value"
                      [[ -z $cmd   ]] && cmd="$value"
                      shift
                    fi
                    ;;

                esac
              done

              [[ $mode = "cmd" ]] && [[ $verbose = true ]] && echo "CMD: $app $(peArgsUnwrap "${args[@]}") $cmd"
              [[ $mode = "cmd" ]] && ! eval "$app $(peArgsUnwrap "${args[@]}") $cmd" && exit 1



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
#    echo "${args[*]/#/ARG:}"
    peArgsUnwrap " ${args[@]}"
    [[ $storeArgs = true        ]] && peArgsStore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"
    [[ $storeDefaultArgs = true ]] && peArgsStore "$PE_CONTEXT_PATH/context/default" "${args[@]}"
  fi

}