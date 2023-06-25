class ArgUtils:



    @staticmethod
    def wrap(value: str):
        return value if value is None else value.replace("\"", "\\\"")
