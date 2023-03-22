function peArgsIsPairKeyValue {
  # second value does not start with -
  # first value is not array
  # second value is not array
  # first value has no =
  # second value is not empty
     [[ ! "$2" =~ ^-.* ]] \
  && [[ ! "$1" =~ ^\[.*] ]] \
  && [[ ! "$2" =~ ^\[.*] ]] \
  && [[ ! "$1" =~ .*=.* ]] \
  && [[ ! "$2" =~ .*=.* ]] \
  && [[ ! "$2" = "" ]] \
  && echo true || echo false
}