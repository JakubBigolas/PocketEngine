from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain.data.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_context.data import ExecutionContextData


class RunnerHandlerAbstract:

    def handle(self, app_context: AppContext, data: ExecutionContextData, chain: ExecutionChainData):
        raise NotImplementedError()

    def accepts(self, app_context: AppContext, chain: ExecutionChainData):
        raise NotImplementedError()

