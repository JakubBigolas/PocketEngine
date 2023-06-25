function peArgsAddPair {
    local argKey="$1"   ; shift
    local argValue="$1" ; shift
    local target="$1"   ; shift

    local __return=()
    local __target=()

    # copy from source reference
    stdArraysCopy $target __target

    # if there is no value then set empty replacement as arg value
    [[ $(peArgsIsPairKeyValue "$argKey" "$argValue") = false ]] && argValue="[#]"

    # in result always return original and new values
    __return=("${__target[@]}" "$argKey" "$argValue")

    # copy by reference
    stdArraysCopy __return $target

}