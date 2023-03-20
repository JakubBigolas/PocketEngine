__peArgsUnwrapLabel="# TEST peArgsUnwrap"

__testHeader="$__peArgsUnwrapLabel : Unwrap empty"
__testExpect=" "
__testActual="$(peArgsUnwrap "")"
__testExecution

__testHeader="$__peArgsUnwrapLabel : Unwrap without changing input"
__testExpect=" -e=99999 -p -f=444"
__testActual="$(peArgsUnwrap "-e=99999" "-p" "-f=444")"
__testExecution

__testHeader="$__peArgsUnwrapLabel : Unwrap with content changing"
__testExpect=" -e=99999 -p -f=444"
__testActual="$(peArgsUnwrap "-e=99999" "[#]" "-p" "[#]" "-f=444" "[#]")"
__testExecution