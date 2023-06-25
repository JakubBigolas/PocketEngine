from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_chain.data.execution_chain_data import ExecutionChainData
from modules.pe.domain.execution_chain.data.execution_chain_data_cmd import ExecutionChainDataCmd
from modules.pe.domain.execution_chain.parser.execs.handler.exec_handler_abstract import ExecHandlerAbstract


class CmdHandler(ExecHandlerAbstract):



    def handle(self, app_context: AppContext, args: list) -> ExecutionChainData:
        data = ExecutionChainDataCmd(args)
        return data



    def accepts(self, app_context: AppContext, args: list) -> bool:
        return args and len(args) > 1\
               and args[0] == "-"\
               and args[1] not in ["set", "add", "unset", "reset", "choose", "clear"]