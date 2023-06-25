class ExecutionContextDataHelper:

    def add_or_put_key_value(self, args: dict, add_args_enabled: bool, key: str, value: str):
        args.setdefault(key, [])
        if add_args_enabled:
            args[key].append(value)
        else:
            args[key] = [value]


    def add_or_put_or_unset_key_value(self, args: dict, set_args_enabled: bool, add_args_enabled: bool, key: str, value: str):
        if set_args_enabled:
            self.add_or_put_key_value(args, add_args_enabled, key, value)
        else:
            args.pop(key)


