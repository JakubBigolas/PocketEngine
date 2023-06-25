from modules.pe.domain.app import AppContext
from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.parametrization_context import ParametrizationContext, ParametrizationContextItemStatementEach
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.selection_reader import SelectionReader
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.statement_reader import StatementReader
from modules.pe.domain.execution_chain_runner.runner.handler.runner_handler_helper import RunnerHandlerHelper
from modules.pe.domain.execution_context_data   import ExecutionContextData
from modules.pe.domain.utils import ColorUtils
from modules.pe.domain.utils.arg_utils          import ArgUtils
from modules.pe.domain.utils.string_utils       import StringUtils


class ExecutionContextHelper:



    def print_args_if_no_execution(self, data: ExecutionContextData):
        if not data.is_args_commited:
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
            if data.is_args_commited:
                self.store_args(app_context, "default", data.start_args)
            else :
                self.store_args(app_context, "default", data.args)
        if data.config.is_store_args and StringUtils.is_not_empty(data.config.context_file):
            if data.is_args_commited:
                self.store_args(app_context, data.config.context_file, data.start_args)
            else:
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

            parametrizationContext = ParametrizationContext(validable_text, dict(), SelectionReader(), StatementReader(), False)
            self.validate_exec(parametrizationContext, validable_text)

            app_context.save_exec(data.config.save_as_command, text)



    def validate_exec(self, context: ParametrizationContext, start_text: str):
        if context.input:
            runnerHandlerHelper = RunnerHandlerHelper()
            runnerHandlerHelper.read_input(context)

            statement_expressions = [it for it in context.items if isinstance(it, ParametrizationContextItemStatementEach)]
            if len(statement_expressions) > 0:
                for item in statement_expressions:
                    statement: ParametrizationContextItemStatementEach = item
                    if statement.sub_section:
                        sub_context = ParametrizationContext(statement.sub_section, context.args, context.selection_reader, context.statement_reader, context.throw_on_key_validation)
                        try:
                            self.validate_exec(sub_context, statement.sub_section)
                        except PeError as e:
                            context.input = start_text[-statement.input_len + len(statement.key) + 3:]
                            self.__handle_error(e, start_text, context)



    def __handle_error(self, e: PeError, start_input: str, context: ParametrizationContext):
        correct_input = start_input if len(context.input) == 0 else start_input[: - len(context.input)]
        raise PeError("{}\n[{}.{}] : {}{}{}{}{}".format(
            str(e),
            len(start_input) - len(context.input),
            len(context.input),
            ColorUtils.C_WHITE,
            correct_input,
            ColorUtils.C_I_RED,
            context.input,
            ColorUtils.C_RESET))



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








