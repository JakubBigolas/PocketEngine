########### ENGINE MANAGEMENT #################################################

if [[ $# -gt 0 ]]; then

  function engine {
    local path="$(pwd)"
    local version="0.0.1.dev"

    while [[ $# -gt 0 ]]; do
      case $1 in

        # print version info
        version)
          echo "$version"
          exit 0
          ;;

        # replace current path with user specified
        -p)
          path="$2"
          shift
          shift
          ;;

        # print help info
        help)
          printHelp
          exit 0
          ;;

        create)
          shift
            case $1 in
              project)
                shift
                createProject "$path" "$@"
                exit 1
                ;;
            esac
          ;;

        index)
          shift
            case $1 in
              update)
                shift
                indexUpdate "$path"
                exit 1
                ;;
              check)
                shift
                indexCheck "$path"
                exit 1
                ;;
            esac
          ;;

        build)
          shift
          buildProject "$path"
          exit 1
          ;;

        hash)
          shift
          hashBuild "$path"
          exit 1
          ;;

        *)
          echo "ERROR: unknown options: $*"
          exit 1
          ;;

      esac
    done
  }

  function printHelp {
    echo "Usage: "
    echo ""
    echo " $: engine [args...] [option]"
    echo ""
    echo " Arguments: "
    echo ""
    echo " -p             - allow to specify project path (by default is current cmd path)"
    echo ""
    echo " Options: "
    echo ""
    echo " - create project PROJECT_NAME alias ALIAS"
    echo "                     - create project in specific path"
    echo "                       # PROJECT_NAME is project specific name"
    echo "                         that will be used for directory name"
    echo "                       # ALIAS        is main script name"
    echo "                         that will be used as command name"
    echo "                         this keyword is optional"
    echo " - index update      - update all index files in project, by default only add new positions to index"
    echo "   Additional arguments: "
    echo "   -c           - create index file if not appears in directory"
    echo "   -r           - remove positions from index if there is no matching src"
    echo " - index check       - check index files structure"
    echo " - index add         - add new file to project"
    echo " - index add test    - add new test file to project"
    echo " - index remove      - remove file from project"
    echo " - index remove test - remove test file from project"
    echo " - build             - build project to one single script"
    echo " - hash              - simple hash function and local variables names in current project build"
    echo ""
  }

  function createProject {
    local path="$1"        ; shift
    local projectName="$1" ; shift
    local alias="$1"       ; shift
    # if there is keyword alias read one more argument
    [[ "$alias" = "alias" ]] && alias="$1" && shift
    # if alias is empty use project name by default
    [[ -z "$alias" ]]        && alias=$projectName
    local projectPath="$path/$projectName"

    # error if there is no project name specified
    [[ -z "$projectName" ]] && echo "ERROR: project name must be specified" && exit 1

    # error if directory path not exists
    [[ ! -d "$path" ]]      && echo "ERROR: project path not available $path or is not a directory" && exit 1

    # error if project directory already exists
    [[ -d "$projectPath" ]] && echo "ERROR: project with name $projectName already exists in " && exit 1

    local projectHomeVar="$(sed --expression 's/\([A-Z]\)/_\1/g' --expression 's/^_//' <<< "$projectName")"
    projectHomeVar="${projectHomeVar^^}_HOME"

    echo "Create project: $projectName"
    echo "path  : $path/$projectName"
    echo "alias : $alias"
    echo "home  : $projectHomeVar"

    mkdir "$projectPath"
    # error if project directory already exists
    [[ ! -d "$projectPath" ]] && echo "ERROR: project directory cannot be created $projectName" && exit 1

    # create main file
    echo '#!/bin/bash'                                          >> "$projectPath/$alias"
    echo ''                                                     >> "$projectPath/$alias"
    echo '# project path'                                       >> "$projectPath/$alias"
    echo "$projectHomeVar=\"$projectPath\""                     >> "$projectPath/$alias"
    echo ''                                                     >> "$projectPath/$alias"
    echo '# import config file'                                 >> "$projectPath/$alias"
    echo ". \"\$$projectHomeVar/config/config.sh\""             >> "$projectPath/$alias"
    echo ''                                                     >> "$projectPath/$alias"
    echo '# import and start engine'                            >> "$projectPath/$alias"
    echo ". \"\$POCKET_ENGINE_HOME/engine/engine-embed.sh\""    >> "$projectPath/$alias"
    echo "engineCreateContext \"\$$projectHomeVar\""            >> "$projectPath/$alias"
    echo "engineStart         \"\$$projectHomeVar\" \"\$@\""    >> "$projectPath/$alias"

    mkdir "$projectPath/config"
    echo '# Add here any global configuration to keep it in one file' >> "$projectPath/config/config.sh"

    mkdir "$projectPath/libs"
    mkdir "$projectPath/libs/main"
    mkdir "$projectPath/libs/main/script"
    mkdir "$projectPath/libs/test"
    mkdir "$projectPath/libs/test/script"

    echo "" >> "$projectPath/libs/main/script/index"
    echo "" >> "$projectPath/libs/test/script/index"

    mkdir "$projectPath/src"
    mkdir "$projectPath/src/main"
    mkdir "$projectPath/src/main/script"
    mkdir "$projectPath/src/test"
    mkdir "$projectPath/src/test/script"
    echo "" >> "$projectPath/src/main/script/index"
    echo "" >> "$projectPath/src/test/script/index"

    echo "# main script function where execution begins"  >> "$projectPath/src/main/script/main.sh"
    echo "function main {"                                >> "$projectPath/src/main/script/main.sh"
    echo "  # project home path"                          >> "$projectPath/src/main/script/main.sh"
    echo "  local home=\"\$1\""                           >> "$projectPath/src/main/script/main.sh"
    echo "  shift"                                        >> "$projectPath/src/main/script/main.sh"
    echo ""                                               >> "$projectPath/src/main/script/main.sh"
    echo "  echo \"Hello World!\""                        >> "$projectPath/src/main/script/main.sh"
    echo ""                                               >> "$projectPath/src/main/script/main.sh"
    echo "}"                                              >> "$projectPath/src/main/script/main.sh"


    echo "Structure:"
    echo ""
    echo "$projectPath"
    echo "   /$alias <- main script that load all scripts and start program"
    echo "   /config             <- directory with config files"
    echo "      /config.sh       <- default config file (may contains global variables)"
    echo "   /libs               <- libraries directory"
    echo "      /main            <- main libraries directory"
    echo "         /script       <- library scripts"
    echo "            /index     <- begin index file"
    echo "      /test            <- test libraries directory"
    echo "         /script       <- test library scripts"
    echo "            /index     <- test begin index file"
    echo "   /src                <- sources directory"
    echo "      /main            <- main sources directory"
    echo "         /script       <- main scripts directory"
    echo "            /main.sh   <- script with main function that is called after load all program resources"
    echo "            /index     <- begin index file"
    echo "      /test            <- test sources directory"
    echo "         /script       <- test scripts directory"
    echo "            /index     <- test begin index file"
    echo ""
    echo "Created!"
    echo "Remember to make file $projectPath/$alias executable"
    echo "and add it to system PATH variable to make it easy to use."

  }

  function indexUpdate {
    local path="$1"        ; shift

    echo "index update $path"
  }

  function indexCheck {
    local path="$1"        ; shift

    echo "index check $path"
  }

  function buildProject {
    local path="$1"        ; shift

    echo "build project $path"
  }

  function hashBuild {
    local path="$1"        ; shift

    echo "hash build $path"
  }

  engine "$@"

fi
