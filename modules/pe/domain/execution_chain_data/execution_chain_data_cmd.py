from modules.pe.domain.execution_chain_data.execution_chain_data import ExecutionChainData


class ExecutionChainDataCmd(ExecutionChainData):

    def __init__(self, args: list):
        super().__init__(args)

    @property
    def cmd(self):      return self.args[1]
    @property
    def params(self):   return self.args[2:]

