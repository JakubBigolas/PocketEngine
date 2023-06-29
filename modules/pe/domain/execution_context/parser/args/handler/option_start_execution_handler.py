from modules.pe.domain.app_context import AppContext
from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionStartExecutionHandler(ArgsHandlerAbstract):



    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        context_data.commit_args(args)



    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg in ["-", "--"] )


    def count_consume(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> int:
        return len(args)
