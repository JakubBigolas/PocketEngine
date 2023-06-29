from modules.pe.domain.app_context import AppContext
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionExecsHandler(ArgsHandlerAbstract):

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        for item in list(app_context.execs_list()):
            print(item)
        exit(0)

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return args[0] == "execs"
