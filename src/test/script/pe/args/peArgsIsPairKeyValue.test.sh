__peArgsIsPairKeyValueLabel="# TEST peArgsIsPairKeyValue"

__testHeader="$__peArgsIsPairKeyValueLabel : Only key"
__testExpect="false"
__testActual="$(peArgsIsPairKeyValue "-e" "")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Key and empty string"
__testExpect="false"
__testActual="$(peArgsIsPairKeyValue "-e" "")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Key and -"
__testExpect="false"
__testActual="$(peArgsIsPairKeyValue "-e" "")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Key is array"
__testExpect="false"
__testActual="$(peArgsIsPairKeyValue "[v]" "value")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Key has equals sign"
__testExpect="false"
__testActual="$(peArgsIsPairKeyValue "-e=v" "value")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Value is array"
__testExpect="false"
__testActual="$(peArgsIsPairKeyValue "-e" "[value]")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Key and value pair"
__testExpect="true"
__testActual="$(peArgsIsPairKeyValue "-e" "value")"
__testExecution

__testHeader="$__peArgsIsPairKeyValueLabel : Key looks like value with value"
__testExpect="true"
__testActual="$(peArgsIsPairKeyValue "e" "value")"
__testExecution