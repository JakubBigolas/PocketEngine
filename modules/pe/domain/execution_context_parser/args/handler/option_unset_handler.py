from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_context_parser.args.handler import ArgsHandlerAbstract
from modules.pe.domain.execution_context_data import ExecutionContextData


class OptionUnsetHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        context_data.config.unset()

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args[0] == "unset"
