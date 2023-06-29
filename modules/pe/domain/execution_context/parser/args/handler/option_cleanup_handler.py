from modules.pe.domain.app_context import AppContext
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionCleanupHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        app_context.remove_context("default")
        app_context.remove_context("context")
        exit(0)

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args[0] == "cleanup"
