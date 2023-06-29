from modules.pe.domain.app_context import AppContext
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionDevModeHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        context_data.config.dev_mode()
        context_data.config.verbose()

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args[0] == "dev-mode"
