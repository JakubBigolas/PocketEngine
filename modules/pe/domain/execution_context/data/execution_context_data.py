from copy import deepcopy
from modules.pe.error import PeError

from .execution_context_config import ExecutionContextConfig
from .execution_context_data_helper import ExecutionContextDataHelper


class ExecutionContextData:

    def __init__(self, verbose: bool, dev_mode: bool):
        self.__helper = ExecutionContextDataHelper()
        # command args
        self.__args = dict()
        # args left after process handling
        self.__unhandled_args = []
        # flag to prevent context modification
        self.__commited = False

        self.__config = ExecutionContextConfig(verbose, dev_mode)

    @property
    def args(self)           : return deepcopy(self.__args)
    @property
    def unhandled_args(self) : return deepcopy(self.__unhandled_args)
    @property
    def commited(self)       : return self.__commited
    @property
    def config(self)         : return self.__config



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



    def clear(self):
        self.__args.clear()



    def commit_args(self, unhandled_args: list):
        if not self.__commited:

            self.__unhandled_args = deepcopy(unhandled_args)
            self.__commited = True
            self.config.commit_args()

        else:
            self.__check_modifiability()



    def __check_modifiability(self):
        if self.__commited:
            raise PeError("Execution context is unmodifiable after arguments commit")

