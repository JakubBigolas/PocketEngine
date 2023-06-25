class ParametrizationContextItem:
    def __init__(self):
        self.input_len = 0
        self.items = []
        self.parent: ParametrizationContextItem = None


class ParametrizationContextItemSelectionAll(ParametrizationContextItem):
    pass


class ParametrizationContextItemSelection(ParametrizationContextItem):
    def __init__(self):
        super().__init__()
        self.required: bool     = None
        self.key: str           = None
        self.count: bool        = None
        self.concat: bool       = None
        self.item: int          = None
        self.replacement: str   = None
        self.or_else: str       = None

class ParametrizationContextItemStatementEach(ParametrizationContextItem):
    def __init__(self):
        super().__init__()
        self.key: str           = None
        self.sub_section: str   = None


class ParametrizationContext:

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
