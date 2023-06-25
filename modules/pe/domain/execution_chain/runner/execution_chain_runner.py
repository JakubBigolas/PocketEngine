from copy import deepcopy

from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain.data.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_chain.runner.runner.runner_resolver import RunnerResolver
from modules.pe.domain.execution_context.data import ExecutionContextData
from modules.pe.error import PeError


class ExecutionChainRunner:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__resolver = RunnerResolver(app_context)



    def execute(self, data: ExecutionContextData, chain: ExecutionChainData):
        self.__validate(data, chain)

        while chain is not None:
            self.__execute_chain_data(data, chain)
            chain = chain.next



    def __execute_chain_data(self, data: ExecutionContextData, chain: ExecutionChainData):
        self.__resolver\
            .resolve(deepcopy(chain))\
            .handle(self.__app_context, deepcopy(data), deepcopy(chain))



    def __validate(self, data: ExecutionContextData, chain: ExecutionChainData):

        if not data.commited:
            raise PeError("Context data must not be modifiable")

        if not data.config.commited:
            raise PeError("Context config must not be modifiable")

        if not chain.commited:
            raise PeError("Execution chain must not be modifiable")

        while chain is not None:
            if not chain.commited:
                raise PeError("Execution chain data must not be modifiable")
            chain = chain.next
