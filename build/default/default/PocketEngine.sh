
# libs/main/script/std/arrays/stdArraysUnique.sh

function stdArraysUnique {
  local array=($@)
  local uniqueArray=()

  for item in ${array[@]}
  do

    local found=false

    for unique in ${uniqueArray[@]}
    do
      [[ "$unique" = "$item" ]] && found=true && break
    done

    [[ $found = false ]] && echo $item

    uniqueArray=(${uniqueArray[@]} $item)

  done

}

# libs/main/script/std/stdColors.sh

# Reset
C_RESET='\033[0m'       # Text Reset

# Regular Colors
C_BLACK='\033[0;30m'        # Black
C_RED='\033[0;31m'          # Red
C_GREEN='\033[0;32m'        # Green
C_YELLOW='\033[0;33m'       # Yellow
C_BLUE='\033[0;34m'         # Blue
C_PURPLE='\033[0;35m'       # Purple
C_CYAN='\033[0;36m'         # Cyan
C_WHITE='\033[0;37m'        # White

# Bold
C_B_BLACK='\033[1;30m'       # Black
C_B_RED='\033[1;31m'         # Red
C_B_GREEN='\033[1;32m'       # Green
C_B_YELLOW='\033[1;33m'      # Yellow
C_B_BLUE='\033[1;34m'        # Blue
C_B_PURPLE='\033[1;35m'      # Purple
C_B_CYAN='\033[1;36m'        # Cyan
C_B_WHITE='\033[1;37m'       # White

# Underline
C_U_BLACK='\033[4;30m'       # Black
C_U_RED='\033[4;31m'         # Red
C_U_GREEN='\033[4;32m'       # Green
C_U_YELLOW='\033[4;33m'      # Yellow
C_U_BLUE='\033[4;34m'        # Blue
C_U_PURPLE='\033[4;35m'      # Purple
C_U_CYAN='\033[4;36m'        # Cyan
C_U_WHITE='\033[4;37m'       # White

# Background
C_BG_BLACK='\033[40m'       # Black
C_BG_RED='\033[41m'         # Red
C_BG_GREEN='\033[42m'       # Green
C_BG_YELLOW='\033[43m'      # Yellow
C_BG_BLUE='\033[44m'        # Blue
C_BG_PURPLE='\033[45m'      # Purple
C_BG_CYAN='\033[46m'        # Cyan
C_BG_WHITE='\033[47m'       # White

# High Intensity
C_I_BLACK='\033[0;90m'       # Black
C_I_RED='\033[0;91m'         # Red
C_I_GREEN='\033[0;92m'       # Green
C_I_YELLOW='\033[0;93m'      # Yellow
C_I_BLUE='\033[0;94m'        # Blue
C_I_PURPLE='\033[0;95m'      # Purple
C_I_CYAN='\033[0;96m'        # Cyan
C_I_WHITE='\033[0;97m'       # White

# Bold High Intensity
C_BI_BLACK='\033[1;90m'      # Black
C_BI_RED='\033[1;91m'        # Red
C_BI_GREEN='\033[1;92m'      # Green
C_BI_YELLOW='\033[1;93m'     # Yellow
C_BI_BLUE='\033[1;94m'       # Blue
C_BI_PURPLE='\033[1;95m'     # Purple
C_BI_CYAN='\033[1;96m'       # Cyan
C_BI_WHITE='\033[1;97m'      # White

# High Intensity backgrounds
C_BGI_BLACK='\033[0;100m'   # Black
C_BGI_RED='\033[0;101m'     # Red
C_BGI_GREEN='\033[0;102m'   # Green
C_BGI_YELLOW='\033[0;103m'  # Yellow
C_BGI_BLUE='\033[0;104m'    # Blue
C_BGI_PURPLE='\033[0;105m'  # Purple
C_BGI_CYAN='\033[0;106m'    # Cyan
C_BGI_WHITE='\033[0;107m'   # White

# src/main/script/pe/args/peArgsAddPair.sh

