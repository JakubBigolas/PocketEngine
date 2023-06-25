from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_context_data import ExecutionContextData

from modules.pe.domain.execution_context.execution_context_helper import ExecutionContextHelper


class ExecutionContext:

    def __init__(self, verbose: bool, dev_mode: bool):
        self.__data = ExecutionContextData(verbose, dev_mode)
        self.__helper = ExecutionContextHelper()

    @property
    def data(self)        -> ExecutionContextData : return self.__data



    def print_args_if_no_execution(self):
        self.__helper.print_args_if_no_execution(self.__data)



    def store_args_if_requested(self, app_context: AppContext):
        self.__helper.store_args_if_requested(app_context, self.__data)



    def store_exec_if_requested(self, app_context: AppContext):
        self.__helper.store_exec_if_requested(app_context, self.__data)
