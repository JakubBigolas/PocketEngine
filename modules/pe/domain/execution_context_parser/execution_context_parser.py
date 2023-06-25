from copy import deepcopy

from modules.pe.domain.app                                                          import AppContext
from modules.pe.domain.execution_context                                            import ExecutionContext
from modules.pe.domain.execution_context_data                                       import ExecutionContextData
from modules.pe.domain.execution_context_parser.args.args_resolver                  import ArgsResolver


class ExecutionContextParser:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__resolver = ArgsResolver(app_context)



    def parse(self, args: list, verbose: bool, dev_mode: bool) -> ExecutionContext:
        executionContext = ExecutionContext(verbose, dev_mode)
        self.__read_args(executionContext.data, args)
        return executionContext



    def __read_args(self, data: ExecutionContextData, args: list):
        args_to_handle = deepcopy(args)

        while len(args_to_handle) > 0:
            dataCopy = deepcopy(data)

            handler = self.__resolver.resolve(dataCopy, args_to_handle)

            args_to_consume = args_to_handle[0:handler.count_consume(self.__app_context, dataCopy, args_to_handle)]
            args_to_handle = args_to_handle[len(args_to_consume):]

            handler.handle(self.__app_context, data, args_to_consume)

