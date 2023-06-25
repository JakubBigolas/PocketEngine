from modules.pe.domain.parametrization_context.data.parametrization_context_data import ParametrizationContextData
from modules.pe.domain.parametrization_context.reader.statement_each_reader import StatementEachReader
from modules.pe.error import PeError


class StatementReader:

    def __init__(self):
        self.__each_reader = StatementEachReader()

    def read_statement(self, context: ParametrizationContextData):
        if context.input.startswith("[[#"):
            context.input = context.input[3:]

            if          not self.__each_reader.read(context):# \
                    # and not self.read_if(context)   \
                    # and not self.read_switch(context):

                raise PeError("Unknown statement")

            return True
        return False
