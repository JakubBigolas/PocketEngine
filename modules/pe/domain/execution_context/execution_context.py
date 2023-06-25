from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_context.data import ExecutionContextData

from modules.pe.domain.execution_context.execution_context_helper import ExecutionContextHelper
from modules.pe.domain.execution_context.parser import ExecutionContextParser


class ExecutionContext:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__helper = ExecutionContextHelper()



    def print_args_if_no_execution(self, data: ExecutionContextData):
        self.__helper.print_args_if_no_execution(data)



    def store_args_if_requested(self, data: ExecutionContextData):
        self.__helper.store_args_if_requested(self.__app_context, data)



    def store_exec_if_requested(self, data: ExecutionContextData):
        self.__helper.store_exec_if_requested(self.__app_context, data)


    def parser(self):
        return ExecutionContextParser(self.__app_context)