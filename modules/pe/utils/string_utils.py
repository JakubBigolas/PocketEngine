class StringUtils:

    @staticmethod
    def is_empty(value: str):
        return value is None or len(value) == 0

    @staticmethod
    def is_not_empty(value: str):
        return value is not None and len(value) > 0