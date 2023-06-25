from copy import deepcopy

from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain_runner.runner.handler.parametrization.parametrization_context import ParametrizationContext, ParametrizationContextItemStatementEach
from modules.pe.domain.utils import ColorUtils


class StatementEachReader:

    # [[#each:key#]] ... [[#each#]]  repeat for each value for key (value count always eq 1 in section)
    # --each-size
    # --each-index
    # --each-first
    # --each-last

    def read(self, context: ParametrizationContext):
        if context.read_begin("each:"):
            item = ParametrizationContextItemStatementEach()
            context.add_item(item)

            item.key = ""
            while  not context.starts_with(["#", "[", "]"]):
                item.key += context.read_first(1)
            self.finish_statement_tag(context, item.key)

            statement_close_tag_index = self.close_tag_index(context, "each")
            if statement_close_tag_index > 0:

                item.sub_section = context.read_first(statement_close_tag_index - 1)
                context.read_begin(item.sub_section)
                context.read_begin("[[#each#]]")
                self.read_sub_sections(context, item)

            return True
        return False



    def read_sub_sections(self, context: ParametrizationContext, item: ParametrizationContextItemStatementEach):
        if item.key in context.args.keys() and len(context.args[item.key]) > 0:
            values = context.args[item.key]
            index = 0
            for value in values:
                self.read_sub_section(context, item, value, index)
                index += 1



    def read_sub_section(self, context: ParametrizationContext, item: ParametrizationContextItemStatementEach, value: str, index: int):
        sub_section_args = self.sub_section_args(context, item.key, value, index)
        sub_context = ParametrizationContext(item.sub_section, sub_section_args, context.selection_reader, context.statement_reader, context.throw_on_key_validation)

        try:
            while len(sub_context.input) > 0:
                if          not sub_context.selection_reader.read_selection(sub_context) \
                        and not sub_context.statement_reader.read_statement(sub_context):
                    sub_context.result += sub_context.input[0]
                    sub_context.input   = sub_context.input[1:]
        except PeError as e:
            context.input = sub_context.input + "[[#each#]]" + context.input
            self.__handle_error(e, item.sub_section, sub_context)

        context.result += sub_context.result
        for sub_item in sub_context.items:
            context.add_item(sub_item, item)
            sub_item.input_len += len(context.input)



    def __handle_error(self, e: PeError, start_input: str, context: ParametrizationContext):
        correct_input = start_input if len(context.input) == 0 else start_input[: - len(context.input)]
        raise PeError("{}\n[{}.{}] : {}{}{}{}{}".format(
            str(e),
            len(start_input) - len(context.input),
            len(context.input),
            ColorUtils.C_WHITE,
            correct_input,
            ColorUtils.C_I_RED,
            context.input,
            ColorUtils.C_RESET))



    def sub_section_args(self, context: ParametrizationContext, key, value, index):
        values = context.args[key]
        first = "true" if index == 0                else None
        last  = "true" if (index+1) == len(values)  else None
        sub_section_args = deepcopy(context.args)
        self.args_add_value(sub_section_args, "--each-item",    value)
        self.args_add_value(sub_section_args, "--each-size",    len(values))
        self.args_add_value(sub_section_args, "--each-index",   index)
        if first:   self.args_add_value(sub_section_args, "--each-first",   first)
        if last:    self.args_add_value(sub_section_args, "--each-last",    last)
        return sub_section_args



    def args_add_value(self, args: dict, key: str, value):
        if key not in args.keys():
            args[key] = []
        args[key].insert(0, str(value))



    def close_tag_index(self, context, tag):
        tag_open = "[[#{}:".format(tag)
        tag_close = "[[#{}#]]".format(tag)
        statement_close_tag_to_find = 1
        index = 0
        while statement_close_tag_to_find > 0 and index < len(context.input):

            substr = str(context.input[index:])

            if   substr.startswith(tag_close) : statement_close_tag_to_find -= 1
            elif substr.startswith(tag_open)  : statement_close_tag_to_find += 1

            index += 1

        if statement_close_tag_to_find > 0:
            raise PeError("Statement {} close tag not found".format(tag))

        return index



    def finish_statement_tag(self, context: ParametrizationContext, input_return: str, tag = "#]]"):
        if not context.read_begin(tag):
            context.input = input_return + context.input
            raise PeError("Statement tag not closed properly with")
