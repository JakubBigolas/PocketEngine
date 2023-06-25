from copy import deepcopy



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
        self.__next = next
        self.commit()

        next.prev = self




    def commit(self):
        self.__check_modifiability()
        self.__commited = True



    def __check_modifiability(self):
        if self.__commited:
            raise RuntimeError("Execution is unmodifiable after commit")
