[[ ! -f "$POCKET_ENGINE_HOME/engine/engine.sh" ]] && echo "ERROR: PocketEngine home variable not set properly: \$POCKET_ENGINE_HOME=$POCKET_ENGINE_HOME" && exit 1

########### MANAGEMENT / PUBLIC INTERFACE ####################################################

function engineCreateContext {
  local home="$1"

  engineImport "$POCKET_ENGINE_HOME"
  [[ ! "$POCKET_ENGINE_HOME" = "$home" ]] && engineImport "$home"

  # read main file
  . "$home/src/main/script/main.sh"
  [[ -f "$home/config/config.sh" ]] && . "$home/config/config.sh"
}

function engineStart {
  local home="$1"

  main "$@"
}

function engineImport {
  local home="$1"

  # read libs and scr index file
  [[ -f "$home/libs/main/script/index" ]] && engineReadIndex "$home" "libs/main/script"
  [[ -f "$home/src/main/script/index"  ]] && engineReadIndex "$home" "src/main/script"

  # run tests
  POCKET_ENGINE_ENABLE_TESTS=true
  POCKET_ENGINE_TESTS_ERRORS=0
  POCKET_ENGINE_TESTS_HIDE_CORRECT=true

  if [[ $POCKET_ENGINE_ENABLE_TESTS = true ]]; then
    [[ -f "$home/libs/test/script/index" ]] && engineRunIndexTests "$home" "libs/test/script"
    [[ -f "$home/src/test/script/index"  ]] && engineRunIndexTests "$home" "src/test/script"
    [[ $POCKET_ENGINE_TESTS_ERRORS -gt 0 ]] && echo "ERRORS IN TESTS $POCKET_ENGINE_TESTS_ERRORS"
  fi

}









########### IMPORT SOURCES ####################################################

