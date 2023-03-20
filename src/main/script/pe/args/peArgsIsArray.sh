function peArgsIsArray {
  [[ "$1" =~ ^\[.*] ]] && echo true || echo false
}