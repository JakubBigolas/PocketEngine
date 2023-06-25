from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_context.parser.args.handler.args_context_handler_abstract import ArgsContextHandlerAbstract
from modules.pe.domain.execution_context.data import ExecutionContextData
import re

from modules.pe.utils.color_utils import ColorUtils


class OptionContextListHandler(ArgsContextHandlerAbstract):


    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        expr = args[0].removeprefix("context-list")

        print_details = False
        if expr.startswith("/"):
            expr = expr.removeprefix("/")
            print_details = True

        for item in list(app_context.contexts_list()):
            if re.search(expr, item):
                self.print_context(app_context, context_data, item, print_details)
        exit(0)


    def print_context(self, app_context: AppContext, context_data: ExecutionContextData, item: str, print_details: bool):
        print("{}context{} : {}".format(ColorUtils.C_GREEN, ColorUtils.C_RESET, item))
        print()

        context_context = str(app_context.load_context(item))
        args = context_context.split("\n")
        while len(args) > 0:
            key = args.pop(0)
            value = None if len(args) < 1 or not self.is_pair_key_value(context_data, key, args[0]) else args.pop(0)
            if print_details:
                print("{}   KEY  {}: \"{}\"".format(ColorUtils.C_YELLOW, ColorUtils.C_RESET, key))
                print("{}   VALUE{}: \"{}\"".format(ColorUtils.C_YELLOW, ColorUtils.C_RESET, value))
                print()
            else:
                if key is not None:   print(f"\"{key}\" ", end="")
                if value is not None: print(f"\"{value}\" ", end="")

        if not print_details:
            print()
            print()




    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg == "context-list" or arg.startswith("context-list/") )
