from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_context_data import ExecutionContextData
from modules.pe.domain.execution_context_parser.args.handler import ArgsHandlerAbstract

class ArgsContextHandlerAbstract(ArgsHandlerAbstract):


    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return False


    def is_pair_key_value(self, context_data: ExecutionContextData, key: str, value: str):
        """
        Check if key and value may be treated as pair.
        :param context_data: execution context data
        :param key: arg name
        :param value: arg value or another key
        :return: false if setting args is disabled or key is None or value is None or first letter of value is "-" or value looks like "[# ... ]" or key has char "=" inside,
        otherwise true
        """
        if not context_data.config.is_set_args_enabled or key is None or value is None:
            return False

        if len(value) > 0:
            if value[0] == "-":
                return False  # if second value starts with minus it is KEY itself
            if value[0:2] == "[#" and value[-1:1] == "]":
                return False  # if second value is internal key then it cannot be value

        if len(key) > 0:
            if "=" in key:
                return False  # if first value contains equal sign it is KEY=VALUE argument or it is too complex to be KEY VALUE pair

        return True