import os
from copy import deepcopy
from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_chain_parser import ExecutionChainParser
from modules.pe.domain.execution_chain_runner.execution_chain_runner import ExecutionChainRunner
from modules.pe.domain.execution_context_parser import ExecutionContextParser



class App:

    def __init__(self, config: dict):
        self.__config               = dict(config)
        self.__context_path: str    = None
        self.__verbose: bool        = None
        self.__dev_mode: bool       = None

        self.__load_configs()

        self.__app_context      = AppContext(self.__context_path, self.sub_execution)
        self.__context_parser   = ExecutionContextParser(self.__app_context)
        self.__chain_parser     = ExecutionChainParser(self.__app_context)
        self.__runner           = ExecutionChainRunner(self.__app_context)



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
        # prevent modifying original args
        args = deepcopy(args)

        # create execution context
        execution_context = self.__context_parser.parse(args, self.__verbose, self.__dev_mode)
        execution_context.store_args_if_requested(self.__app_context)
        execution_context.store_exec_if_requested(self.__app_context)
        execution_context.print_args_if_no_execution()

        if execution_context.data.is_args_commited and not execution_context.data.config.save_as_command:
            execution_chain = self.__chain_parser.parse(execution_context.data.unhandled_args)

            if execution_chain.commited:
                self.__runner.execute(execution_context, execution_chain)
