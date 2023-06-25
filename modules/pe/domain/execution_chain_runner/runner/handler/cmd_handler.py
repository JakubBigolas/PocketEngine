import subprocess
from sys import stdout

from modules.pe.domain.app import AppContext
from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain import ExecutionChain
from modules.pe.domain.execution_chain_data import ExecutionChainData, ExecutionChainDataCmd
from modules.pe.domain.execution_chain_runner.runner.handler import RunnerHandlerAbstract
from modules.pe.domain.execution_context import ExecutionContext
from modules.pe.domain.execution_context_data.execution_context_config import ExecutionContextConfig


class CmdHandler(RunnerHandlerAbstract):



    def handle(self, app_context: AppContext, context: ExecutionContext, chain: ExecutionChain, chain_data: ExecutionChainData):
        cmd_chain_data: ExecutionChainDataCmd = chain_data

        data    = context.data
        config  = data.config

        command = self.helper.parametrized([cmd_chain_data.cmd], data.args) + " " + self.helper.parametrized(cmd_chain_data.params, data.args)

        self.print_command(config, command)
        self.execute(config, command)



    def accepts(self, app_context: AppContext, chain_data: ExecutionChainData):
        return isinstance(chain_data, ExecutionChainDataCmd)



    def execute(self, config: ExecutionContextConfig, command: str):
        if not config.is_dev_mode:
            result = subprocess.run(["bash"], input=command, shell=True, capture_output=False, text=True)
            if result.returncode != 0:
                PeError("Command {} finished with error code {}".format(command, result.returncode))



    def print_command(self, config: ExecutionContextConfig, command: str):
        if config.is_dev_mode or config.is_verbose:
            print("COMMAND : {}".format(command))
            stdout.flush()
