from copy import deepcopy

from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.parametrization_context import ParametrizationContext
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.statement_each_reader import StatementEachReader
from modules.pe.domain.utils import ColorUtils


class StatementReader:

    def __init__(self):
        self.__each_reader = StatementEachReader()

    def read_statement(self, context: ParametrizationContext):
        if context.input.startswith("[[#"):
            context.input = context.input[3:]

            if          not self.__each_reader.read(context):# \
                    # and not self.read_if(context)   \
                    # and not self.read_switch(context):

                raise PeError("Unknown statement")

            return True
        return False
