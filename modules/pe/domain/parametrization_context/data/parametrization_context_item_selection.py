from modules.pe.domain.parametrization_context.data.parametrization_context_item import ParametrizationContextItem


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
