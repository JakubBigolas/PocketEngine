from modules.pe.domain.app_context import AppContext
from modules.pe.error import PeError

from ...data.execution_context_data import ExecutionContextData
from .handler.args_handler_abstract import ArgsHandlerAbstract
from .handler.no_option_handler import NoOptionHandler
from .handler.option_start_execution_handler import OptionStartExecutionHandler
from .handler.option_help_handler import OptionHelpHandler
from .handler.option_version_handler import OptionVersionHandler
from .handler.option_dev_mode_handler import OptionDevModeHandler
from .handler.option_verbose_handler import OptionVerboseHandler
from .handler.option_contexts_handler import OptionContextsHandler
from .handler.option_context_list_handler import OptionContextListHandler
from .handler.option_context_rm_handler import OptionContextRmHandler
from .handler.option_context_handler import OptionContextHandler
from .handler.option_store_handler import OptionStoreHandler
from .handler.option_default_handler import OptionDefaultHandler
from .handler.option_set_handler import OptionSetHandler
from .handler.option_unset_handler import OptionUnsetHandler
from .handler.option_add_handler import OptionAddHandler
from .handler.option_clear_handler import OptionClearHandler
from .handler.option_context_path_handler import OptionContextPathHandler
from .handler.option_cleanup_handler import OptionCleanupHandler
from .handler.option_execs_handler import OptionExecsHandler
from .handler.option_exec_rm_handler import OptionExecRmHandler
from .handler.option_exec_list_handler import OptionExecListHandler
from .handler.option_save_as_handler import OptionSaveAsHandler


class ArgsResolver:

    def __init__(self, app_context: AppContext):
        self.__app_context = app_context
        self.__args_handlers = [
            OptionHelpHandler(),
            OptionVersionHandler(),
            OptionDevModeHandler(),
            OptionVerboseHandler(),
            OptionContextsHandler(),
            OptionContextListHandler(),
            OptionContextRmHandler(),
            OptionContextHandler(),
            OptionStoreHandler(),
            OptionDefaultHandler(),
            OptionSetHandler(),
            OptionUnsetHandler(),
            OptionAddHandler(),
            OptionClearHandler(),
            OptionContextPathHandler(),
            OptionCleanupHandler(),
            OptionExecsHandler(),
            OptionExecRmHandler(),
            OptionExecListHandler(),
            OptionStartExecutionHandler(),
            OptionSaveAsHandler()
        ]
        self.__no_option_handler = NoOptionHandler()
        self.__start_execution_handler: OptionStartExecutionHandler = None



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
