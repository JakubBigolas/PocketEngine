function peOptionHelp {
  echo -e ""
  echo -e "Usage: pe [options...] [arguments...] - [commands...] -- [repeat last command with another args/options]"
  echo -e ""
  echo -e "Main PocketEngine (\"pe\") purpose is to store and invoke multiple commands with configured arguments context as simple as it can be."
  echo -e ""
  echo -e "Options:"
  pdToolHelpOptionPrint '' ''
  pdToolHelpOptionPrint 'set'              'enable setting arguments cache sequention (enabled by default)'
  pdToolHelpOptionPrint 'unset'            'start removing arguments cache sequention'
  pdToolHelpOptionPrint 'clear'            'remove all arguments from cache'
  pdToolHelpOptionPrint 'verbose'          'print each execution command before run'
  pdToolHelpOptionPrint 'context-path'     'return path to store directory'
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
  pdToolHelpOptionPrint '- set'            'allow to add new arguments to cache before next execution'
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
  echo -e "Example use story: "
  echo -e ""
  echo -e "   $ pe - save-as buildAndRun - myCommand build -- -pDocker run"
  echo -e "   ${C_BLUE}# create new command named \"buildAndRun\" that runs commands: \"myCommand build\" and \"myCommand -pDocker run\"${C_RESET}"
  echo -e ""
  echo -e "   $ pe default -project MyApp"
  echo -e "   ${C_BLUE}# store arguments [-project MyApp] as default arguments loaded every time by default${C_RESET}"
  echo -e ""
  echo -e "   $ pe clear store store/env-dev -env dev"
  echo -e "   ${C_BLUE}# clear argument cache to be sure there is no defaults and store arguments [-env dev] as named context \"env-dev\"${C_RESET}"
  echo -e ""
  echo -e "   $ pe context/env-dev - run buildAndRun"
  echo -e "   ${C_BLUE}# run commands stored under name \"buildAndRun\" with default args and env-dev args, it will be converted to commands:${C_RESET}"
  echo -e "   ${C_BLUE}# $ \"myCommand\" \"-project\" \"MyApp\" \"-env\" \"dev\" \"build\"${C_RESET}"
  echo -e "   ${C_BLUE}# $ \"myCommand\" \"-project\" \"MyApp\" \"-env\" \"dev\" \"-pDoker\" \"run\"${C_RESET}"
  echo -e ""
  echo -e "   $ pe cleanup"
  echo -e "   ${C_BLUE}# if there is no need to keep default arguments remove them${C_RESET}"
}