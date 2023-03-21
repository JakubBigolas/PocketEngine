function peOptionHelp {
  echo -e ""
  echo -e "Usage: pe [options...] [arguments...] - [command...] -- [repeat last command with another args/options]"
  echo -e ""
  echo -e "Main PocketEngine (\"pe\") purpose it to invoke multiple commands in one arguments context or event in one line."
  echo -e ""
  echo -e " Ex: $ pe store -project MyApp -env dev - myCommand build -- -pDocker run"
  echo -e "       ${C_BLUE}# save args: -project MyApp -env dev${C_RESET}"
  echo -e "       ${C_BLUE}# and run commands ${C_RESET}"
  echo -e "       ${C_BLUE}#    myCommand -project MyApp -env dev build${C_RESET}"
  echo -e "       ${C_BLUE}#    myCommand -project MyApp -env dev -pDocker run${C_RESET}"
  echo -e "     $ pe context - myCommand logs"
  echo -e "       ${C_BLUE}# read args from context and run command: ${C_RESET}"
  echo -e "       ${C_BLUE}#    myCommand -project MyApp -env dev -pDocker logs${C_RESET}"
  echo -e "     $ pe cleanup"
  echo -e "       ${C_BLUE}# remove all args from context${C_RESET}"
  echo -e ""
  echo -e "Options:"
  pdToolHelpOptionPrint 'help'           'print this help info and exit'
  pdToolHelpOptionPrint 'version'        'print version info and exit'
  pdToolHelpOptionPrint 'clear'          'remove all arguments in memory'
  pdToolHelpOptionPrint 'cleanup'        'remove all stored arguments including default and exit'
  pdToolHelpOptionPrint 'cleanup/*'      'remove all stored arguments in specific context and exit'
  pdToolHelpOptionPrint 'context'        'load last saved context arguments'
  pdToolHelpOptionPrint 'context-list'   'list all saved contexts'
  pdToolHelpOptionPrint 'context/*'      'load specific context arguments'
  pdToolHelpOptionPrint 'default'        'save all arguments set as default (it is performed just before first " - " option '
  pdToolHelpOptionPrint ''               'or on exit if there is nothing to execute)'
  pdToolHelpOptionPrint ''               'arguments saved this way will be loaded automatically at the beginning of next run'
  pdToolHelpOptionPrint 'set'            'start setting arguments sequention (enabled by default)'
  pdToolHelpOptionPrint 'store'          'save all arguments set to context (it is performed just before first " - " option '
  pdToolHelpOptionPrint 'store/*'        'save all arguments set to specific context (it is performed just before first " - " option '
  pdToolHelpOptionPrint ''               'or on exit if there is nothing to execute)'
  pdToolHelpOptionPrint 'unset'          'start removing arguments sequention'
  pdToolHelpOptionPrint 'verbose'        'print each execution command before run'
  pdToolHelpOptionPrint '-'              'start new command execution'
  pdToolHelpOptionPrint '--'             'start new command execution with last command name'
  pdToolHelpOptionPrint '- set'          'allow to add new arguments before next execution'
  pdToolHelpOptionPrint '- unset'        'allow to remove arguments before next execution'
  pdToolHelpOptionPrint '- reset'        'restore arguments to value before start fist execution'
  pdToolHelpOptionPrint '- clear'        'clear all arguments in memory'
  echo -e ""
  echo -e "Arguments:"
  echo -e " To set arguments just type them as space separated KEY VALUE pairs or KEY=VALUE pair or just KEY."
  echo -e " If argument starts with character '-' it is always treated as KEY (even if there was key before)."
  echo -e " There is also key-set form as list comma separated keys between braces [K1,K2,...,Kn]"
  echo -e ""
  echo -e " Example possible combinations:"
  echo -e "  KEY"
  echo -e "  -KEY"
  echo -e "  -KEY VALUE"
  echo -e "  -KEY -KEY VALUE"
  echo -e "  KEY VALUE -KEY"
  echo -e "  -KEY VALUE KEY"
  echo -e "  -KEY=VALUE KEY"
  echo -e "  -KEY VALUE_LOOKS_LIKE_KEY=VALUE"
  echo -e "  -KEY [KEY,-KEY] KEY"
  echo -e "  -KEY [KEY,-KEY=VALUE]"
  echo -e ""
}