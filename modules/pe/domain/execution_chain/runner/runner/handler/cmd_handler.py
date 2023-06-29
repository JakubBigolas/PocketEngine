import subprocess
from sys import stdout

from modules.pe.error import PeError
from modules.pe.domain.app_context import AppContext
from modules.pe.domain.execution_context import ExecutionContextData
from modules.pe.domain.execution_context import ExecutionContextConfig
from modules.pe.domain.parametrization_context import ParametrizationContext

from ....data.execution_chain_data import ExecutionChainData
from ....data.execution_chain_data_cmd import ExecutionChainDataCmd
from .runner_handler_abstract import RunnerHandlerAbstract


class CmdHandler(RunnerHandlerAbstract):

    def __init__(self):
        self.__parametrization_context = ParametrizationContext()



    def handle(self, app_context: AppContext, data: ExecutionContextData, chain: ExecutionChainData):
        chain: ExecutionChainDataCmd = chain
        config  = data.config
        command = self.__parametrization_context.to_parametrized_string([chain.cmd], data.args) + " " + self.__parametrization_context.to_parametrized_string(chain.params, data.args)

        self.print_command(config, command)
        self.execute(config, command)



    def accepts(self, app_context: AppContext, chain: ExecutionChainData):
        return isinstance(chain, ExecutionChainDataCmd)



    def execute(self, config: ExecutionContextConfig, command: str):
        if not config.is_dev_mode:
            result = subprocess.run(["bash"], input=command, shell=True, capture_output=False, text=True)
            if result.returncode != 0:
                raise PeError("COMMAND : exit with code {}".format(result.returncode))



    def print_command(self, config: ExecutionContextConfig, command: str):
        if config.is_dev_mode or config.is_verbose:
            print("COMMAND : {}".format(command))
            stdout.flush()
