from copy import deepcopy

from modules.pe.domain.app_context                                                          import AppContext
from modules.pe.error import PeError
from modules.pe.domain.execution_context.data import ExecutionContextData
from modules.pe.domain.execution_context.parser.args.args_resolver import ArgsResolver
from modules.pe.domain.execution_context.parser.args.handler import ArgsHandlerAbstract


class ExecutionContextParser:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__resolver = ArgsResolver(app_context)



    def parse(self, args: list, verbose: bool, dev_mode: bool) -> ExecutionContextData:
        data = ExecutionContextData(verbose, dev_mode)
        self.__read_args(data, args)
        return data



    def __read_args(self, data: ExecutionContextData, args: list):
        args_to_handle = deepcopy(args)

        while len(args_to_handle) > 0:
            dataCopy = deepcopy(data)
            handler = self.__resolver.resolve(dataCopy, args_to_handle)

            args_to_consume = self.__extract_args_to_consume(args_to_handle, handler, dataCopy)
            args_to_handle = args_to_handle[len(args_to_consume):]

            handler.handle(self.__app_context, data, args_to_consume)

    def __extract_args_to_consume(self, args_to_handle, handler: ArgsHandlerAbstract, data: ExecutionContextData) -> list:
        args_to_consume = args_to_handle[0:handler.count_consume(self.__app_context, data, args_to_handle)]

        if len(args_to_consume) < 1 : raise PeError("Handler must consume at least one argument. args = {} handler = {}".format(args_to_consume, handler))

        return args_to_consume
