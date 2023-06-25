from copy import deepcopy
from modules.pe.domain.error import PeError
from modules.pe.domain.execution_context_data.execution_context_config import ExecutionContextConfig

from modules.pe.domain.execution_context_data.execution_context_data_helper import ExecutionContextDataHelper


class ExecutionContextData:

    def __init__(self, verbose: bool, dev_mode: bool):
        self.__helper = ExecutionContextDataHelper()
        # command args, ALWAYS MODIFIABLE!!!
        self.__args = dict()
        # command args (before first execution)
        self.__start_args = dict()
        # args left after process handling
        self.__unhandled_args = []
        # flag to prevent context modification
        # if true only current args and execution chain may be modified
        self.__args_commited = False

        self.__config = ExecutionContextConfig(verbose, dev_mode)

    ### PROPERTIES #################################################################################

    @property
    def args(self):                     return deepcopy(self.__args)
    @property
    def start_args(self):               return deepcopy(self.__start_args)
    @property
    def unhandled_args(self):           return deepcopy(self.__unhandled_args)
    @property
    def is_args_commited(self):         return self.__args_commited
    @property
    def config(self):                   return self.__config

    ### BUSINESS LOGIC #################################################################################

    def add_or_put_key_value(self, key: str, value: str):
        """
        If add args is enabled add another value for key.
        If add args is disabled put another value for key.
        WARNING: it works even if unset args is enabled.
        :param key: arg name
        :param value: arg value
        :return: void
        """
        self.__helper.add_or_put_key_value(self.__args, self.config.is_add_args_enabled, key, value)



    def add_or_put_or_unset_key_value(self, key: str, value: str):
        """
        If setting args is enabled redirects to add_or_put_key_value.
        Otherwise, removes all values for key.
        :param key: arg name
        :param value: arg value (optional for removing)
        :return: void
        """
        self.__helper.add_or_put_or_unset_key_value(self.__args, self.config.is_set_args_enabled, self.config.is_add_args_enabled, key, value)



    def add_unhandled_arg(self, arg: str):
        self.__unhandled_args.append(arg)



    def clear_unhandled_args(self):
        self.__unhandled_args.clear()



    def clear(self):
        self.__args.clear()



    def commit_args(self, unhandled_args: list):
        if not self.__args_commited:
            if unhandled_args and len(unhandled_args) > 0:
                self.__unhandled_args += unhandled_args
            self.__start_args = deepcopy(self.__args)
            self.__args_commited = True
            self.config.commit_args()

        else:
            self.__check_modifiability()



    def __check_modifiability(self):
        if self.__args_commited:
            raise PeError("Execution context is unmodifiable after arguments commit")
        if len(self.__unhandled_args) > 0:
            raise PeError("Execution context is unmodifiable while there are unhandled arguments")

