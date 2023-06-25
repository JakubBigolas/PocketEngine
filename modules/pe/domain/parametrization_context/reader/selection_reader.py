from modules.pe.domain.parametrization_context.data.parametrization_context_data import ParametrizationContextData
from modules.pe.domain.parametrization_context.data.parametrization_context_item_selection import ParametrizationContextItemSelection
from modules.pe.domain.parametrization_context.data.parametrization_context_item_selection_all import ParametrizationContextItemSelectionAll
from modules.pe.error import PeError


class SelectionReader:


    # <<#@#>>                       return all context args
    # <<#X#>>                       return selection
    # <<#X->replacement#>>          return replacement if selection exists
    # <<#X->replacement?:orElse>>   return orElse if there is no selection or replacement if selection exists
    # <<#X?:orElse>>                return orElse if there is no selection
    # Where X is
    # key        key
    # key[*]     value (values) for key
    # key[@]     count of values for key
    # key[2]     second value for key
    # !key       error if there is no key
    # !key[...]  error if there is no key or value



    def read_selection(self, context: ParametrizationContextData) -> bool:
        if context.read_begin("<<#@"):
            context.add_item(ParametrizationContextItemSelectionAll())

            self.read_selection_done(context)
            context.result += self.concat_args(context.args)
            return True

        if context.read_begin("<<#"):
            item = ParametrizationContextItemSelection()
            context.add_item(item)

            item.required       = context.read_begin("!")
            item.key            = self.read_key(context)
            item.count          = context.read_begin("[@]")
            item.concat         = context.read_begin("[*]")
            item.item           = self.read_selection_key_array_index(context)
            item.replacement    = self.read_sub_selection(context, "->", [":?", "#", ">"], item)  # self.read_selection_replacement(context)
            item.or_else        = self.read_sub_selection(context, ":?", ["#", ">"], item)  # self.read_selection_or_else(context)

            self.validate_key(context, item)
            self.read_selection_done(context)
            self.evaluate_key(context, item)

            return True

        return False



    def read_selection_done(self, context: ParametrizationContextData):
        if not context.read_begin("#>>"):
            raise PeError("Selection not closed properly")



    def evaluate_key(self, context: ParametrizationContextData, item: ParametrizationContextItemSelection):
        if item.key in context.args.keys():
            values = context.args[item.key]

            if      item.count            : item.key = str(len(values))
            elif    item.concat           : item.key = self.concat_args_values(values)
            elif    item.item is not None : item.key = values[item.item] if item.item < len(values) else None

            if      item.key is not None  : context.result += item.key if item.replacement is None else item.replacement

        elif item.or_else is not None:
            context.result += item.or_else



    def validate_key(self, context: ParametrizationContextData, item: ParametrizationContextItemSelection):
        if item.required and context.throw_on_key_validation:
            if item.key not in context.args.keys():
                raise PeError("Missing required key '{}'!".format(item.key))
            if item.item and len(context.args[item.key]) < (item.item + 1):
                raise PeError("Missing required item '{}' for key '{}'".format(item, item.key))
            if item.concat and len(context.args[item.key]) == 0:
                raise PeError("Missing required items for key '{}; to concat!".format(item.key))



    def read_key(self, context: ParametrizationContextData):
        key = ""

        while not context.starts_with(["->", ":?", "#", "]", "[", ">"]):
            key += context.read_first(1)

        if key == "":
            raise PeError("missing key in expression")

        return key



    def read_selection_key_array_index(self, context: ParametrizationContextData):
        index = None
        if context.read_begin("["):

            while context.starts_with(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]):
                index = ((0 if index is None else index) * 10) + int(context.read_first(1))

            if not context.read_begin("]"):
                raise PeError("Incorrect item selection!")

        return index



    def read_sub_selection(self, context: ParametrizationContextData, begin: str, end: list, item: ParametrizationContextItemSelection):
        if context.read_begin(begin):

            sub_selection = ""
            while not context.starts_with(end):
                sub_selection += self.sub_read(context, item)

            return sub_selection
        return None



    def sub_read(self, context: ParametrizationContextData, item: ParametrizationContextItemSelection) -> str:
        sub_context = context.new_data(context.input, context.args, context.throw_on_key_validation)
        try:

            if         sub_context.selection_reader.read_selection(sub_context) \
                    or sub_context.statement_reader.read_statement(sub_context):
                context.input = sub_context.input
                for sub_item in sub_context.items:
                    context.add_item(sub_item, item)
                return sub_context.result
            else:
                return context.read_first(1)

        except PeError as e:
            context.input = sub_context.input
            raise e



    def concat_args(self, args):
        result = ""

        for key in args:
            values = args[key]
            if values and len(values) > 0:
                for value in values:
                    result += "{} {} ".format(key, value)
            else:
                result += "{} ".format(key)

        return result if len(result) == 0 else result[:-1]



    def concat_args_values(self, values):
        result = ""

        if values and len(values) > 0:
            for value in values:
                result += "{} ".format(value)

        return result if len(result) == 0 else result[:-1]
