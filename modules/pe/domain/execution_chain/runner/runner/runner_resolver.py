from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain.data.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_chain.runner.runner.handler import RunnerHandlerAbstract
from modules.pe.domain.execution_chain.runner.runner.handler.cmd_handler import CmdHandler
from modules.pe.domain.execution_chain.runner.runner.handler.stored_cmd_handler import StoredCmdHandler


class RunnerResolver:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__runner_handlers = [
            CmdHandler(),
            StoredCmdHandler()
        ]



    def resolve(self, data: ExecutionChainData) -> RunnerHandlerAbstract:
        handlers = [it for it in self.__runner_handlers if it.accepts(self.__app_context, data)]
        if len(handlers) == 1:
            return handlers[0]
        else:
            raise RuntimeError("Unexpected count ({}) of runner handler for chain data type \"{}\"".format(len(handlers), data))
