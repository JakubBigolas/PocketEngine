

class ExecutionContextConfig:

    def __init__(self, verbose: bool, dev_mode: bool):

        # if true then every command will be printed before evaluation
        self.__verbose = verbose
        # development mode enforces verbose mode and disable command evaluation
        self.__dev_mode = dev_mode
        # enable setting arguments mode
        self.__set_args_enabled = True
        # enable adding arguments mode
        self.__add_args_enabled = True
        # if true then arguments will be stored just before first execution
        self.__store_args = False
        # if true then arguments will bo stored as default, just before first execution
        self.__store_default_args = False
        # argument contest store file name, default "context"
        self.__context_file = "context"
        # if set to non-empty string all executions will be stored instead of executed
        self.__save_as_command = None

        # flag to prevent context modification
        # if true only current args and execution chain may be modified
        self.__args_commited = False

    ### PROPERTIES #################################################################################

    @property
    def context_file(self):             return self.__context_file
    @property
    def is_verbose(self):               return self.__verbose
    @property
    def is_dev_mode(self):              return self.__dev_mode
    @property
    def is_set_args_enabled(self):      return self.__set_args_enabled
    @property
    def is_add_args_enabled(self):      return self.__add_args_enabled
    @property
    def is_store_args(self):            return self.__store_args
    @property
    def is_store_default_args(self):    return self.__store_default_args
    @property
    def commited(self):         return self.__args_commited
    @property
    def save_as_command(self):          return self.__save_as_command

    ### BUSINESS LOGIC #################################################################################


    def unset(self):
        self.__set_args_enabled = False
        self.__add_args_enabled = False



    def set(self):
        self.__set_args_enabled = True
        self.__add_args_enabled = False



    def add(self):
        self.__set_args_enabled = True
        self.__add_args_enabled = True



    def commit_args(self):
        if not self.__args_commited:
            self.__args_commited = True
        else:
            self.__check_modifiability()



    def verbose(self):
        self.__check_modifiability()
        self.__verbose = True



    def dev_mode(self):
        self.__check_modifiability()
        self.verbose()
        self.__dev_mode = True



    def store(self, name: str):
        self.__check_modifiability()
        self.__store_args = True
        if name:
            self.__context_file = name



    def default(self):
        self.__check_modifiability()
        self.__store_default_args = True



    def save_as(self, save_as: str):
        self.__check_modifiability()
        self.__save_as_command = save_as



    def __check_modifiability(self):
        if self.__args_commited:
            raise RuntimeError("Execution context is unmodifiable after arguments commit")

