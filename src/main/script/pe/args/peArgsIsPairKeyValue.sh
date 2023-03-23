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