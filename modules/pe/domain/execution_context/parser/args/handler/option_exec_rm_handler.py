from modules.pe.domain.app_context import AppContext
from modules.pe.error import PeError
from modules.pe.domain.execution_context.parser.args.handler import ArgsHandlerAbstract
from modules.pe.domain.execution_context.data import ExecutionContextData


class OptionExecRmHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        expr = args[0].removeprefix("exec-rm")
        expr = expr.removeprefix("/")

        if not expr:
            raise PeError("ERROR: exec-rm requires exec name to be removed")

        app_context.remove_exec(expr)

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg == "exec-rm" or arg.startswith("exec-rm/") )
