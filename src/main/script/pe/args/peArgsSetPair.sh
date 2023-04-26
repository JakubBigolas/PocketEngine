function peArgsSetPair {
    local argKey="$1"   ; shift
    local argValue="$1" ; shift
    local target="$1"   ; shift

    local __return=()
    local __target=()

    # copy from source reference
    stdArraysCopy $target __target

    # remove key from copy
    local targetWithoutRemovedValues=("${__target[@]}")
    peArgsRemoveKey "$argKey" targetWithoutRemovedValues

    # if there is no value then set empty replacement as arg value
    [[ $(peArgsIsPairKeyValue "$argKey" "$argValue") = false ]] && argValue="[#]"

    # in result return original copy without previous keys and new value for this key
    __return=("${targetWithoutRemovedValues[@]}" "$argKey" "$argValue")

    # copy by reference
    stdArraysCopy __return $target

}