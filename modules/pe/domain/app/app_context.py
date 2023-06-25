import os
import re


class AppContext:

    def __init__(self, context_path: str, sub_execution):
        self.__project_dir      = context_path
        self.__sub_execution    = sub_execution
        self.__context_dir      = context_path + "/context"
        self.__execs_dir        = context_path + "/execs"
        self.__execs_docs_dir   = context_path + "/execs-docs"
        os.makedirs(self.__context_dir   , exist_ok=True)
        os.makedirs(self.__execs_dir     , exist_ok=True)
        os.makedirs(self.__execs_docs_dir, exist_ok=True)

    @property
    def sub_execution(self):                return self.__sub_execution



    def get_context_project_dir(self):
        return self.__context_dir



    def contexts_list(self):
        return os.listdir(self.__context_dir)

    def load_context(self, context):
        return self.__load_file(self.__context_dir, context)

    def save_context(self, context, text):
        self.__save_file(self.__context_dir, context, text)

    def remove_context(self, context):
        self.__remove_file(self.__context_dir, context)



    def execs_list(self):
        return os.listdir(self.__execs_dir)

    def load_exec(self, exec):
        result = self.__load_file(self.__execs_dir, exec)
        result = re.sub("\n+", "\n", result)
        result = re.sub("\\\\\n\s*", " ", result)
        return result

    def save_exec(self, exec, text):
        self.__save_file(self.__execs_dir, exec, text)

    def remove_exec(self, exec):
        self.__remove_file(self.__execs_dir, exec)



    def load_exec_doc(self, exec_doc):
        return self.__load_file(self.__execs_docs_dir, exec_doc)

    def save_exec_doc(self, exec_doc, text):
        self.__save_file(self.__execs_docs_dir, exec_doc, text)

    def remove_exec_doc(self, exec_doc):
        self.__remove_file(self.__execs_docs_dir, exec_doc)



    def __load_file(self, path, fname):
        try:
            file = open(path + "/" + fname, "rt")
            result = file.read() if file.readable() else None
            file.close()
            return result
        except:
            return None

    def __save_file(self, path, fname, text):
        file = open(path + "/" + fname, "wt")
        file.write(text)
        file.close()

    def __remove_file(self, path, fname):
        try:
            os.remove(path + "/" + fname)
        except:
            pass
