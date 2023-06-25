from modules.pe.domain.error import PeError
from modules.pe.domain.execution_chain_data.execution_chain_data import ExecutionChainData


class ExecutionChain:

    def __init__(self):
        self.__head: ExecutionChainData = None
        self.__tail: ExecutionChainData = None
        self.__commited = False

    @property
    def head(self):     return self.__head
    @property
    def tail(self):     return self.__tail
    @property
    def commited(self): return self.__commited



    def commit(self):
        self.check_modifability()
        self.__commited = True
        if self.__tail:
            self.__tail.commit()



    def add(self, chain_data: ExecutionChainData):
        self.check_modifability()
        if chain_data:
            if self.__head is None:
                self.__tail = self.__head = chain_data
            else:
                self.__check_loop_error(chain_data)
                self.__tail.finish_and_next(chain_data)
                self.__tail = chain_data

    def __check_loop_error(self, chain_data: ExecutionChainData):
        it = self.__head
        while it is not None:
            if it == chain_data:
                raise PeError("Cannot add the same instance of execution to chain")
            it = it.next



    def check_modifability(self):
        if self.__commited:
            raise PeError("Execution chain is unmodifiable after commit")
