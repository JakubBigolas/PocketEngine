from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_context.data import ExecutionContextData


class ArgsHandlerAbstract:

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        raise NotImplementedError

    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        raise NotImplementedError

    def count_consume(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> int:
        if args and len(args) > 0:
            return 1
        else:
            return 0
