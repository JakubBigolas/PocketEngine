from modules.pe.domain.parametrization_context.data.parametrization_context_data import ParametrizationContextData
from modules.pe.domain.parametrization_context.data.parametrization_context_item_statement_each import ParametrizationContextItemStatementEach
from modules.pe.domain.parametrization_context.reader.selection_reader import SelectionReader
from modules.pe.domain.parametrization_context.reader.statement_reader import StatementReader
from modules.pe.error import PeError


class ParametrizationContext:


    def validate_execution(self, execution: str):

        if execution:
            context = self.new_data(execution, dict(), False)

            self.read_input(context)

            statement_expressions = [it for it in context.items if isinstance(it, ParametrizationContextItemStatementEach)]
            if len(statement_expressions) > 0:
                for item in statement_expressions:
                    statement: ParametrizationContextItemStatementEach = item
                    if statement.sub_section:
                        try:
                            self.validate_execution(statement.sub_section)
                        except PeError as e:
                            context.input = execution[-statement.input_len + len(statement.key) + 3:]
                            context.handle_error(e, execution, context.input)


    def to_parametrized_string(self, strings: list, args: dict, wrap = True) -> str:
        result = ""

        for param in strings:
            result += self.parametrize_string(param, args, wrap) + " "

        limit = 100
        sub_result = self.parametrize_string(result, args, False)
        while sub_result != result:
            sub_result = self.parametrize_string(sub_result, args, False)
            result = sub_result
            limit -= 1
            if limit < 0:
                raise PeError("Maximum limit (100) of recurrent parametrization exceed with parametrization result: {}".format(sub_result))

        return result[0:-1]



    def parametrize_string(self, string: str, args: dict, wrap = True) -> str:
        if string:

            context = self.new_data(string, args)
            self.read_input(context)
            string = context.result

        return string if not wrap else "\"" + string.replace("\"", "\\\"") + "\""



    def new_data(self, input: str, args: dict, throw_on_key_validation = True) -> ParametrizationContextData:
        return ParametrizationContextData(input, args, SelectionReader(), StatementReader(), throw_on_key_validation)



    def read_input(self, context: ParametrizationContextData):
        start_input = context.input
        while len(context.input) > 0:

            try:
                if          not context.selection_reader.read_selection(context) \
                        and not context.statement_reader.read_statement(context):

                    context.result += context.input[0]
                    context.input   = context.input[1:]

            except PeError as e:
                context.handle_error(e, start_input, context.input)
