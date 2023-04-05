__testLabel="# TEST peArgsRemoveKey"

__testHeader="$__testLabel : Unset nothing"
__testExpect=" -f 123"
__testActual="$(peArgsRemoveKey "-e" "-f" "123")"
__testExecution



function peArgsWrap {
  while [[ $# -gt 0 ]]; do

    local arg="$1"
    shift
    arg="${arg//"\\"/\\\\}"  # \ -> \\
    arg="${arg//\"/\\\"}"    # " -> \"
    arg="${arg//\`/\\\`}"    # ` -> \`
    arg="${arg//\$/\\\$}"    # $ -> \$

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