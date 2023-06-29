from copy import deepcopy

from modules.pe.domain.app_context import AppContext
from ..data.execution_chain_data import ExecutionChainData
from .execs.exec_resolver import ExecResolver


class ExecutionChainParser:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__resolver = ExecResolver(app_context)



    def parse(self, args: list) -> ExecutionChainData:
        chain:ExecutionChainData = None
        last_chain: ExecutionChainData = None

        if args and len(args) > 0:

            args_to_consume = list()
            args_to_consume.append(args.pop(0))

            for arg in args:
                # create execution and start another
                if arg in ["-", "--"]:
                    last_chain = self.__create_next_execution(last_chain, args_to_consume)
                    if chain is None:
                        chain = last_chain
                    args_to_consume = list()
                    args_to_consume.append(arg)

                # continue completing execution
                else:
                    args_to_consume.append(arg)

            last_chain = self.__create_next_execution(last_chain, args_to_consume)
            if chain is None:
                chain = last_chain
            last_chain.commit()

        return chain



    def __create_next_execution(self, last_chain: ExecutionChainData, args: list) -> ExecutionChainData:
        if args and len(args) > 0:
            chain = self.__resolver.resolve(deepcopy(args)).handle(self.__app_context, args)
            if last_chain:
                last_chain.finish_and_next(chain)
            return chain
        return last_chain
