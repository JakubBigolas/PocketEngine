
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