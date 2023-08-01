from modules.pe.domain.app_context import AppContext
from .args_context_handler_abstract import ArgsContextHandlerAbstract
from ....data.execution_context_data import ExecutionContextData
import re

class OptionContextHandler(ArgsContextHandlerAbstract):


    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        arg = args[0]
        expr = "context"
        if arg.startswith("context/"):
            expr=arg.removeprefix("context/")
        if arg.startswith("c/"):
            expr=arg.removeprefix("c/")

        for item in list(app_context.contexts_list()):
            if len(expr) == 0 or re.fullmatch(expr, item):
                self.read_context(app_context, context_data, item)



    def read_context(self, app_context: AppContext, context_data: ExecutionContextData, item: str):
        context_context = str(app_context.load_context(item))
        args = context_context.split("\n")
        while len(args) > 0:
            key = args.pop(0)
            value = None if len(args) < 1 or not self.is_pair_key_value(context_data, key, args[0]) else args.pop(0)
            context_data.add_or_put_key_value(key, value)



    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg == "context" or arg.startswith("context/") or arg.startswith("c/") )
