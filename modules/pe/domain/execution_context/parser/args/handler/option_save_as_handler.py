from modules.pe.domain.app_context import AppContext
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionSaveAsHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        context_data.config.save_as(args[1])

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args and len(args) > 1 and args[0] == "save-as"

    def count_consume(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> int:
        return 2

