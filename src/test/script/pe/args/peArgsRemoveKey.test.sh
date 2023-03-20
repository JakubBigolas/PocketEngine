__peArgsRemoveKeyLabel="# TEST peArgsRemoveKey"

__testHeader="$__peArgsRemoveKeyLabel : Unset nothing"
__testExpect=" -f 123"
__testActual="$(peArgsRemoveKey "-e" "-f" "123")"
__testExecution

__testHeader="$__peArgsRemoveKeyLabel : Unset only one"
__testExpect=" "
__testActual="$(peArgsRemoveKey "-e" "-e" "123")"
__testExecution

__testHeader="$__peArgsRemoveKeyLabel : Unset first"
__testExpect=" -f 321 -d 9999"
__testActual="$(peArgsRemoveKey "-e" "-e" "123" "-f" "321" "-d" "9999")"
__testExecution

__testHeader="$__peArgsRemoveKeyLabel : Unset middle"
__testExpect=" -e 123 -d 9999"
__testActual="$(peArgsRemoveKey "-f" "-e" "123" "-f" "321" "-d" "9999")"
__testExecution

__testHeader="$__peArgsRemoveKeyLabel : Unset last"
__testExpect=" -e 123 -f 321"
__testActual="$(peArgsRemoveKey "-d" "-e" "123" "-f" "321" "-d" "9999")"
__testExecution

__testHeader="$__peArgsRemoveKeyLabel : Unset multiple"
__testExpect=" -f 321"
__testActual="$(peArgsRemoveKey "[-e,-d,-g]" "-e" "123" "-f" "321" "-d" "9999")"
__testExecution