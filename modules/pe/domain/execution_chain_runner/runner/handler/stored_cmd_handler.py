import subprocess
import uuid
from sys import stdout

from modules.pe.domain.app import AppContext
from modules.pe.domain.execution_chain import ExecutionChain
from modules.pe.domain.execution_chain_data import ExecutionChainData, ExecutionChainDataStoredCmd
from modules.pe.domain.execution_chain_runner.runner.handler import RunnerHandlerAbstract
from modules.pe.domain.execution_context import ExecutionContext
from modules.pe.domain.execution_context_data.execution_context_config import ExecutionContextConfig

class StoredCmdHandler(RunnerHandlerAbstract):



    def handle(self, app_context: AppContext, context: ExecutionContext, chain: ExecutionChain, chain_data: ExecutionChainData):
        stored_cmd_chain_data: ExecutionChainDataStoredCmd = chain_data
        app         = app_context.sub_execution()
        args        = self.build_args(context, stored_cmd_chain_data)
        exec        = self.load_exec(app_context, stored_cmd_chain_data)
        exec_uuid   = self.print_start_sub_execution(context.data.config, args, exec, stored_cmd_chain_data)
        app.execute(args + exec)
        self.print_end_sub_execution(context.data.config, exec_uuid, stored_cmd_chain_data)



    def accepts(self, app_context: AppContext, chain_data: ExecutionChainData):
        return isinstance(chain_data, ExecutionChainDataStoredCmd)



    def print_start_sub_execution(self, config: ExecutionContextConfig, args: list, exec: list, chain_data: ExecutionChainDataStoredCmd) -> uuid:
        exec_uuid = uuid.uuid4()
        if config.is_verbose or config.is_dev_mode:
            print("START STORED EXECUTION : {} ({})".format(chain_data.execution_name, exec_uuid))
            print("EXECUTION CHAIN        : {}".format(exec))
            print("WITH ARGS              : {}".format(args))
            stdout.flush()
        return exec_uuid



    def print_end_sub_execution(self, config: ExecutionContextConfig, exec_uuid: uuid, chain_data: ExecutionChainDataStoredCmd):
        if config.is_verbose or config.is_dev_mode:
            print("END STORED EXECUTION   : {} ({})".format(chain_data.execution_name, exec_uuid))
            stdout.flush()



    def load_exec(self, app_context: AppContext, chain_data: ExecutionChainDataStoredCmd):
        exec_str = app_context.load_exec(chain_data.execution_name)
        if exec_str and len(exec_str) > 0:
            return exec_str.split("\n")
        else:
            return list()



    def build_args(self, context: ExecutionContext, chain_data: ExecutionChainDataStoredCmd) -> list:
        result  = list()
        config  = context.data.config
        args    = context.data.args

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
