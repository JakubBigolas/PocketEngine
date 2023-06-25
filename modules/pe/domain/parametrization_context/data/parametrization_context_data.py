from modules.pe.domain.parametrization_context.data.parametrization_context_item import ParametrizationContextItem
from modules.pe.error import PeError
from modules.pe.utils.color_utils import ColorUtils


class ParametrizationContextData:

    def __init__(self, input: str, args: dict, selection_reader, statement_reader, throw_on_key_validation = True):
        self.input      = input
        self.args       = args
        self.result     = ""
        self.selection_reader = selection_reader
        self.statement_reader = statement_reader
        self.items = []
        self.throw_on_key_validation = throw_on_key_validation

    def read_begin(self, value: str) -> bool:
        if self.input.startswith(value):
            self.input = self.input[len(value):]
            return True
        return False

    def starts_with(self, values: list) -> bool:
        for value in values:
            if self.input.startswith(value):
                return True
        return False

    def read_first(self, chars: int) -> str:
        result = self.input[:chars]
        self.input = self.input[chars:]
        return result

    def add_item(self, item: ParametrizationContextItem, parent: ParametrizationContextItem = None):
        item.input_len = len(self.input)
        if parent:
            parent.items.append(item)
            item.parent = parent
        self.items.append(item)

    def handle_error(self, e: PeError, start_input: str, context_input: str):
        correct_input = start_input if len(context_input) == 0 else start_input[: - len(context_input)]
        raise PeError("{}\n[{}.{}] : {}{}{}{}{}".format(
            str(e),
            len(start_input) - len(context_input),
            len(context_input),
            ColorUtils.C_WHITE,
            correct_input,
            ColorUtils.C_I_RED,
            context_input,
            ColorUtils.C_RESET))



    def new_data(self, input: str, args: dict, throw_on_key_validation = True):
        return ParametrizationContextData(input, args, self.selection_reader, self.statement_reader, throw_on_key_validation)
