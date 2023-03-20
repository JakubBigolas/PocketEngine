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

  # read default variables first
  [[ -f "$home/config/default" ]] && args=($(peOptionContext "$home/config/default" ${args[@]}))
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
        args=($(peOptionContext "$home/config/context" ${args[@]}))
        shift
        ;;

      store) # store all set variables
        storeArgs=true
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
        [[ -f "$home/config/context" ]] && rm "$home/config/context"
        [[ -f "$home/config/default" ]] && rm "$home/config/default"
        exit 0
        ;;


      # --------------------------------------------------------------------------------------------------------------------------------
      -) # start sub execution process
        execution=true
        startArgs=(${args[@]})
        [[ $storeArgs = true        ]] && echo "${args[@]}" > "$home/config/context"
        [[ $storeDefaultArgs = true ]] && echo "${args[@]}" > "$home/config/default"

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
  [[ $execution = false ]] && [[ $storeArgs = true        ]] && echo "${args[@]}" > "$home/config/context"
  [[ $execution = false ]] && [[ $storeDefaultArgs = true ]] && echo "${args[@]}" > "$home/config/default"

}