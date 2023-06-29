from modules.pe.domain.app_context import AppContext
from .parser.execution_chain_parser import ExecutionChainParser
from .runner.execution_chain_runner import ExecutionChainRunner


class ExecutionChain:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context



    def parser(self):
        return ExecutionChainParser(self.__app_context)



    def runner(self):
        return ExecutionChainRunner(self.__app_context)