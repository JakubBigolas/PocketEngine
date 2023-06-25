from copy import deepcopy

from modules.pe.error import PeError


class ExecutionChainData:

    def __init__(self, args: list):
        self.__prev = None
        self.__next = None
        self.__args = args
        self.__commited = False

    @property
    def prev(self):         return self.__prev
    @property
    def next(self):         return self.__next
    @property
    def args(self):         return deepcopy(self.__args)
    @property
    def commited(self):     return self.__commited

    @prev.setter
    def prev(self, prev):
        self.__prev = prev



    def finish_and_next(self, next):
        self.__check_modifiability()
        self.__check_loop_error(next)
        self.__next = next
        next.prev = self
        self.commit()



    def commit(self):
        self.__check_modifiability()
        self.__commited = True



    def __check_modifiability(self):
        if self.__commited:
            raise RuntimeError("Execution chain element is unmodifiable after commit")



    def __check_loop_error(self, chain):
        head = self
        while head.prev:
            head = head.prev

        while head is not None:
            if head == chain:
                raise PeError("Cannot add the same instance of execution to chain")
            head = head.next
