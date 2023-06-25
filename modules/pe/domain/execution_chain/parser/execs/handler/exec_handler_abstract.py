from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain.data.execution_chain_data import ExecutionChainData


class ExecHandlerAbstract:

    def handle(self, app_context: AppContext, args: list) -> ExecutionChainData:
        raise NotImplementedError()

    def accepts(self, app_context: AppContext, args: list) -> bool:
        # TODO: set, unset, reset, choose, clear, cmd
        raise NotImplementedError()
