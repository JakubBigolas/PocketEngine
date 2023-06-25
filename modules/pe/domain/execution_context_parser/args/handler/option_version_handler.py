from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_context_parser.args.handler import ArgsHandlerAbstract
from modules.pe.domain.execution_context_data import ExecutionContextData


class OptionVersionHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        print("2.0.0")
        exit(0)

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args[0] == "version"
