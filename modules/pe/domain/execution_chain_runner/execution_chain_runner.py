from modules.pe.domain.app import AppContext
from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain import ExecutionChain
from modules.pe.domain.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_chain_runner.runner.runner_resolver import RunnerResolver
from modules.pe.domain.execution_context import ExecutionContext


class ExecutionChainRunner:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__resolver = RunnerResolver(app_context)



    def execute(self, context: ExecutionContext, chain: ExecutionChain):
        self.__validate(context, chain)

        chain_data = chain.head
        while chain_data is not None:
            self.__execute_chain_data(context, chain, chain_data)
            chain_data = chain_data.next



    def __execute_chain_data(self, context: ExecutionContext, chain: ExecutionChain, chain_data: ExecutionChainData):
        self.__resolver.resolve(chain_data).handle(self.__app_context, context, chain, chain_data)



    def __validate(self, context: ExecutionContext, chain: ExecutionChain):

        if not context.data.is_args_commited:
            raise PeError("Context data must not be modifiable")

        if not context.data.config.is_args_commited:
            raise PeError("Context config must not be modifiable")

        if not chain.commited:
            raise PeError("Execution chain must not be modifiable")

        chain_data = chain.head
        while chain_data is not None:
            if not chain_data.commited:
                raise PeError("Execution chain data must not be modifiable")
            chain_data = chain_data.next
