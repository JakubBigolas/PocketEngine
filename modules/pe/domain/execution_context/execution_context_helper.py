from modules.pe.utils import ArgUtils
from modules.pe.utils import StringUtils
from modules.pe.domain.app_context import AppContext
from modules.pe.domain.parametrization_context import ParametrizationContext

from .data.execution_context_data import ExecutionContextData


class ExecutionContextHelper:

    def __init__(self):
        self.__parametrizationContext = ParametrizationContext()


    def print_args_if_no_execution(self, data: ExecutionContextData):
        if not data.commited:
            line = ""
            for arg in data.args:
                arg_value = data.args[arg]
                for value in arg_value:
                    line += "\"{}\" ".format(ArgUtils.wrap(arg))
                    if value is not None:
                        line += "\"{}\" ".format(ArgUtils.wrap(value))
            print(line)



    def store_args_if_requested(self, app_context: AppContext, data: ExecutionContextData):
        if data.config.is_store_default_args:
                self.store_args(app_context, "default", data.args)
        if data.config.is_store_args and StringUtils.is_not_empty(data.config.context_file):
                self.store_args(app_context, data.config.context_file, data.args)
        pass



    def store_exec_if_requested(self, app_context: AppContext, data: ExecutionContextData):
        if data.config.save_as_command and data.unhandled_args and len(data.unhandled_args) > 0:

            text = ""
            validable_text = ""
            for arg in data.unhandled_args:
                text += arg + "\n"
                validable_text += arg + " "

            if len(text) > 0:
                text = text[0:-1]
                validable_text = validable_text[0:-1]

            self.__parametrizationContext.validate_execution(validable_text)
            app_context.save_exec(data.config.save_as_command, text)



    def store_args(self, app_context: AppContext, name: str, args: dict):
        text = ""
        for arg in args:
            arg_value = args[arg]
            if len(arg_value) > 0:
                for value in arg_value:
                    if arg is not None:
                        text += arg + "\n"
                    if value is not None:
                        text += value + "\n"
            elif arg is not None:
                text += arg + "\n"
        if len(text) > 0:
            text = text[0:-1]
        app_context.save_context(name, text)








