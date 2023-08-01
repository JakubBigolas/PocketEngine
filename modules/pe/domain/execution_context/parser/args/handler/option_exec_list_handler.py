import io
import re

from modules.pe.domain.app_context import AppContext
from modules.pe.utils.arg_utils import ArgUtils
from modules.pe.utils.color_utils import ColorUtils
from modules.pe.domain.parametrization_context import ParametrizationContextItemSelection,\
    ParametrizationContextItemSelectionAll,\
    ParametrizationContextItemStatementEach,\
    ParametrizationContext

from .args_handler_abstract import ArgsHandlerAbstract
from ....data.execution_context_data import ExecutionContextData


class OptionExecListHandler(ArgsHandlerAbstract):

    def __init__(self):
        self.__parametrization_context = ParametrizationContext()

    def handle(self, app_context: AppContext, context_data: ExecutionContextData, args: list):
        expr: str = args[0].removeprefix("exec-list")

        print_details = False
        if expr.startswith("/"):
            expr = expr.removeprefix("/")
            print_details = True

        for item in list(app_context.execs_list()):
            if len(expr) == 0 or re.fullmatch(expr, item):
                self.print_exec(app_context, item, print_details)
        exit(0)



    def accepts(self, app_context: AppContext, context_data: ExecutionContextData, args: list) -> bool:
        arg = args[0]
        return arg and ( arg == "exec-list" or arg.startswith("exec-list/") )



    def print_exec(self, app_context: AppContext, item: str, print_details: bool):
        print("{}Execution{} : {}{}".format(ColorUtils.C_I_GREEN, ColorUtils.C_WHITE, item, ColorUtils.C_RESET))
        self.print_exec_doc(app_context, item, print_details)
        self.print_exec_cmd(app_context, item, print_details)
        self.print_exec_args(app_context, item, print_details)



    def print_exec_doc(self, app_context: AppContext, item: str, print_details: bool):
        # print execution documentation
        if print_details:
            exec_doc = app_context.load_exec_doc(item)
            if exec_doc:
                print("{}#{}".format(ColorUtils.C_I_YELLOW, ColorUtils.C_RESET))
                for doc_line in exec_doc.split("\n"):
                    print(f"{ColorUtils.C_I_YELLOW}#  {doc_line}{ColorUtils.C_RESET}")
                print("{}#{}".format(ColorUtils.C_I_YELLOW, ColorUtils.C_RESET))



    def print_exec_cmd(self, app_context: AppContext, item: str, print_details: bool):
        exec_content = app_context.load_exec(item).strip()
        if exec_content:
            lines = exec_content.split("\n")
            line = ""
            for exec_line in lines:

                if exec_line in ["-", "--"]:
                    print(line)
                    line = "> " + exec_line
                else:
                    line += " \"{}\"".format(ArgUtils.wrap(exec_line))

            print(line)
            print()



    def print_exec_args(self, app_context: AppContext, item: str, print_details: bool):
        out = io.StringIO()
        exec_content = app_context.load_exec(item)

        keys_found = self.print_exec_args_content(exec_content, "   ", out)
        keys_to_fill = set()
        for key in keys_found:
            required_key_form = f"{key} {ColorUtils.C_RED}(required){ColorUtils.C_RESET}"
            if required_key_form not in keys_found and not key.startswith("--each-"):
                keys_to_fill.add(key)

        if len(keys_to_fill) > 0:
            print("   All available keys to fill:", end="")
            for key in keys_to_fill:
                print(f" {key}", end="")
            print()

        if len(out.getvalue()) > 0:
            if print_details:
                print(out.getvalue())
            else:
                print()




    def print_exec_args_content(self, exec_content: str, prefix: str, out) -> set:
        keys_found = set()
        if exec_content:

            context = self.__parametrization_context.new_data(exec_content, dict(), False)
            self.__parametrization_context.read_input(context)

            keys_found.update(self.print_all_expression(       exec_content, context.items, prefix, out))
            keys_found.update(self.print_selection_expressions(exec_content, context.items, prefix, out))
            keys_found.update(self.print_statement_expressions(exec_content, context.items, prefix, out))

        return keys_found



    def print_all_expression(self, input: str, items: list, prefix: str, out) -> set:
        all_expressions = [it for it in items if isinstance(it, ParametrizationContextItemSelectionAll)]
        if len(all_expressions) > 0:
            print(file=out)
            print(f"{prefix}All expressions found", file=out)
        return set()



    def print_selection_expressions(self, input: str, items: list, prefix: str, out) -> set:
        keys_found = set()
        selection_expressions = [it for it in items if isinstance(it, ParametrizationContextItemSelection)]
        if len(selection_expressions) > 0:
            print(file=out)
            print(f"{prefix}Selections expressions found:", file=out)
            for item in selection_expressions:
                selection: ParametrizationContextItemSelection = item
                keys_found.add(selection.key)
                if selection.required:
                    keys_found.add(f"{selection.key} {ColorUtils.C_RED}(required){ColorUtils.C_RESET}")
                result = ""

                if selection.count              : result += "values count of "
                if selection.concat             : result += "values concat of "
                if selection.item is not None   : result += "value at index {} of ".format(selection.item)
                if selection.required    : result += f"{ColorUtils.C_RED}required {ColorUtils.C_RESET}"

                result += f"key {self.highlight(selection.key)}"
                if selection.replacement : result += f" with replacement"
                if selection.or_else     : result += " {}with empty replacement".format("" if not selection.replacement else "and ")
                # if selection.replacement : result += f" replaced with {self.highlight(selection.replacement)}"
                # if selection.or_else     : result += f" or if empty {self.highlight(selection.or_else)}"

                print(" {}{}".format(prefix, result), file=out)
        return keys_found



    def print_statement_expressions(self, input: str, items: list, prefix: str, out) -> set:
        keys_found = set()
        statement_expressions = [it for it in items if isinstance(it, ParametrizationContextItemStatementEach)]
        if len(statement_expressions) > 0:
            print(file=out)
            print(f"{prefix}Statement expressions found:", file=out)
            for item in statement_expressions:
                statement: ParametrizationContextItemStatementEach = item
                keys_found.add(statement.key)
                print("{} For each {} do {}".format(prefix, self.highlight(statement.key), self.highlight(statement.sub_section)), file=out)
                if statement.sub_section:
                    keys_found.update(self.print_exec_args_content(statement.sub_section, prefix + "   ", out))
        return keys_found



    def highlight(self, value: str):
        return "{}{}{}{}".format(ColorUtils.C_BLACK, ColorUtils.C_BG_YELLOW, value, ColorUtils.C_RESET)


