__peArgsIsArrayLabel="# TEST peArgsIsArray"

# Check if empty value is not array

__testHeader="$__peArgsIsArrayLabel : Check if empty value is not array"
__testExpect="false"
__testActual="$(peArgsIsArray "")"
__testExecution

# Check if value is not array

__testHeader="$__peArgsIsArrayLabel : Check if value is not array"
__testExpect="false"
__testActual="$(peArgsIsArray "value")"
__testExecution

# Check if value starts with [ is not array

__testHeader="$__peArgsIsArrayLabel : Check if value starts with [ is not array"
__testExpect="false"
__testActual="$(peArgsIsArray "[value")"
__testExecution

# Check if value ends with ] is not array

__testHeader="$__peArgsIsArrayLabel : Check if value ends with ] is not array"
__testExpect="false"
__testActual="$(peArgsIsArray "value]")"
__testExecution

# Check if value with [ and ] in wrong order is not array

__testHeader="$__peArgsIsArrayLabel : Check if value with [ and ] in wrong order is not array"
__testExpect="false"
__testActual="$(peArgsIsArray "v[alue]")"
__testExecution

# Check if empty value with [ and ] is array

__testHeader="$__peArgsIsArrayLabel : Check if empty value with [ and ] is array"
__testExpect="true"
__testActual="$(peArgsIsArray "[]")"
__testExecution

# Check if single value with [ and ] is array

__testHeader="$__peArgsIsArrayLabel : Check if single value with [ and ] is array"
__testExpect="true"
__testActual="$(peArgsIsArray "[value]")"
__testExecution

# Check if value list with [ and ] is array

__testHeader="$__peArgsIsArrayLabel : Check if value list with [ and ] is array"
__testExpect="true"
__testActual="$(peArgsIsArray "[v1,v2,v3]")"
__testExecution