function peArgsAddPair {
    local newArgs=()
    local argKey="$1"
    local argValue="$2"
    shift
    shift

    # if there is no value then set empty replacement as arg value
    [[ $(peArgsIsPairKeyValue "$argKey" "$argValue") = false ]] && argValue="[#]"

    local key=
    local value=
    local type="key"
    local isNew=true

    for it in "$@"
    do

      # for key remember and switch to value
      if [[ $type = "key" ]]; then
        key="$it"
        type="value"

      # for value do checks and switch to key
      elif [[ $type = "value" ]]; then
        value="$it"
        type="key"

        # if keys are the same replace value with arg value
        if [[ "$key" = "$argKey" ]]; then
          value="$argValue"
          isNew=false

        else

          # if keys without value after '=' are the same then replace key and value with args
          local keyWithoutValue="${key/=*/}"
          local argKeyWithoutValue="${argKey/=*/}"
          if [[ "$keyWithoutValue" = "$argKeyWithoutValue" ]]; then
            key="$argKey"
            value="$argValue"
            isNew=false

            # if new key has sign '=' then replace value with empty replacement however
            [[ ! "$argKeyWithoutValue" = "$argKey" ]] && value="[#]"

          fi

        fi

        # return calculated pair key value
        peArgsWrap "$key"
        peArgsWrap "$value"
      fi

    done

    # if there were nothing to replace add new value
    [[ $isNew = true ]] && peArgsWrap "$argKey"
    [[ $isNew = true ]] && peArgsWrap "$argValue"

}

# src/main/script/pe/args/peArgsChooseKey.sh

function peArgsChooseKey {
    local newArgs=()
    local argKey="$1"
    shift

    local key=
    local value=
    local type="key"

    for it in "$@"
    do

      # for key remember and switch to value
      if [[ $type = "key" ]]; then
        key="$it"
        type="value"

      # for value do checks and switch to key
      elif [[ $type = "value" ]]; then
        value="$it"
        type="key"

        local keyWithoutValue="${key/=*/}"

        # not left if keys are the same with or without '='
        if [[ "$key" == "$argKey" ]] || [[ "$keyWithoutValue" = "$argKey" ]]; then
          peArgsWrap "$key"
          peArgsWrap "$value"
          break
        fi

      fi

    done

}

# src/main/script/pe/args/peArgsIsPairKeyValue.sh

