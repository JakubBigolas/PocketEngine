# PocketEngine & Engine

## PocketEntine (pe)

Main PocketEngine ("pe") purpose is to store and invoke multiple commands with configured arguments 
context as simple as it can be in one place!
It is useful if you very often need to run same commands with different parametrization. 
Write your command, replace parameters with configurable arguments and save it using name familiar for you.
Now you can set parameters and invoke your command simple and quick without any script manual management.

### Example usage: 
```bash 
pe [options...] [arguments...] - [command] [command parametrization...] -- [repeat last command with another command parametrization]
```

### Global variable configuration

- `PE_CONTEXT_PATH` 
  is context path of configs (string)

- `PE_DEV_MODE`
  use dev-mode option by default, (true|false)

- `PE_VERBOSE`
  use verbose option by default, (true|false)

### Options:

- `set`              - enable setting arguments cache sequention override previous key value if already 
  exists in cache (remove other occurrences of the same key)
- `add`              - enable adding arguments cache sequention (enabled by default) allow to add the same key in cache multiple times
- `unset`            - start removing arguments cache sequention by key name (all occurrences of key)
- `clear`            - remove all arguments from cache
- `verbose`          - print each execution command before run
- `dev-mode`         - development mode allow to see what engine will produce and run without real execution enables verbose mode by default
- `context-path`     - return path of store directory
- `help`             - print this help info and exit
- `version`          - print version info and exit


### Arguments context management options:

