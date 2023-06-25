from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_chain import ExecutionChain
from modules.pe.domain.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_chain_runner.runner.handler.runner_handler_helper import RunnerHandlerHelper
from modules.pe.domain.execution_context import ExecutionContext


class RunnerHandlerAbstract:

    def __init__(self):
        self.__helper = RunnerHandlerHelper()

    @property
    def helper(self): return self.__helper

    def handle(self, app_context: AppContext, context: ExecutionContext, chain: ExecutionChain, chain_data: ExecutionChainData):
        raise NotImplementedError()

    def accepts(self, app_context: AppContext, chain_data: ExecutionChainData):
        raise NotImplementedError()

