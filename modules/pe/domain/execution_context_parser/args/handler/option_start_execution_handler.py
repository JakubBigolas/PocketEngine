from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_context_parser.args.handler import ArgsHandlerAbstract
from modules.pe.domain.execution_context_data import ExecutionContextData


class OptionStartExecutionHandler(ArgsHandlerAbstract):



    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        context_data.commit_args(args)



    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg in ["-", "--"] )


    def count_consume(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> int:
        return len(args)
