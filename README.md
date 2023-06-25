#  PocketEntine (pe)

Main PocketEngine ("pe") purpose is to store and invoke multiple commands with configured arguments
context as simple as it can be in one place!
It is useful if you very often need to run same commands with different parametrization.
Write your command, replace parameters with configurable arguments and save it using name familiar for you.
Now you can set parameters and invoke your command simple and quick without any script manual management.

## Example usage:
```bash 
pe [options...] [context arguments...] - [command] [command parametrization...] ...
pe [options...] [arguments...] -- [stored command] [context arguments...] ...
```

## Global variable configuration

Configurable both in system variables and file .../PocketEngine/config.py

- `PE_CONTEXT_PATH` 
  is context path of configs (string)

- `PE_DEV_MODE`
  use dev-mode option by default, (true|false)

- `PE_VERBOSE`
  use verbose option by default, (true|false)

## Options:

- `set`              - enable setting arguments cache sequention NOTICE: at least there will be only one value for key
- `add`              - enable adding arguments cache sequention (enabled by default) allow to add the same key in cache multiple times
- `unset`            - start removing arguments cache sequention by key name (all occurrences of key)
- `clear`            - remove all arguments from cache
- `verbose`          - print each execution command before run
- `dev-mode`         - development mode allow to see what engine will produce and run, without real execution enables verbose mode by default
- `context-path`     - return path of store directory
- `help`             - print this help info and exit
- `version`          - print version info and exit

## Arguments context management options:

- `contexts`         - print simple list of all saved context names and exit
- `context-list`     - print simple list of all saved contexts with arguments and exit
- `context-list/*`   - print extended filtered list of saved contexts with arguments and exit
- `context-rm/*`     - remove named arguments context and exit
- `context`          - load saved unnamed context arguments to cache
- `context/*`        - load saved named context arguments to cache
- `c/*`              - short version of context/*
- `default`          - save all arguments cache as default context  (it is performed just before first execution)
- `store`            - save all arguments cache as unnamed context  (it is performed just before first execution)
- `store/*`          - save all arguments cache as specific context (it is performed just before first execution)
- `s/*`              - short version of store/*

## Executions management options:

- `save-as *`        - save whole execution chain as specified name
- `execs`            - print all stored execution names and exit
- `exec-list`        - print all stored executions with simple content and exit
- `exec-list/*`      - print filtered stored executions with extended content and exit
- `exec-rm/*`        - remove named execution and exit

If there is need to attach some documentation for execution put in in file named same as execution file
in directory `$PE_CONTEXT_PATH/execs-docs`

## Execution chain:

-                 start new command execution chain
--                load execution chain by name
execute with current arguments cache (verbose option is inherited)
and additional param list passed after execution name

- `-`                - start new command execution chain
- `--`               - load execution chain by name execute with current arguments cache (verbose option is inherited) and additional param list passed after execution name

## Arguments:

To set arguments just type them as space separated KEY VALUE pairs or KEY=VALUE pair or just KEY.
If argument starts with character '-' it is always treated as KEY (even if there was key before).
If KEY has character '=' then another argument will be treated as KEY too (even if it looks like value).
NOTICE: if unset mode is enabled then everything is treated as key and if there is value associated with key it will be removed too.
Each KEY, VALUE or execution element (except first element) will be wrapped in quotes excluding internal KEYs

## Command parametrization:

- Selection form: get all arguments from context...
  - `<<#@#>>`          ...and return

- Selection form: find X in arguments context and...
  - `<<#X#>>`                         ...return
  - `<<#X?:OR_ELSE>>`                 ...return or if X not exists return OR_ELSE
  - `<<#X->REPLACEMENT#>>`            ...replace it with REPLACEMENT and return
  - `<<#X->REPLACEMENT?:OR_ELSE>>`    ...replace it with REPLACEMENT and return or if X not exists return OR_ELSE

Where
  - `REPLACEMENT` and `OR_ELSE` are just string or another selection form
  - Where `X` is
    - `key`           just key
    - `key[*]`        value (concatenated values) for key
    - `key[@]`        count of values for key
    - `key[index]`    value for key at specified index
    - `!key`          key or error if there is no key
    - `!key[...]`     key value or error if there is no key or value

Selection form: find values for key in arguments context and repeat internal section for each value
- `[[#each:key#]] repeatable content [[#each#]]`
  - Each loop add some additional arguments to context:
    - --each-item            current item of loop
    - --each-index           current index of loop
    - --each-size            count of all items of loop
    - --each-first           true for first otherwise non included
    - --each-last            true for last element otherwise non included
  - NOTICE: if loops are nested, each additional "loop argument" will be treated as array and
            these arguments are ordered beginning from most nested to first loop occurrence


