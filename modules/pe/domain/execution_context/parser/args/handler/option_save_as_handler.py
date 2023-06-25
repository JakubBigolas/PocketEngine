from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_context.parser.args.handler import ArgsHandlerAbstract
from modules.pe.domain.execution_context.data import ExecutionContextData


class OptionSaveAsHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        context_data.config.save_as(args[1])

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args and len(args) > 1 and args[0] == "save-as"

    def count_consume(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> int:
        return 2