function engineReadIndex {
  local home="$1"
  local path="$2"

  # abort if there is no index file
  [[ ! -f "$home/$path/index" ]] && echo "ERROR: There is no index file in path '$home/$path/index'" && exit 1
  # or read file line by line
  readarray -t file < "$home/$path/index"

  # if index is empty read all directory files
  [[ -z "${file[*]}" ]] && file=($(ls "$home/$path"))

  # for each import file position
  for line in "${file[@]}"
  do
      line="${line//[$'\t\r\n']/}"

      [[ $line =~ index      ]]  && continue # ommit every index file
      [[ $line =~ main.sh    ]]  && continue # ommit every main.sh file
      [[ $line =~ ^#.*       ]]  && continue # ommit comment lines
      [[ $line =~ ^\s*$      ]]  && continue # ommit empty lines

      engineReadIndexPosition "$home" "$path" "$line"
  done
}

function engineReadIndexPosition {
  local home="$1"
  local path="$2"
  local file="$3"

  local fullpath="$home/$path/$file"

  # read file if exists
  if [[ -f "$fullpath" ]] || [[ -f "$fullpath.sh" ]]; then
    engineReadIndexFile "$home" "$path" "$file"

  # read child index if filepath is directory
  elif [[ -d "$fullpath" ]]; then
    engineReadIndex "$home" "$path/$file"

  # if there is no file or directory to read print error and exit
  else
    echo "ERROR: cannot read sources from any of paths:"
    echo "- $fullpath"
    echo "- $fullpath.sh"
    exit 1
  fi

}

function engineReadIndexFile {
  local home="$1"
  local path="$2"
  local file="$3"

  # run import file
  local fullpath="$home/$path/$file"
  [[ -f "$fullpath"    ]] && . "$fullpath"
  [[ -f "$fullpath.sh" ]] && . "$fullpath.sh"
}










########### TEST SOURCES ######################################################

function engineRunIndexTests {
  local home="$1"
  local path="$2"

  # abort if there is no index file
  [[ ! -f "$home/$path/index" ]] && echo "ERROR: There is no index file in path '$home/$path/index'" && exit 1
  # or read file line by line
  readarray -t file < "$home/$path/index"

  # if index is empty read all directory files
  [[ -z "${file[*]}" ]] && file=($(ls "$home/$path"))

  # for each import file position
  for line in "${file[@]}"
  do
      line="${line//[$'\t\r\n']/}"

      [[ $line =~ index      ]]  && continue # ommit every index file
      [[ $line =~ main.sh    ]]  && continue # ommit every main.sh file
      [[ $line =~ ^#.*       ]]  && continue # ommit comment lines
      [[ $line =~ ^\s*$      ]]  && continue # ommit empty lines

      engineTestIndexPosition "$home" "$path" "$line"
  done
}

function engineTestIndexPosition {
  local home="$1"
  local path="$2"
  local file="$3"

  local fullpath="$home/$path/$file"

  # read file if exists
  if [[ -f "$fullpath" ]] || [[ -f "$fullpath.test" ]] || [[ -f "$fullpath.test.sh" ]]; then
    engineTestIndexFile "$home" "$path" "$file"

  # read child index if filepath is directory
  elif [[ -d "$fullpath" ]]; then
    engineRunIndexTests "$home" "$path/$file"

  # if there is no file or directory to read print error and exit
  else
    echo "ERROR: cannot read test from any of paths:"
    echo "- $fullpath"
    echo "- $fullpath.test"
    echo "- $fullpath.test.sh"
    exit 1
  fi
}

function engineTestIndexFile {
  local home="$1"
  local path="$2"
  local file="$3"

  local fullpath="$home/${path/main/test}/$file"

  # run test file
  [[ -f "$fullpath" ]]         && . "$fullpath"         "$home" "$path" "$file"
  [[ -f "$fullpath.test" ]]    && . "$fullpath.test"    "$home" "$path" "$file"
  [[ -f "$fullpath.test.sh" ]] && . "$fullpath.test.sh" "$home" "$path" "$file"
}

function engineTest {
  local name=$1
  local expected=$2
  local result=$3
  if [ ! "$expected" = "$result" ]; then
    echo "TEST: $name failed"
    echo "EXPTECTED: "
    echo "$expected"
    echo "RESULT: "
    echo "$result"
    echo
    POCKET_ENGINE_TESTS_ERRORS=$((POCKET_ENGINE_TESTS_ERRORS + 1))
  elif [[ ! $POCKET_ENGINE_TESTS_HIDE_CORRECT = true ]]; then
    echo "TEST: $name correct"
  fi
}

function __testExecution {
  engineTest "$__testHeader" "$__testExpect" "$__testActual"
}





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
    echo "                - create project in specific path"
    echo "                  # PROJECT_NAME is project specific name"
    echo "                    that will be used for directory name"
    echo "                  # ALIAS        is main script name"
    echo "                    that will be used as command name"
    echo "                    this keyword is optional"
    echo " - index update - update all index files in project, by default only add new positions to index"
    echo "   Additional arguments: "
    echo "   -c           - create index file if not appears in directory"
    echo "   -r           - remove positions from index if there is no matching src"
    echo " - index check  - check index files structure"
    echo " - build        - build project to one single script"
    echo " - hash         - simple hash function and local variables names in current project build"
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
    echo '#!/bin/bash'                                       >> "$projectPath/$alias"
    echo ''                                                  >> "$projectPath/$alias"
    echo '# project path'                                    >> "$projectPath/$alias"
    echo "$projectHomeVar=\"$projectPath\""                  >> "$projectPath/$alias"
    echo ''                                                  >> "$projectPath/$alias"
    echo '# import config file'                              >> "$projectPath/$alias"
    echo ''                                                  >> "$projectPath/$alias"
    echo '# import and start engine'                         >> "$projectPath/$alias"
    echo '. "$POCKET_ENGINE_HOME/engine/engine.sh"'          >> "$projectPath/$alias"
    echo 'engineCreateContext "$POCKET_ENGINE_HOME"'         >> "$projectPath/$alias"
    echo 'engineStart         "$POCKET_ENGINE_HOME" "$@"'    >> "$projectPath/$alias"

    mkdir "$projectPath/config"

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
