from modules.pe.domain.parametrization_context.data.parametrization_context_item import ParametrizationContextItem


class ParametrizationContextItemStatementEach(ParametrizationContextItem):
    def __init__(self):
        super().__init__()
        self.key: str           = None
        self.sub_section: str   = None
