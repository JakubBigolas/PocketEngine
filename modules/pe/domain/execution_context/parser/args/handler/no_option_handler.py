from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_context.data import ExecutionContextData
from modules.pe.domain.execution_context.parser.args.handler.args_context_handler_abstract import ArgsContextHandlerAbstract


class NoOptionHandler(ArgsContextHandlerAbstract):



    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        key = args[0]

        value = None
        if len(args) > 1:
            value = args[1]

        if key is not None:
            context_data.add_or_put_or_unset_key_value(key, value)



    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        return False



    def count_consume(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> int:
        if len(args) > 1 and self.is_pair_key_value(context_data, args[0], args[1]):
            return 2
        else:
            return super().count_consume(app_context, context_data, args)
