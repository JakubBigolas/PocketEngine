class ParametrizationContextItem:
    def __init__(self):
        self.input_len = 0
        self.items = []
        self.parent: ParametrizationContextItem = None