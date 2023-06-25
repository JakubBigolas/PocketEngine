from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain.parser.execs.handler.cmd_handler import CmdHandler
from modules.pe.domain.execution_chain.parser.execs.handler.exec_handler_abstract import ExecHandlerAbstract
from modules.pe.domain.execution_chain.parser.execs.handler.stored_cmd_handler import StoredCmdHandler


class ExecResolver:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__execs_handlers = [
            CmdHandler(),
            StoredCmdHandler()
        ]



    def resolve(self, args: list) -> ExecHandlerAbstract:
        handlers = [it for it in self.__execs_handlers if it.accepts(self.__app_context, args)]
        if len(handlers) == 1:
            return handlers[0]
        else:
            raise RuntimeError("Unexpected count ({}) of exec handler for arguments \"{}\"".format(len(handlers), args))
