from modules.pe.domain.app_context import AppContext
from modules.pe.error import PeError
from ....data.execution_chain_data_stored_cmd import ExecutionChainDataStoredCmd
from ....data.execution_chain_data import ExecutionChainData
from .exec_handler_abstract import ExecHandlerAbstract


class StoredCmdHandler(ExecHandlerAbstract):



    def handle(self, app_context: AppContext, args: list) -> ExecutionChainData:
        if not args[1] in app_context.execs_list():
            raise PeError("There is no stored execution named {}".format(args[1]))
        data = ExecutionChainDataStoredCmd(args)
        return data



    def accepts(self, app_context: AppContext, args: list) -> bool:
        return args and len(args) > 0 and args[0] == "--"
