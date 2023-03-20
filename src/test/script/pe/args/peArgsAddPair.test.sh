__peArgsAddPairLabel="# TEST peArgsAddPair"

__testHeader="$__peArgsAddPairLabel : Add key to nothing"
__testExpect=" -e [#]"
__testActual="$(peArgsAddPair "-e" "")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add key=value to nothing"
__testExpect=" -e=r34 [#]"
__testActual="$(peArgsAddPair "-e=r34" "")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add key to key"
__testExpect=" -d value -e [#]"
__testActual="$(peArgsAddPair "-e" "" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add key value to key value"
__testExpect=" -d value -e value2"
__testActual="$(peArgsAddPair "-e" "value2" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Replace key value"
__testExpect=" -d value2"
__testActual="$(peArgsAddPair "-d" "value2" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add key and array pair"
__testExpect=" -d value -e [#]"
__testActual="$(peArgsAddPair "-e" "[]" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add key and array pair with value"
__testExpect=" -d value -e [#]"
__testActual="$(peArgsAddPair "-e" "[111]" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add array with values and key pair"
__testExpect=" -d value 123 [#] 432 [#]"
__testActual="$(peArgsAddPair "[123,432]" "-e" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add key=value and value"
__testExpect=" -d value -e=321 [#]"
__testActual="$(peArgsAddPair "-e=321" "123" "-d" "value")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Replace key=value with another key=value"
__testExpect=" -d value -e=2 [#]"
__testActual="$(peArgsAddPair "-e=2" "" "-d" "value" "-e=1" "[#]")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Replace key=value with key value"
__testExpect=" -d value -e val"
__testActual="$(peArgsAddPair "-e" "val" "-d" "value" "-e=1" "[#]")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Replace key value with key=value"
__testExpect=" -d value -e=2 [#]"
__testActual="$(peArgsAddPair "-e=2" "" "-d" "value" "-e" "toReplace")"
__testExecution

__testHeader="$__peArgsAddPairLabel : Add value with \"\""
__testExpect=" -d value -e \"\""
__testActual="$(peArgsAddPair "-e" "\"\"" "-d" "value" )"
__testExecution

__testHeader="$__peArgsAddPairLabel : Replace multiple values using array"
__testExpect=" -e=333 [#] -p [#] -f=444 [#]"
__testActual="$(peArgsAddPair "[-e=333,-p]" "" "-e" "123" "-p" "1" "-f=444" "[#]" )"
__testExecution