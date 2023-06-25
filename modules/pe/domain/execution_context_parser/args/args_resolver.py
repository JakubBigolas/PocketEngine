from modules.pe.domain.execution_context_parser.args.handler import *
from modules.pe.domain.error import PeError
from modules.pe.domain.execution_context_data import ExecutionContextData
from modules.pe.domain.execution_context_parser.args.handler import ArgsHandlerAbstract


class ArgsResolver:

    def __init__(self, app_context: AppContext):
        self.__args_handlers = []
        self.inject_args_handlers()
        self.__no_option_handler = NoOptionHandler()
        self.__start_execution_handler: OptionStartExecutionHandler = None
        self.__app_context = app_context



    def inject_args_handlers(self):
        for name, obj in globals().items():
            if isinstance(obj, type) and issubclass(obj, ArgsHandlerAbstract) and obj != ArgsHandlerAbstract:
                self.__args_handlers.append(obj())



    def resolve(self, data: ExecutionContextData, args: list) -> ArgsHandlerAbstract:

        # by default
        # if execution has been started before, add rest arguments to unhandled list
        handler = self.__start_execution_handler

        if handler is None:
            handler = self.find_handler(data, args)

            # if there is handler
            if handler:

                # if execution has been started, make rest arguments as unhandled
                if isinstance(handler, OptionStartExecutionHandler):
                    self.__start_execution_handler = handler

                # or if there is key in cache try to add it to context with this arg as value
                elif len(data.unhandled_args) > 0:
                    handler = self.__no_option_handler

            # if there is no handler for arg, add arg to argument context cache
            else:
                handler = self.__no_option_handler

        return handler



    def find_handler(self, data: ExecutionContextData, args: list) -> ArgsHandlerAbstract:
        handlers = [handler for handler in self.__args_handlers if handler.accepts(self.__app_context, data, args)]

        if len(handlers) > 1:
            raise PeError("Too much handlers for args {}".format(args))

        elif len(handlers) == 1:
            return handlers[0]
