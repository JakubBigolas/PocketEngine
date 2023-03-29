function main {
  local home=$1
  shift



  # variables available in whole process ---------------------------------------------

  # arguments cache
  local args=()

  # static argument cache created from regular cache just before first execution
  local startArgs=()

  # enable setting arguments mode
  local setArgsEnabled=true

  # if true then arguments will be stored just before first execution
  local storeArgs=false

  # if true then arguments will bo stored as default, just before first execution
  local storeDefaultArgs=false

  # this flag is set to true just before first execution (false if there is nothing to execute)
  local execution=false

  # if true then every command will be printed before evaluation
  local verbose=false

  # argument contest store file name, default "context"
  local contextFile="context"

  # development mode enforces verbose mode and disable command evaluation
  local devMode=false





  # setting up filesystem ------------------------------------------------------------
  # script may require directories for storing args and command chains

  # ensure there context directory structure exists
  peSetUpContextDris

  # read default variables first
  [[ -f "$PE_CONTEXT_PATH/context/default" ]] && eval "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/default" "${args[@]}"))"




  # main loop per every argument -----------------------------------------------------
  while [[ $# -gt 0 ]]; do
    case $1 in

      # print help page
      help)
        peOptionHelp
        exit 0
        ;;

      # print version info
      version)
        peOptionVersion
        exit 0
        ;;

      # enable development mode, every command will be printed but not executed
      # useful for debug
      dev-mode)
        devMode=true
        verbose=true
        shift
        ;;

      # print every command before execution
      verbose)
        verbose=true
        shift
        ;;

      # simple list of stored contexts by filename
      contexts)
        ls "$PE_CONTEXT_PATH/context"
        exit 0
        ;;

      # list of contexts with caption (filtered)
      context-list|context-list/*)
        peOptionContextList "$1"
        ;;

      # read all stored variables from 'context'
      context)
        eval "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/context" "${args[@]}"))"
        shift
        ;;

      # read all stored variables from specific context
      context/*|c/*)
        contextFile=${1/"context/"/}
        contextFile=${contextFile/"c/"/}
        [[ -z $contextFile ]] && contextFile="context"
        eval "args=($(peArgsRestore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"))"
        shift
        ;;

      # remove stored context file
      context-rm/*)
        contextFile=${1/"context-rm/"/}
        [[ -f "$PE_CONTEXT_PATH/context/$contextFile" ]] && rm "$PE_CONTEXT_PATH/context/$contextFile"
        exit 0
        ;;

      # set store args flat to true (store all variables in file)
      store)
        storeArgs=true
        shift
        ;;

      # store all set variables in specific context (set store args flat to true)
      store/*|s/*)
        storeArgs=true
        contextFile=${1/"store/"/}
        contextFile=${contextFile/"s/"/}
        [[ -z $contextFile ]] && contextFile="context"
        shift
        ;;

      # flag store all set variables as default set to true
      default)
        storeDefaultArgs=true
        shift
        ;;

      # print stored executions (all/filtered)
      exec-list|exec-list/*)
        peOptionExecList "$1"
        exit 0
        ;;

      # simple list of stored executions
      execs)
        ls "$PE_CONTEXT_PATH/execs"
        exit 0
        ;;

      # remove stored context file
      exec-rm/*)
        contextFile=${1/"exec-rm/"/}
        [[ -f "$PE_CONTEXT_PATH/execs/$contextFile" ]] && rm "$PE_CONTEXT_PATH/execs/$contextFile"
        exit 0
      ;;

      # set flag remove arg key/value to true (only one after unset)
      unset)
        setArgsEnabled=false
        shift
        ;;

      # set flag add arg key/value to true (only one after unset)
      set)
        setArgsEnabled=true
        shift
        ;;

      # unset all args from cache
      clear)
        args=()
        shift
        ;;

      # unset remove default and unnamed stored variables set and exit
      cleanup)
        [[ -f "$PE_CONTEXT_PATH/context/context" ]] && rm "$PE_CONTEXT_PATH/context/context"
        [[ -f "$PE_CONTEXT_PATH/context/default" ]] && rm "$PE_CONTEXT_PATH/context/default"
        exit 0
        ;;

      # print path to stored configs directory
      context-path)
        echo "$PE_CONTEXT_PATH"
        exit 0
        ;;


      # --------------------------------------------------------------------------------------------------------------------------------
      -) # start sub execution process

        # set flag indicates that execution has been started
        execution=true

        # save args cache before start doing anything, user may return this state using reset command
        startArgs=("${args[@]}")

        # perform argument storing if requested before executions
        [[ $storeArgs = true        ]] && peArgsStore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"
        [[ $storeDefaultArgs = true ]] && peArgsStore "$PE_CONTEXT_PATH/context/default" "${args[@]}"

        # execution mode (new, renew, set, unset, reset, choose, clear, save-as, run)
        local mode="none"

        # first element of command chain
        # will be print very pure, won`t be wrapped or converted
        # args from cache will be placed after app element
        local app=

        # rest of command chain
        # will be wrapped and parametrized
        local cmd=


        # loop starting sequention of command chain building
        while [[ $# -gt 0 ]]; do
          case $1 in

            # switch mode new -> set
            set)    [[ $mode = "new" ]] && mode="set"    &&                             shift ;;

            # switch mode new -> unset
            unset)  [[ $mode = "new" ]] && mode="unset"  &&                             shift ;;

            # switch mode new -> set and restart args to start value
            reset)  [[ $mode = "new" ]] && mode="set"    && args=("${startArgs[@]}") && shift ;;

            # switch mode new -> choose and clear args
            choose) [[ $mode = "new" ]] && mode="choose" && args=()                  && shift ;;

            # switch mode new -> set and clear args
            clear)  [[ $mode = "new" ]] && mode="set"    && args=()                  && shift ;;

            # run selected saved exec config command chain
            run)    [[ $mode = "new" ]] && mode="run"                                && shift ;;

            # save rest of commands chain to exec config and exit
            save-as)
              if [[ $mode = "new" ]]; then
                local exec="$2"
                shift ; shift ; shift
                [[ -f "$PE_CONTEXT_PATH/execs/$exec" ]] && rm "$PE_CONTEXT_PATH/execs/$exec"
                for arg in "$@" ; do echo "$arg" >> "$PE_CONTEXT_PATH/execs/$exec" ; done
                exit 0
              fi
              ;;

            # switch any mode -> new
            -)    mode="new"   ; shift ;;
            # switch any mode -> renew
            --)   mode="renew" ; shift ;;

            # building command chain util "-" or "--" not appears ---------------------------------------------
            *)
              while [[ $# -gt 0 ]]; do
                case $1 in

                  # break current command chain building, return to parent loop starting new command chain building
                  -|--)
                    break
                    ;;


                  # command chan building
                  *)

                    # SET mode
                    # parametrize two arguments and add them argument to cache
                    if [[ $mode = "set" ]]; then

                      ! key=$(peArgsReplace   "$1" "${args[@]}" "${startArgs[@]}") && echo "$key" && exit 1
                      ! value=$(peArgsReplace "$2" "${args[@]}" "${startArgs[@]}") && echo "$value" && exit 1

                      eval "args=($(peArgsAddPair "$key" "$value" "${args[@]}"))"
                      [[ $(peArgsIsPairKeyValue "$1" "$2") = "true" ]] && shift
                      shift

                    # UNSET mode
                    # remove argument from cache by key
                    elif [[ $mode = "unset" ]]; then
                      eval "args=($(peArgsRemoveKey "$1" "${args[@]}"))"
                      shift

                    # CHOOSE mode
                    # add to cache arguments selected from beginning argument set created before execution
                    elif [[ $mode = "choose" ]]; then
                      local chosen=()
                      eval "chosen=($(peArgsChooseKey "$1" "${startArgs[@]}"))"
                      args=("${args[@]}" "${chosen[@]}")
                      shift

                    # NEW mode
                    # save arg as command name and switch mode to CMD
                    elif [[ $mode = "new" ]]; then
                      app=$1
                      mode="cmd"
                      cmd=
                      shift

                    # RENEW mode
                    # clear command chang except for command name and switch mode to CMD
                    elif [[ $mode = "renew" ]]; then
                      mode="cmd"
                      cmd=

                    # CMD mode
                    # wrap argument to be sure that every char will be treated as regular, parametrize it and add to command chain
                    elif [[ $mode = "cmd" ]]; then
                      local value=$1
                      value=$(peArgsWrap "$1")
                      ! value=$(peArgsReplace "$value" "${args[@]}" "${startArgs[@]}") && echo "$value" && exit 1
                      [[ -n $cmd ]] && cmd="$cmd $value" || cmd="$value"
                      shift

                    # RUN mode
                    # run stored command by name
                    elif [[ $mode = "run" ]]; then
                      peOptionRun "$1" "$verbose" "$devMode" "${args[@]}"
                      shift

                    fi
                    ;;

                esac
              done

              # after command chain building and before start new command chain build -----------------------------------------------

              # double wrap argument to be sure that every char will be treated as regular and every argument will be passed (even empty string)
              local packagedArgs=()
              eval "packagedArgs=($(peArgsWrap $(peArgsWrap "${args[@]}")))"

              # prepare command
              local command="$app $(peArgsUnwrap "${packagedArgs[@]}") $cmd"

              # print command for verbose or dev-mode
              [[ $mode = "cmd" ]] && [[ $verbose = true ]] && echo "CMD: $command"

              # execute command if not dev-mode
              [[ $devMode = false ]] && [[ $mode = "cmd" ]] && ! eval "$command" && exit 1

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

  # if there were no execution but there is still need to do something
  if [[ $execution = false ]]; then

    # print args to output
    peArgsUnwrap "${args[@]}"

    # store args
    [[ $storeArgs = true        ]] && peArgsStore "$PE_CONTEXT_PATH/context/$contextFile" "${args[@]}"
    [[ $storeDefaultArgs = true ]] && peArgsStore "$PE_CONTEXT_PATH/context/default" "${args[@]}"

  fi

}