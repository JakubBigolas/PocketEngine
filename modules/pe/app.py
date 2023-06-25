import os
from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain import ExecutionChain
from modules.pe.domain.execution_chain.runner import ExecutionChainRunner
from modules.pe.domain.execution_context import ExecutionContext


class App:

    def __init__(self, config: dict):
        self.__config               = dict(config)
        self.__context_path: str    = None
        self.__verbose: bool        = None
        self.__dev_mode: bool       = None

        self.__load_configs()
        self.__app_context          = AppContext(self.__context_path, self.sub_execution)
        self.__execution_context    = ExecutionContext(self.__app_context)
        self.__execution_chain      = ExecutionChain(self.__app_context)



    def sub_execution(self):
        return App(self.__config)



    def __load_configs(self):
        self.__context_path = self.__load_config("PE_CONTEXT_PATH", "~/pe")
        self.__verbose      = self.__load_config("PE_VERBOSE", False)
        self.__dev_mode     = self.__load_config("PE_DEV_MODE", False)



    def __load_config(self, variable: str, default) -> str :
        """
            Try to load variable from config.py file or if there is no such argument tries to load from env variables
            :param variable name
            :param default If there is no value for name in both sources returns default value
        """
        try:
            return self.__config[variable] if self.__config[variable] else os.environ[variable]
        except KeyError:
            return default



    def execute(self, args: list):

        # create execution context
        data = self.__execution_context.parser().parse(args, self.__verbose, self.__dev_mode)
        self.__execution_context.store_args_if_requested(data)
        self.__execution_context.store_exec_if_requested(data)
        self.__execution_context.print_args_if_no_execution(data)

        if data.commited and not data.config.save_as_command and len(data.unhandled_args) > 0:
            chain = self.__execution_chain.parser().parse(data.unhandled_args)

            if chain and chain.commited:
                self.__execution_chain.runner().execute(data, chain)
