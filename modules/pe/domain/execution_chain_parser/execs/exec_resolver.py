from modules.pe.domain.execution_chain_parser.execs.handler import *

from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_chain_parser.execs.handler.exec_handler_abstract import ExecHandlerAbstract


class ExecResolver:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__execs_handlers = []
        self.inject_execs_handlers()



    def inject_execs_handlers(self):
        for name, obj in globals().items():
            if isinstance(obj, type) and issubclass(obj, ExecHandlerAbstract) and obj != ExecHandlerAbstract:
                self.__execs_handlers.append(obj())



    def resolve(self, args: list) -> ExecHandlerAbstract:
        handlers = [it for it in self.__execs_handlers if it.accepts(self.__app_context, args)]
        if len(handlers) == 1:
            return handlers[0]
        else:
            raise RuntimeError("Unexpected count ({}) of exec handler for arguments \"{}\"".format(len(handlers), args))