function peArgsIsPairKeyValue {

  # if second value starts with minus it is KEY itself or it starts command execution and cannot be paired
  if   [[ "$2" =~ ^- ]]       ; then echo false ;

  # if first value is internal key then everything after it is value
  elif [[ "$1" =~ ^\[#.+]$ ]] ; then echo true ;

  # if first value contains equal sign it is KEY=VALUE argument or it is too complex to be KEY VALUE pair
  elif [[ "$1" =~ = ]]        ; then echo false ;

  # if second value is internal key then it cannot be value
  elif [[ "$2" =~ ^\[#.+]$ ]] ; then echo false ;

  # if there is no objection they are married
  else echo true ; fi

}

# src/main/script/pe/args/peArgsRemoveKey.sh

function peArgsRemoveKey {
    local newArgs=()
    local argKey="$1"
    shift

    local key=
    local value=
    local type="key"

    for it in "$@"
    do

      # for key remember and switch to value
      if [[ $type = "key" ]]; then
        key="$it"
        type="value"

      # for value do checks and switch to key
      elif [[ $type = "value" ]]; then
        value="$it"
        type="key"

        local keyWithoutValue="${key/=*/}"

        # not left if keys are the same with or without '='
        if [[ ! "$key" == "$argKey" ]] && [[ ! "$keyWithoutValue" == "$argKey" ]]; then
          peArgsWrap "$key"
          peArgsWrap "$value"
        fi

      fi

    done

}

# src/main/script/pe/args/peArgsReplace.sh

function peArgsReplace {
  local input="$1"
  shift
  local result=""


  while : ; do

#    echo "----------------------------------"

    # find everything before expression
    local before="${input/"<<#"*/}"

    # add it to result
    result="$result$before"

    # remove it from input
    input="${input/"$before"/}"

    # find expression
    local expr=${input/"#>>"*/}
    expr=${expr/"<<#"/}
#    echo "EXPR: $expr"
    local originalExpr="<<#$expr#>>"

    # find everything after expression
    local after=${input/"<<#$expr#>>"/}

    # left after in input
    input="$after"

    if [[ -n "$expr" ]]; then

      local isKeyExpression=false
      local isConditional=false
      local isRequired=false
      local isEmptyReplacement=false
      local isReplacement=false

      local exprWithoutEmptyReplacement=
      local emptyReplacement=

      local exprWithoutReplacement=
      local replacement=

      # check if expression returns key (not input)
      if [[ "$expr" =~ ^#.*#$ ]]; then
        isKeyExpression=true
        expr="<<$expr>>"
        expr=${expr/"#>>"/}
        expr=${expr/"<<#"/}
#        echo "KEY EXPR: $expr"
      fi

      # check if expression is conditional
      if [[ "$expr" =~ ^\?.* ]]; then
        isConditional=true
        expr="${expr/\?/}"
#        echo "CONDITIONAL"
      fi

      # check if expression is required
      if [[ "$expr" =~ ^\!.* ]]; then
        isRequired=true
        expr="${expr/\!/}"
#        echo "REQUIRED"
      fi

      # check if there is empty replacement
      if [[ "$expr" =~ .*:\?.* ]]; then

        # empty replacement cannot be combined with conditinal or required expression
        if [[ $isConditional = true ]] || [[ $isRequired = true ]]; then
          echo "ERROR: Empty replacement is not available for conditional/required expression ($originalExpr)"
          exit 1
        fi

        isEmptyReplacement=true
        exprWithoutEmptyReplacement=${expr/:\?*/}
        emptyReplacement=${expr/"$exprWithoutEmptyReplacement:?"/}
#        echo "OR ELSE: $emptyReplacement"

      fi

      # check if there is key replacement
      if [[ "$expr" =~ .*\|.* ]]; then

        # key replacement may be only combined with key expression
        [[ $isKeyExpression = false ]]    && echo "ERROR: Replacement is not available for value expression ($originalExpr)" && exit 1

        # key replacement cannot be combined with empty replacement expression
        [[ $isEmptyReplacement = true ]]  && echo "ERROR: Replacement cannot be combined with empty replacement expression ($originalExpr)" && exit 1

        isReplacement=true
        exprWithoutReplacement=${expr/\|*/}
        replacement=${expr/"$exprWithoutReplacement|"/}
#        echo "REPLACEMENT: $replacement"

      fi

      [[ $isEmptyReplacement = true ]] && expr="$exprWithoutEmptyReplacement"
      [[ $isReplacement = true ]]      && expr="$exprWithoutReplacement"

      local keyValuePair=
      eval "keyValuePair=($(peArgsChooseKey "$expr" "$@"))"

      local key="${keyValuePair[0]}"
      local value="${keyValuePair[1]}"
      [[ $value = "[#]" ]] && value=

#      echo "KEY  : $key"
#      echo "VALUE: $value"

      # if it is key expression
      if [[ $isKeyExpression = true ]]; then
        # and key is empty
        if [[ -z "$key" ]]; then
          # if is not conditional
          if [[ $isConditional = false ]] ; then
            # and is required - throw an error
            [[ $isRequired = true ]] && echo "ERROR: Required expression: key not found ($originalExpr)" && exit 1
            # or has empty replacement - replace it
            [[ $isEmptyReplacement = true ]] && key="$emptyReplacement"
            # or is not conditional and has replacement = replace it
            [[ $isReplacement = true ]] && key="$replacement"
          fi
        else
          [[ $isReplacement = true ]] && key="$replacement"
        fi
        # add key to expression
        result="$result$key"

      # if it is value expression
      else
        # and value is empty
        if [[ -z "$value" ]]; then
          # if is not conditional
          if [[ $isConditional = false ]] ; then
            # and is required - throw an error
            [[ $isRequired = true ]] && echo "ERROR: Required expression: value not found ($originalExpr)" && exit 1
            # or has empty replacement - replace it
            [[ $isEmptyReplacement = true ]] && value="$emptyReplacement"
          fi
        fi
        # add value to expression
        result="$result$value"

      fi

    fi

    # finish loop if input is empty
    [[ -z "$input" ]]  && break;

  done

  # <<#?key#>>                      return value for key, if there is no value then ommit
  # <<#key#>>                       return value for key, if there is no value then return empty string
  # <<#key:?orElse#>>               return value for key, if there is no value then return "orElse"
  # <<#!key#>>                      return value for key, if there is no value then finish with error

  # <<##?key##>>                    return key, if there is no key then ommmit
  # <<##key##>>                     return key, if there is no key then return empty string
  # <<##key?:orElse##>>             return key, if there is no key then return "orElse"
  # <<##!key##>>                    return key, if there is no key then finish with error
  # <<##...key|replacement##>>      return replacement if there is a key

  echo "$result"
}

# src/main/script/pe/args/peArgsRestore.sh

function peArgsRestore {
  local contextFile=$1
  shift
  local args=("$@")
  local contextArgs=()

  # read raw args file
  [[ -f "$contextFile" ]] && readarray -t contextArgs < "$contextFile"

  local type="key"
  for it in "${contextArgs[@]}"
  do
    if [[ $type = "key" ]]; then
      key="$it"
      type="value"
    elif [[ $type = "value" ]]; then
      value="$it"
      type="key"

      # evaluate in array-safe way
      eval "args=($(peArgsAddPair "$key" "$value" "${args[@]}"))"

    fi
  done

  # return in array-safe way
  for arg in "${args[@]}" ; do peArgsWrap "$arg" ; done

}

# src/main/script/pe/args/peArgsStore.sh

function peArgsStore {
  local path="$1"
  shift

  # delete old version
  if [[ -f "$path" ]]; then
    rm "$path"
  fi

  # print new version
  for arg in "$@"
  do
    printf "%s\n" "${arg//$'\n'/\n}" >> "$path"
  done

}

# src/main/script/pe/args/peArgsUnwrap.sh

function peArgsUnwrap {
  local args=()

  for arg in "$@"
  do # remove internal args
    [[ ! "$arg" =~ ^\[#.*\]$ ]] && [[ ! "$arg" =~ ^\"\[#.*\]\"$ ]] && args=("${args[@]}" "$arg")
  done

  local unwrap=" ${args[*]}"
  local unwrap=${unwrap//\\\`/\`} # \` -> `
  local unwrap=${unwrap//\\\$/\$} # \$ -> $
  echo " $unwrap"
}

# src/main/script/pe/args/peArgsWrap.sh


# wrap each argument replacing each each sensitive char with escape

function peArgsWrap {

  # for each argument
  while [[ $# -gt 0 ]]; do

    local arg="$1"
    shift
    arg="${arg//"\\"/\\\\}"  # replace \ -> \\
    arg="${arg//\"/\\\"}"    # replace " -> \"
    arg="${arg//\`/\\\`}"    # replace ` -> \`
    arg="${arg//\$/\\\$}"    # replace $ -> \$

    if [[ "$1" == *$'\n'* ]]; then

      printf "\""

      while [[ "$1" == *$'\n'* ]]
      do
        local subSequence="${arg/\\\\n*/}"
        arg=${arg/"$subSequence"/}
        arg=${arg/\\\\n/}
        echo "$subSequence"
      done

      echo "$arg\""

    else
      echo "\"$arg\""
    fi

  done


}

# src/main/script/pe/option/peOptionContextList.sh

function peOptionContextList {

  # search expression from arg
  local search=${1/context-list/}
  local search=${search/\//}

  # array of files in $PE_CONTEXT_PATH/context
  local contextFiles=
  mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/context")

  for file in "${contextFiles[@]}"
  do

    # print if nothing to search or context file name like search expression
    if [[ -z "$search" ]] || [[ "$file" =~ $search ]]; then
      echo -e "${C_GREEN}Context: ${C_WHITE}$file${C_RESET}"

      # read raw args file
      readarray -t contextArgs < "$PE_CONTEXT_PATH/context/$file"

      echo
      local type="key"
      for it in "${contextArgs[@]}"
      do
        if [[ $type = "key" ]]; then
          key="$it"
          type="value"
        elif [[ $type = "value" ]]; then
          value="$it"
          [[ "$value" = "[#]" ]] && value=
          type="key"

          # print in pretty format
          printf "${C_YELLOW}   KEY  ${C_RESET}: %s"  "$key"
          echo
          printf "${C_YELLOW}   VALUE${C_RESET}: %s" "$value"
          echo
          echo

        fi
      done

    fi
  done

  exit 0

}

# src/main/script/pe/option/peOptionExecList.sh

function peOptionExecList {

  # search expression from argument
  local search=${1/exec-list/}
  local search=${search/\//}

  # array of files from "$PE_CONTEXT_PATH/execs"
  local contextFiles=
  mapfile -t contextFiles < <(ls "$PE_CONTEXT_PATH/execs")

  for file in "${contextFiles[@]}"
  do
    if [[ -z "$search" ]] || [[ "$file" =~ $search ]]; then
      echo -e "${C_GREEN}Context: ${C_WHITE}$file${C_RESET}"

      # read raw args file
      readarray -t contextArgs < "$PE_CONTEXT_PATH/execs/$file"

      echo
      printf "${C_WHITE} >"
      local format="${C_I_BLUE}"
      # print in pretty format
      for it in "${contextArgs[@]}"
      do

          [[ "$it" = "-"    ]] && echo && printf "${C_WHITE} >"  && format="${C_I_BLUE}"
          [[ "$it" = "--"   ]] && echo && printf "${C_WHITE} >>"
          [[ ! "$it" = "-"  ]] && [[ ! "$it" = "--" ]] && printf "${format} %s" "$it" && format="${C_RESET}"

      done
      echo
      echo

    fi
  done
  exit 0

}

# src/main/script/pe/option/peOptionHelp.sh

function peOptionHelp {
  echo -e ""
  echo -e "Usage: pe [options...] [arguments...] - [commands...] -- [repeat last command with another args/options]"
  echo -e ""
  echo -e "Main PocketEngine (\"pe\") purpose is to store and invoke multiple commands with configured arguments context as simple as it can be."
  echo -e ""
  echo -e "Options:"
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'set'              'enable setting arguments cache sequention (enabled by default)'
  pdToolHelpOptionPrint 'unset'            'start removing arguments cache sequention'
  pdToolHelpOptionPrint 'clear'            'remove all arguments from cache'
  pdToolHelpOptionPrint 'verbose'          'print each execution command before run'
  pdToolHelpOptionPrint 'context-path'     'return path to store directory'
  pdToolHelpOptionPrint 'help'             'print this help info and exit'
  pdToolHelpOptionPrint 'version'          'print version info and exit'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '----------------' 'Arguments context management:'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'cleanup'          'remove unnamed and default context and exit'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'contexts'         'print simple list of all saved context names and exit'
  pdToolHelpOptionPrint 'context-list'     'print list of all saved contexts with arguments and exit'
  pdToolHelpOptionPrint 'context-list/*'   'print filtered list of saved contexts with arguments and exit'
  pdToolHelpOptionPrint 'context-rm/*  '   'remove named arguments context and exit'
  pdToolHelpOptionPrint 'context'          'load saved unnamed context arguments to cache'
  pdToolHelpOptionPrint 'context/*'        'load saved named context arguments to cache'
  pdToolHelpOptionPrint 'c/*'              'short version of context/*'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'default'          'save all arguments cache as default context  (it is performed just before first execution)'
  pdToolHelpOptionPrint ''                 'arguments stored in default context will be always loaded at the beginning'
  pdToolHelpOptionPrint 'store'            'save all arguments cache as unnamed context  (it is performed just before first execution)'
  pdToolHelpOptionPrint 'store/*'          'save all arguments cache as specific context (it is performed just before first execution)'
  pdToolHelpOptionPrint 's/*'              'short version of store/*'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '----------------' 'Executions management:'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'execs'            'print all stored execution names and exit'
  pdToolHelpOptionPrint 'exec-list'        'print all stored executions with caption and exit'
  pdToolHelpOptionPrint 'exec-list/*'      'print filtered stored executions with caption and exit'
  pdToolHelpOptionPrint 'exec-rm/*'        'remove named execution and exit'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '----------------' 'Execution chain:'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '-'                'start new command execution'
  pdToolHelpOptionPrint '--'               'start new execution with last command name'
  pdToolHelpOptionPrint '- set'            'allow to add new arguments to cache before next execution'
  pdToolHelpOptionPrint '- unset'          'allow to remove arguments from cache before next execution'
  pdToolHelpOptionPrint '- reset'          'restore arguments cache to state before start fist execution'
  pdToolHelpOptionPrint '- choose'         'choose needed arguments in cache by KEY, others will be removed'
  pdToolHelpOptionPrint '- clear'          'clear all arguments cache'
  pdToolHelpOptionPrint '- save-as *'      'save everything after this sequention as execution with specific name'
  pdToolHelpOptionPrint '- run *'          'load execution by name and execute with current arguments cache (verbose option is inherited)'
  echo -e ""
  echo -e "Arguments:"
  echo -e " To set arguments just type them as space separated KEY VALUE pairs or KEY=VALUE pair or just KEY."
  echo -e " If argument starts with character '-' it is always treated as KEY (even if there was key before)."
  echo -e " If KEY has character '=' then another argument will be treated as KEY too (even if it looks like value)."
  echo -e " If there is need to put KEY that will not be present in execution (like id for choosing params) then use pattern [#...]"
  echo -e " and everything after it will be VALUE (if it not starts with '-') even if another value is written same way."
  echo -e " If there is need to put something more complex put it in quotes."
  echo -e " NOTICE: if unset mode is enabled then everything is treated as key and if there is value associated with key it will be removed too."
  echo -e " Finally each KEY, VALUE or execution element (except first element) will be wrapped in quotes excluding internal KEYs"
  echo -e ""
  echo -e " Example possible combinations KEY VALUE set:"
  echo -e "  KEY"
  echo -e "  -KEY"
  echo -e "  -KEY VALUE"
  echo -e "  -KEY -KEY VALUE"
  echo -e "  -KEY VALUE KEY"
  echo -e "  -KEY=VALUE KEY"
  echo -e "  -KEY VALUE_LOOKS_LIKE_KEY=VALUE"
  echo -e "  KEY VALUE -KEY [#INTERNAL_KEY] #[VALUE_LOOKS_LIKE_KEY]"
  echo -e ""
  echo -e "Example use story: "
  echo -e ""
  echo -e "   $ pe - save-as buildAndRun - myCommand build -- -pDocker run"
  echo -e "   ${C_BLUE}# create new command named \"buildAndRun\" that runs commands: \"myCommand build\" and \"myCommand -pDocker run\"${C_RESET}"
  echo -e ""
  echo -e "   $ pe default -project MyApp"
  echo -e "   ${C_BLUE}# store arguments [-project MyApp] as default arguments loaded every time by default${C_RESET}"
  echo -e ""
  echo -e "   $ pe clear store store/env-dev -env dev"
  echo -e "   ${C_BLUE}# clear argument cache to be sure there is no defaults and store arguments [-env dev] as named context \"env-dev\"${C_RESET}"
  echo -e ""
  echo -e "   $ pe context/env-dev - run buildAndRun"
  echo -e "   ${C_BLUE}# run commands stored under name \"buildAndRun\" with default args and env-dev args, it will be converted to commands:${C_RESET}"
  echo -e "   ${C_BLUE}# $ \"myCommand\" \"-project\" \"MyApp\" \"-env\" \"dev\" \"build\"${C_RESET}"
  echo -e "   ${C_BLUE}# $ \"myCommand\" \"-project\" \"MyApp\" \"-env\" \"dev\" \"-pDoker\" \"run\"${C_RESET}"
  echo -e ""
  echo -e "   $ pe cleanup"
  echo -e "   ${C_BLUE}# if there is no need to keep default arguments remove them${C_RESET}"
}

# src/main/script/pe/option/peOptionRun.sh

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

# src/main/script/pe/option/peOptionVersion.sh

function peOptionVersion {
  echo "0.0.1.dev"
}

# src/main/script/pe/peSetUpContxtDirs.sh

function peSetUpContextDris {
    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && PE_CONTEXT_PATH="$home/context"

    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && mkdir "$PE_CONTEXT_PATH"
    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && mkdir "$PE_CONTEXT_PATH/context"
    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && mkdir "$PE_CONTEXT_PATH/execs"
}

# src/main/script/pe/tool/pdToolHelpOptionPrint.sh

function pdToolHelpOptionPrint {
   printf " ${C_BLUE}%-16s ${C_RESET}%s\n" "$1" "$2"
}

# /src/main/script/main.sh

function main {

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
