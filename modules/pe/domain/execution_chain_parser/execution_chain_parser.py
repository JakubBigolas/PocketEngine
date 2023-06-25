from copy import deepcopy

from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_chain import ExecutionChain
from modules.pe.domain.execution_chain_parser.execs.exec_resolver import ExecResolver


class ExecutionChainParser:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__resolver = ExecResolver(app_context)



    def parse(self, args: list) -> ExecutionChain:
        chain = ExecutionChain()
        self.__read_args(chain, args)
        chain.commit()
        return chain



    def __read_args(self, chain: ExecutionChain, args: list):
        if args and len(args) > 0:

            args_to_consume = list()
            args_to_consume.append(args.pop(0))

            for arg in args:
                # create execution and start another
                if arg in ["-", "--"]:
                    self.__create_next_execution(chain, args_to_consume)
                    args_to_consume = list()
                    args_to_consume.append(arg)

                # continue completing execution
                else:
                    args_to_consume.append(arg)

            self.__create_next_execution(chain, args_to_consume)



    def __create_next_execution(self, chain: ExecutionChain, args: list):
        if args and len(args) > 0:
            chainData = self.__resolver.resolve(deepcopy(args)).handle(self.__app_context, args)
            chain.add(chainData)
