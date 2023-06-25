function peOptionHelp {
  echo -e "PocketEngine (pe)"
  echo
  echo -e "Main PocketEngine purpose is to store and invoke multiple commands with configured arguments"
  echo -e "context as simple as it can be in one place!"
  echo -e "It is useful if you very often need to run same commands with different parametrization."
  echo -e "Write your command, replace parameters with configurable arguments and save it using name familiar for you."
  echo -e "Now you can set parameters and invoke your command simple and quick without any script manual management."
  echo
  echo -e "Usage: pe [options...] [arguments...] - [command] [command parametrization...] -- [repeat last command with another command parametrization]"
  echo -e ""
  echo -e "Options:"
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'set'              'enable setting arguments cache sequention'
  pdToolHelpOptionPrint ''                 'override previous key value if already exists in cach'
  pdToolHelpOptionPrint 'add'              'enable adding arguments cache sequention (enabled by default)'
  pdToolHelpOptionPrint ''                 'allow to add the same key in cache multiple times'
  pdToolHelpOptionPrint 'unset'            'start removing arguments cache sequention by key name (all occurrences of key)'
  pdToolHelpOptionPrint 'clear'            'remove all arguments from cache'
  pdToolHelpOptionPrint 'verbose'          'print each execution command before run'
  pdToolHelpOptionPrint 'dev-mode'         'development mode allow to see what engine will produce and run without real execution'
  pdToolHelpOptionPrint ''                 'enables verbose mode by default'
  pdToolHelpOptionPrint 'context-path'     'return path of store directory'
  pdToolHelpOptionPrint 'help'             'print this help info and exit'
  pdToolHelpOptionPrint 'version'          'print version info and exit'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '----------------' 'Arguments context management:'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'cleanup'          'remove unnamed and default context and exit'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'contexts'         'print simple list of all saved context names and exit'
  pdToolHelpOptionPrint 'context-list'     'print list of all saved contexts with arguments and exit'
  pdToolHelpOptionPrint 'context-list/*'   'print filtered list of saved contexts with arguments and exit'
  pdToolHelpOptionPrint 'context-rm/*  '   'remove named arguments context and exit'
  pdToolHelpOptionPrint 'context'          'load saved unnamed context arguments to cache'
  pdToolHelpOptionPrint 'context/*'        'load saved named context arguments to cache'
  pdToolHelpOptionPrint 'c/*'              'short version of context/*'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'default'          'save all arguments cache as default context  (it is performed just before first execution)'
  pdToolHelpOptionPrint ''                 'arguments stored in default context will be always loaded at the beginning'
  pdToolHelpOptionPrint 'store'            'save all arguments cache as unnamed context  (it is performed just before first execution)'
  pdToolHelpOptionPrint 'store/*'          'save all arguments cache as specific context (it is performed just before first execution)'
  pdToolHelpOptionPrint 's/*'              'short version of store/*'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '----------------' 'Executions management:'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'execs'            'print all stored execution names and exit'
  pdToolHelpOptionPrint 'exec-list'        'print all stored executions with caption and exit'
  pdToolHelpOptionPrint 'exec-list/*'      'print filtered stored executions with caption and exit'
  pdToolHelpOptionPrint 'exec-rm/*'        'remove named execution and exit'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '----------------' 'Execution chain:'
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint '-'                'start new command execution'
  pdToolHelpOptionPrint '--'               'start new execution with last command name'
  pdToolHelpOptionPrint '---'              'working like sequention " - run * "'
  pdToolHelpOptionPrint '- set'            'allow to set new arguments to cache before next execution'
  pdToolHelpOptionPrint '- add'            'allow to add new arguments to cache before next execution'
  pdToolHelpOptionPrint '- unset'          'allow to remove arguments from cache before next execution'
  pdToolHelpOptionPrint '- reset'          'restore arguments cache to state before start fist execution'
  pdToolHelpOptionPrint '- choose'         'choose needed arguments in cache by KEY, others will be removed'
  pdToolHelpOptionPrint '- clear'          'clear all arguments cache'
  pdToolHelpOptionPrint '- save-as *'      'save everything after this sequention as execution with specific name'
  pdToolHelpOptionPrint '- run *'          'load execution by name and execute with current arguments cache (verbose option is inherited)'
  echo -e ""
  echo -e "Arguments:"
  echo -e " To set arguments just type them as space separated KEY VALUE pairs or KEY=VALUE pair or just KEY."
  echo -e " If argument starts with character '-' it is always treated as KEY (even if there was key before)."
  echo -e " If KEY has character '=' then another argument will be treated as KEY too (even if it looks like value)."
  echo -e " If there is need to put KEY that will not be present in execution (like id for choosing params) then use pattern [#...]"
  echo -e " and everything after it will be VALUE (if it not starts with '-') even if another value is written same way."
  echo -e " If there is need to put something more complex put it in quotes."
  echo -e " NOTICE: if unset mode is enabled then everything is treated as key and if there is value associated with key it will be removed too."
  echo -e " Finally each KEY, VALUE or execution element (except first element) will be wrapped in quotes excluding internal KEYs"
  echo -e ""
  echo -e " Example possible combinations KEY VALUE set:"
  echo -e "  KEY"
  echo -e "  -KEY"
  echo -e "  -KEY VALUE"
  echo -e "  -KEY -KEY VALUE"
  echo -e "  -KEY VALUE KEY"
  echo -e "  -KEY=VALUE KEY"
  echo -e "  -KEY VALUE_LOOKS_LIKE_KEY=VALUE"
  echo -e "  KEY VALUE -KEY [#INTERNAL_KEY] #[VALUE_LOOKS_LIKE_KEY]"
  echo -e ""
  echo -e "Command parametrization:"
  echo -e " By default all arguments from cache are placed just between command and it's parametrization."
  echo -e " But it is possible to make command parametrization more complex."
  echo -e " If there is need to put arguments in specific way, this replacement form may be used:"
  echo -e ""
  echo -e " Form \"Find value for key and replace it with, or if there is no value then...\""
  pdToolHelpOptionPrint "<<#?key#>>"         "...ommit"                  26
  pdToolHelpOptionPrint "<<#key#>>"          "...use empty string"       26
  pdToolHelpOptionPrint "<<#key:?orElse#>>"  "...use "orElse""           26
  pdToolHelpOptionPrint "<<#!key#>>"         "...finish with error"      26
  echo -e ""
  echo -e " Form \"Find key and replace it with, or if there is no such key then...\""
  pdToolHelpOptionPrint "<<##?key##>>"         "...ommit"                26
  pdToolHelpOptionPrint "<<##key##>>"          "...use empty string"     26
  pdToolHelpOptionPrint "<<##key?:orElse##>>"  "...use "orElse""         26
  pdToolHelpOptionPrint "<<##!key##>>"         "...finish with error"    26
  echo -e ""
  echo -e " Form \"Find key and replace it with replacement, or if there is no key then...\""
  pdToolHelpOptionPrint "<<##?key|replacement##>>" "...ommit"            26
  pdToolHelpOptionPrint "<<##key|replacement##>>"  "...use empty string" 26
  echo -e ""
  echo -e " Form \"Find key and repeat replacement for each occurance of key\""
  pdToolHelpOptionPrint "<<###each:key###>> ... repeatable content ... <<###each!###>>"
  echo -e "  In each iteration in this loop only one occurrence of key is available in cache"
  echo -e "  and some additional parameters:"
  pdToolHelpOptionPrint " --each-size"  "count of all occurrences of key" 26
  pdToolHelpOptionPrint " --each-index" "current occurrence of key" 26
  pdToolHelpOptionPrint " --each-first" "appears only for first occurrence with single space value" 26
  pdToolHelpOptionPrint " --each-last"  "appears only for last occurrence with single space value" 26
  echo -e ""
}