from modules.pe.domain.app_context import AppContext
from modules.pe.error import PeError
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionContextRmHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        expr = args[0].removeprefix("context-rm")
        expr = expr.removeprefix("/")

        if not expr:
            raise PeError("ERROR: context-rm requires context name to be removed")

        app_context.remove_context(expr)

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg == "context-rm" or arg.startswith("context-rm/") )