- `cleanup`          - remove unnamed and default argument context and exit
- `contexts`         - print simple list of all saved context names and exit
- `context-list`     - print list of all saved contexts with arguments and exit
- `context-list/*`   - print filtered list of saved contexts with arguments and exit
- `context-rm/*`     - remove named arguments context and exit
- `context`          - load saved unnamed context arguments to cache
- `context/*`        - load saved named context arguments to cache
- `c/*`              - short version of context/*
- `default`          - save all arguments cache as default context (it is performed just before first execution)
arguments stored in default context will always be loaded at the beginning
- `store`            - save all arguments cache as unnamed context (it is performed just before first execution)
- `store/*`          - save all arguments cache as specific context (it is performed just before first execution)
- `s/*`              - short version of store/*

### Executions management options:

- `execs`            - print all stored execution names and exit
- `exec-list`        - print all stored executions with caption and documentation and exit
- `exec-list/*`      - print filtered stored executions with caption and exit
- `exec-rm/*`        - remove named execution and exit

If there is need to attach some documentation for execution put in in file named same as execution file
in directory `$PE_CONTEXT_PATH/execs-docs`

### Execution chain:

- `-`                - start new command execution
- `--`               - start new execution with last command name
- `---`              - working like sequention " - run * "
- `- set`            - allow to set new arguments to cache before next execution
- `- add`            - allow to add new arguments to cache before next execution
- `- unset`          - allow to remove arguments from cache before next execution
- `- reset`          - restore arguments cache to state before start fist execution
- `- choose`         - choose arguments in cache selected by KEY, others will be removed
- `- clear`          - clear all arguments cache
- `- save-as *`      - save everything after this sequention as execution with specified name
- `- run *`          - load execution by name and execute with current arguments cache (verbose and dev-mode options are inherited)

### Arguments:
To set arguments just type them as space separated KEY VALUE pairs or KEY=VALUE pair or just KEY.</br>
If argument starts with character '-' it is always treated as KEY (even if there was key before).</br>
If KEY has character '=' then another argument will be treated as KEY too (even if it looks like value).</br>
If there is need to put KEY that will not be present in execution (like id for choosing params) then use 
pattern [#...] and everything after it will be VALUE (if it not starts with '-') even if another value is 
written same way.</br>
If there is need to put something more complex put it in quotes.</br>
NOTICE: if unset mode is enabled then everything is treated as key and if there is value associated with key it will be removed too.</br>
Finally each KEY, VALUE or execution element (except first element) will be wrapped in quotes excluding internal KEY`s.

Example of possible combinations KEY VALUE set:
- `KEY`
- `-KEY`
- `-KEY VALUE`
- `-KEY -KEY VALUE`
- `-KEY VALUE KEY`
- `-KEY=VALUE KEY`
- `-KEY VALUE_LOOKS_LIKE_KEY=VALUE`
- `KEY VALUE -KEY [#INTERNAL_KEY] #[VALUE_LOOKS_LIKE_KEY]`

### Command parametrization:
By default, all arguments from cache are placed just between command, and it's parametrization.
But it is possible to make command parametrization more complex.
If there is need to put arguments in specific way, this replacement form may be used:

- Form "Find value for key and replace it with, or if there is no value then..."
  - `<<#?key#>>`                 ...ommit
  - `<<#key#>>`                  ...use empty string
  - `<<#key:?orElse#>>`          ...use orElse
  - `<<#!key#>>`                 ...finish with error


- Form "Find key and replace it with, or if there is no such key then..."
  - <<##?key##>>`               ...ommit
  - <<##key##>>`                ...use empty string
  - <<##key?:orElse##>>`        ...use orElse
  - <<##!key##>>`               ...finish with error


- Form "Find key and replace it with replacement, or if there is no key then...
  - `<<##?key|replacement##>>`   ...ommit
  - `<<##key|replacement##>>`    ...use empty string


- Form "Find key and repeat replacement for each occurance of key":
  - `<<###each:key###>> ... repeatable content ... <<###each!###>>` </br>
  In each iteration in this loop only one occurrence of key is available in cache 
  and some additional parameters:
  - `--each-size`               count of all occurrences of key
  - `--each-index`              current occurrence of key
  - `--each-first`              appears only for first occurrence with single space value
  - `--each-last`               appears only for last occurrence with single space value




## Engine (engine) 

# THIS PROJECT IS STILL IN VERY DEVELOPMENT STAGE

Engine is simple tool to create and manage bash script projects.
Allows to split and test code in very many files. 

Engine by itself is not an "engine" project so if there is need to make some modification/fixes,
you need to compile its sources manually, like that:

```bash
# go to engine direcotry
cd [...]/PocketEngine/engine

# compile all files in one script
echo "" > engine.sh   ;   for f in `ls bin` ; do echo "# $f" >> engine.sh ; cat "bin/$f" >> engine.sh ; echo "" >> engine.sh ; done   ;   echo "engine \"\$@\"" >> engine.sh
```

If you need to use `engine` as command line program
add path `[...]/PocketEngine/engine` to `path` system variable 
and make file `[...]/PocketEngine/engine/engine` executable.

To build only engin-embed.sh file use script like this:

```bash
# go to engine direcotry
cd [...]/PocketEngine/engine

# run script to get function and print its result to engine-embed.sh
. bin/engine-embed.sh && engineEmbed > engine-embed.sh
```

## Main "Engine" projects rules and best practices:

- use `.../<project>/config/config.sh` file for global variables configuration
- use `.../<project>/config/config-<profile>.sh` file for global variables configuration for specific build profile
- starting point of script is in script `.../<project>/scr/main/script/main.sh`
- directory `.../<project>/src/main` is for sources specific in your project
- directory `.../<project>/src/main/script` is for script code specific for your project
- directory `.../<project>/src/test` is for test sources specific in your project
- directory `.../<project>/src/test/script` is for script test code specific for your project
- directory `.../<project>/libs` works like `.../<project>/src` but should contain only library files
- directory `.../<project>/engine` is only for "Engine" mechanism files (like engine-embed.sh)
it is not required to embed "Engine" in this directory if project has linked "global" engine.
- every `.../script/*` directory requires `index` file to be included by "Engine" in compilation code process
- empty `index` file means "load all content from it`s directory"
- every test file should be named as tested main file with suffix ".test" or ".spec"

## Best practices working with "Engine" project
- it is recommended to specify files/dirs in `index` file for better performance
- it is recommended to store only one function in one file
- it is recommended to prefix every file with package name (package name is path starting after .../script/ dir) 
- it is recommended to name file in camelCase
- it is recommended to name function same as file

### Usage:

```bash
engine [args...] [option]
```

### Arguments:

 - `-p`            - allow to specify project path (by default is current cmd path)

### Options:

- `create project PROJECT_NAME alias ALIAS` </br> 
  Create project in specific path where:
  - `PROJECT_NAME` is project specific name that will be used for directory name 
  - `ALIAS` is main script name that will be used as command name, this keyword is optional

- `index update [args...]`</br> 
  Update all index files in project, by default only add new positions to index.</br>
  Arguments:
  - `-c`              - create index file if not appears in directory
  - `-r`              - remove positions from index if there is no matching src
- `index check`       - check index files structure
- `index add`         - add new file to project
- `index add test`    - add new test file to project
- `index remove`      - remove file from project
- `index remove test` - remove test file from project
- `build VERSION`     - build project to one single script, `VERSION` allow to add subdirectory with version name for build
