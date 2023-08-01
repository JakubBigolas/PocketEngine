import uuid
from sys import stdout

from modules.pe.domain.app_context import AppContext
from modules.pe.utils import ColorUtils
from modules.pe.domain.execution_context import ExecutionContextData
from modules.pe.domain.execution_context import ExecutionContextConfig
from ....data.execution_chain_data import ExecutionChainData
from ....data.execution_chain_data_stored_cmd import ExecutionChainDataStoredCmd
from .runner_handler_abstract import RunnerHandlerAbstract


class StoredCmdHandler(RunnerHandlerAbstract):


    def handle(self, app_context: AppContext, data: ExecutionContextData, chain: ExecutionChainData):
        chain: ExecutionChainDataStoredCmd = chain
        app         = app_context.sub_execution()
        args        = self.build_args(data, chain)
        exec        = self.load_exec(app_context, chain)
        exec_uuid   = self.print_start_sub_execution(data.config, args, exec, chain)
        app.execute(args + exec)
        self.print_end_sub_execution(data.config, exec_uuid, chain)



    def accepts(self, app_context: AppContext, chain: ExecutionChainData):
        return isinstance(chain, ExecutionChainDataStoredCmd)



    def print_start_sub_execution(self, config: ExecutionContextConfig, args: list, exec: list, chain_data: ExecutionChainDataStoredCmd) -> uuid:
        exec_uuid = uuid.uuid4()

        args_line = ""
        for arg in args:
            if arg is not None:
                args_line += arg + " "
        if len(args_line) > 0   : args_line = args_line[:-1]

        exec_line = ""
        for ex in exec          : exec_line += ex + " "
        if len(exec_line) > 0   : exec_line = exec_line[:-1]

        if config.is_verbose or config.is_dev_mode:
            print(f"START STORED EXECUTION : {chain_data.execution_name} {ColorUtils.C_BLUE}{exec_uuid}{ColorUtils.C_RESET}")
            print(f"EXECUTION CHAIN        : {exec_line}")
            print(f"WITH ARGS              : {args_line}")
            stdout.flush()
        return exec_uuid



    def print_end_sub_execution(self, config: ExecutionContextConfig, exec_uuid: uuid, chain_data: ExecutionChainDataStoredCmd):
        if config.is_verbose or config.is_dev_mode:
            print(f"END STORED EXECUTION   : {chain_data.execution_name} {ColorUtils.C_BLUE}{exec_uuid}{ColorUtils.C_RESET}")
            stdout.flush()



    def load_exec(self, app_context: AppContext, chain_data: ExecutionChainDataStoredCmd):
        exec_str = app_context.load_exec(chain_data.execution_name)
        if exec_str and len(exec_str) > 0:
            return exec_str.split("\n")
        else:
            return list()



    def build_args(self, data: ExecutionContextData, chain_data: ExecutionChainDataStoredCmd) -> list:
        result  = list()
        config  = data.config
        args    = data.args

        self.inherit_dev_mode(config, result)
        self.inherit_verbose(config, result)
        self.pass_context_args(args, result)
        self.pass_chain_args(chain_data, result)

        return result



    def inherit_dev_mode(self, config: ExecutionContextConfig, result: list):
        if config.is_dev_mode:
            result.append("dev-mode")



    def inherit_verbose(self, config: ExecutionContextConfig, result: list):
        if config.is_verbose:
            result.append("verbose")



    def pass_context_args(self, args: dict, result: list):
        if len(args) > 0:
            for arg in args:
                key = arg
                values = args[key]
                if len(values) > 0:
                    for value in values:
                        result.append(key)
                        result.append(value)
                else:
                    result.append(key)



    def pass_chain_args(self, chain_data: ExecutionChainDataStoredCmd, result: list):
        if chain_data.params:
            for param in chain_data.params:
                result.append(param)
