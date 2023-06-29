from modules.pe.domain.app_context import AppContext
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionStoreHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        arg = args[0]
        context_name = None
        if arg.startswith("store/"):
            context_name = arg.removeprefix("store/")
        if arg.startswith("s/"):
            context_name = arg.removeprefix("s/")
        context_data.config.store(context_name)

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg == "store" or arg.startswith("store/") or arg.startswith("s/"))
