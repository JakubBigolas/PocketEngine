from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.parametrization_context import ParametrizationContext
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.selection_reader import SelectionReader
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.statement_reader import StatementReader
from modules.pe.domain.utils import ColorUtils


class RunnerHandlerHelper:

    def parametrized(self, params: list, args: dict, wrap = True) -> str:
        result = ""

        for param in params:
            result += self.parametrize(param, args, wrap) + " "

        limit = 100
        sub_result = self.parametrize(result, args, False)
        while sub_result != result:
            sub_result = self.parametrize(sub_result, args, False)
            result = sub_result
            limit -= 1
            if limit < 0:
                raise PeError("Maximum limit (100) of recurrent parametrization exceed with parametrization result: {}".format(sub_result))

        return result[0:-1]



    def parametrize(self, param: str, args: dict, wrap = True) -> str:
        if param:

            context = ParametrizationContext(param, args, SelectionReader(), StatementReader())
            self.read_input(context)
            param = context.result

        return param if not wrap else "\"" + param.replace("\"", "\\\"") + "\""



    def read_input(self, context: ParametrizationContext):
        start_input = context.input
        while len(context.input) > 0:

            try:
                if          not context.selection_reader.read_selection(context) \
                        and not context.statement_reader.read_statement(context):

                    context.result += context.input[0]
                    context.input   = context.input[1:]

            except PeError as e:
                self.__handle_error(e, start_input, context)



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