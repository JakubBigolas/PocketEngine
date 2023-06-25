function peSetUpContextDris {
    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && PE_CONTEXT_PATH="$home/context"

    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && mkdir "$PE_CONTEXT_PATH"
    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && mkdir "$PE_CONTEXT_PATH/context"
    [[ ! -d "$PE_CONTEXT_PATH/context" ]] && mkdir "$PE_CONTEXT_PATH/execs"
}