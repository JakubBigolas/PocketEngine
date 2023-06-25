from modules.pe.domain.execution_chain_runner.runner.handler import *

from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_chain_runner.runner.handler.runner_handler_abstract import RunnerHandlerAbstract


class RunnerResolver:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__runner_handlers = []
        self.inject_runner_handlers()



    def inject_runner_handlers(self):
        for name, obj in globals().items():
            if isinstance(obj, type) and issubclass(obj, RunnerHandlerAbstract) and obj != RunnerHandlerAbstract:
                self.__runner_handlers.append(obj())



    def resolve(self, chain_data: ExecutionChainData) -> RunnerHandlerAbstract:
        handlers = [it for it in self.__runner_handlers if it.accepts(self.__app_context, chain_data) ]
        if len(handlers) == 1:
            return handlers[0]
        else:
            raise RuntimeError("Unexpected count ({}) of runner handler for chain data type \"{}\"".format(len(handlers), chain_data))
