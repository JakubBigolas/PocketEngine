
# engine-build-project.sh
function buildProject {
  local path="$1"        ; shift
  local profile="$1"     ; shift
  local version="$1"     ; shift
  local projectName="$(pathToProjectName "$path")"
  local projectHomeVar="$(toUpperSnakeCase "$profile")_HOME"

  [[ ! -d "$path" ]] && echo "ERROR: project path not available $path" && exit 1

  [[ -z "$version" ]] && version="default"
  [[ -z "$profile" ]] && profile="default"

  local versionPath="$path/build/$profile/$version"

  [[ ! -d "$path/build"           ]] && mkdir "$path/build"
  [[ ! -d "$path/build/$profile"  ]] && mkdir "$path/build/$profile"
  [[   -d "$versionPath"          ]] && rm -rf "$versionPath"
  [[ ! -d "$versionPath"          ]] && mkdir "$versionPath"


  echo "Build project: $projectName"
  echo "profile     : $profile"
  echo "version     : $version"
  echo "build path  : $versionPath"
  echo "home-var    : $projectHomeVar"

  # TODO valid project structure before build

  # TODO read libs from external library

  # create start standalone file
  echo '#!/bin/bash'                                          >> "$versionPath/$projectName"
  echo ''                                                     >> "$versionPath/$projectName"
  echo '# app home'                                           >> "$versionPath/$projectName"
  echo "$projectHomeVar=\"\""                                 >> "$versionPath/$projectName"
  echo ''                                                     >> "$versionPath/$projectName"
  echo '# import config file'                                 >> "$versionPath/$projectName"
  echo ". \"\$$projectHomeVar/config/config.sh\""             >> "$versionPath/$projectName"
  echo ''                                                     >> "$versionPath/$projectName"
  echo '# import app'                                         >> "$versionPath/$projectName"
  echo ". \"\$$projectHomeVar/$projectName\""                 >> "$versionPath/$projectName"
  echo 'main "$@"'                                            >> "$versionPath/$projectName"

  # create standalone script file
  [[ -f "$path/libs/main/script/index" ]] && buildProjectReadIndex "$path" "libs/main/script" "$versionPath/$projectName.sh"
  [[ -f "$path/src/main/script/index"  ]] && buildProjectReadIndex "$path" "src/main/script"  "$versionPath/$projectName.sh"
  echo ""                                >> "$versionPath/$projectName.sh"
  echo "# /src/main/script/main.sh"      >> "$versionPath/$projectName.sh"
  echo ""                                >> "$versionPath/$projectName.sh"
  cat  "$path/src/main/script/main.sh"   >> "$versionPath/$projectName.sh"
  echo ""                                >> "$versionPath/$projectName.sh"

  # create config file
  mkdir "$versionPath/config"
  if [[ -f "$path/config/config-$profile.sh" ]]; then
    cp "$path/config/config-$profile.sh" "$versionPath/config/config.sh"
  else
    echo '# Add here any global configuration to keep it in one file' >> "$versionPath/config/config.sh"
  fi

  echo "Completed!"
}

function buildProjectReadIndex {
  local home="$1"
  local path="$2"
  local buildFile="$3"

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

      buildProjectReadIndexPosition "$home" "$path" "$line" "$buildFile"
  done
}

function buildProjectReadIndexPosition {
  local home="$1"
  local path="$2"
  local file="$3"
  local buildFile="$4"

  local fullpath="$home/$path/$file"

  # read file if exists
  if [[ -f "$fullpath" ]] || [[ -f "$fullpath.sh" ]]; then
    buildProjectReadIndexFile "$home" "$path" "$file" "$buildFile"

  # read child index if filepath is directory
  elif [[ -d "$fullpath" ]]; then
    buildProjectReadIndex "$home" "$path/$file" "$buildFile"

  # if there is no file or directory to read print error and exit
  else
    echo "ERROR: cannot read sources from any of paths:"
    echo "- $fullpath"
    echo "- $fullpath.sh"
    exit 1
  fi

}

function buildProjectReadIndexFile {
  local home="$1"
  local path="$2"
  local file="$3"
  local buildFile="$4"

  # run import file
  local fullpath="$home/$path/$file"
  [[ -f "$fullpath.sh" ]] && fullpath="$fullpath.sh"

  echo ""              >> "$buildFile"
  echo "# $path/$file" >> "$buildFile"
  echo ""              >> "$buildFile"
  cat  "$path/$file"   >> "$buildFile"
  echo ""              >> "$buildFile"
}
# engine-create-project.sh
function createProject {

  # ARGS

  local path="$1"        ; shift # PROJECT PATH
  local projectName="$1" ; shift # PROJECT NAME
  local alias="$1"       ; shift # PROJECT ALIAS

  # if there is keyword alias read one more argument
  [[ "$alias" = "alias" ]] && alias="$1" && shift

  # if alias is empty use project name by default
  [[ -z "$alias" ]]        && alias=$projectName
  local projectPath="$path/$projectName"



  # PRE SCRIPT VALIDATION

  # error if there is no project name specified
  [[ -z "$projectName" ]] && echo "ERROR: project name must be specified" && exit 1

  # error if directory path not exists
  [[ ! -d "$path" ]]      && echo "ERROR: project path not available $path or is not a directory" && exit 1

  # error if project directory already exists, cannot be recreated
  [[ -d "$projectPath" ]] && echo "ERROR: project with name $projectName already exists in " && exit 1



  # BEGIN EXECUTION

  local projectHomeVar="$(toUpperSnakeCase "$projectName")_HOME"

  # print env
  echo "Create project: $projectName"
  echo "path  : $path/$projectName"
  echo "alias : $alias"
  echo "home  : $projectHomeVar"

  # create project directory
  mkdir "$projectPath"

  # create dirs and files
  createProject_ExportEngineEmbed "$projectPath"
  createProject_MainFile          "$projectPath" "$alias" "$projectHomeVar"
  createProject_ConfigFile        "$projectPath"
  createProject_IndexDirs         "$projectPath" "libs"
  createProject_IndexDirs         "$projectPath" "src"
  createProject_ExampleMainSh     "$projectPath"

  # finish
  createProject_Completed         "$projectPath" "$alias"

}

function createProject_ExportEngineEmbed {
  local path="$1"

  mkdir "$path/engine"
  engineEmbed >> "$path/engine/engine-embed.sh"
}

function createProject_MainFile {
  local path="$1"           ; shift
  local alias="$1"          ; shift
  local projectHomeVar="$1" ; shift

  echo "#!/bin/bash"                                        >> "$path/$alias"
  echo ""                                                   >> "$path/$alias"
  echo "# project path"                                     >> "$path/$alias"
  echo "$projectHomeVar=\"$path\""                          >> "$path/$alias"
  echo ""                                                   >> "$path/$alias"
  echo "# import config file"                               >> "$path/$alias"
  echo ". \"\$$projectHomeVar/config/config.sh\""           >> "$path/$alias"
  echo ""                                                   >> "$path/$alias"
  echo "# import and start engine"                          >> "$path/$alias"
  echo ". \"\$$projectHomeVar/engine/engine-embed.sh\""     >> "$path/$alias"
  echo "engineCreateContext \"\$$projectHomeVar\""          >> "$path/$alias"
  echo "engineStart         \"\$$projectHomeVar\" \"\$@\""  >> "$path/$alias"
}

function createProject_ConfigFile {
  local path="$1"
  mkdir "$path/config"
  echo '# Add here any global configuration to keep it in one file' >> "$path/config/config.sh"
}

function createProject_IndexDirs {
  local path="$1"   ; shift
  local subdir="$1" ; shift

  mkdir "$path/$subdir"
  mkdir "$path/$subdir/main"
  mkdir "$path/$subdir/main/script"
  mkdir "$path/$subdir/test"
  mkdir "$path/$subdir/test/script"

  echo "" >> "$path/$subdir/main/script/index"
  echo "" >> "$path/$subdir/test/script/index"

}

function createProject_ExampleMainSh {
  local path="$1/src/main/script/main.sh"

  echo "# main script function where execution begins" >> "$path"
  echo "function main {"                               >> "$path"
  echo ""                                              >> "$path"
  echo "  echo \"Hello World!\""                       >> "$path"
  echo ""                                              >> "$path"
  echo "}"                                             >> "$path"
}

function createProject_Completed {
  local projectPath="$1" ; shift
  local alias="$1"       ; shift

  echo ""
  echo "Structure:"
  echo ""
  echo "$projectPath"
  echo "   /$alias <- main script that load all scripts and start program"
  echo "   /engine             <- pocket engine directory, content should not be modified"
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
  echo ""
  echo "Remember to make file $projectPath/$alias executable"
  echo "and add it to system PATH variable to make it easy to use."
  echo ""
}

# engine-embed.sh
function engineEmbed {
echo '


########### MANAGEMENT / PUBLIC INTERFACE ####################################################

function engineCreateContext {
  local home="$1"

  # TODO there is need to add function to load libs from external repository

  engineImport "$home"

  # read main file
  . "$home/src/main/script/main.sh"
  [[ -f "$home/config/config.sh" ]] && . "$home/config/config.sh"
}

function engineStart {
  local home="$1"
  shift

  main "$@"
}

function engineImport {
  local home="$1"

  # read libs and scr index file
  [[ -f "$home/libs/main/script/index" ]] && engineReadIndex "$home" "libs/main/script"
  [[ -f "$home/src/main/script/index"  ]] && engineReadIndex "$home" "src/main/script"

  # run tests
# ENGINE_ENABLE_TESTS=true
  ENGINE_TESTS_ERRORS=0
  ENGINE_TESTS_HIDE_CORRECT=false

  if [[ $ENGINE_ENABLE_TESTS = true ]]; then
    [[ -f "$home/libs/test/script/index" ]] && engineRunIndexTests "$home" "libs/test/script"
    [[ -f "$home/src/test/script/index"  ]] && engineRunIndexTests "$home" "src/test/script"
    [[ $ENGINE_TESTS_ERRORS -gt 0 ]] && echo "ERRORS IN TESTS $ENGINE_TESTS_ERRORS"
  fi

}









########### IMPORT SOURCES ####################################################

function engineReadIndex {
  local home="$1"
  local path="$2"

  # abort if there is no index file
  [[ ! -f "$home/$path/index" ]] && echo "ERROR: There is no index file in path \"$home/$path/index\"" && exit 1
  # or read file line by line
  readarray -t file < "$home/$path/index"

  # if index is empty read all directory files
  [[ -z "${file[*]}" ]] && file=($(ls "$home/$path"))

  # for each import file position
  for line in "${file[@]}"
  do
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"

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
  [[ ! -f "$home/$path/index" ]] && echo "ERROR: There is no index file in path \"$home/$path/index\"" && exit 1
  # or read file line by line
  readarray -t file < "$home/$path/index"

  # if index is empty read all directory files
  [[ -z "${file[*]}" ]] && file=($(ls "$home/$path"))

  # for each import file position
  for line in "${file[@]}"
  do
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"

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
    ENGINE_TESTS_ERRORS=$((ENGINE_TESTS_ERRORS + 1))
  elif [[ ! $ENGINE_TESTS_HIDE_CORRECT = true ]]; then
    echo "TEST: $name correct"
  fi
}

function __testExecution {
  engineTest "$__testHeader" "$__testExpect" "$__testActual"
}


'
}
# engine-help.sh
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
  echo " - build VERSION     - build project to one single script"
  echo "                       # VERSION allow to add subdirectory with version name for build"
  echo ""
}
# engine-index-check.sh
function indexCheck {

  # ARGS

  local path="$1"   ; shift

  local projectName="$(pathToProjectName "$path")"

  # PRINT ENVS

  echo "Index check for project: $projectName"
  echo "path: $path"
  echo

  # DO CHECKS

  indexCheck_checkEngine   "$path"
  indexCheck_startPoint    "$path"
  indexCheck_checkConfig   "$path"
  indexCheck_checkSources  "$path" "libs"
  indexCheck_checkSources  "$path" "src"

}

# Checking if embedded engine exists in project and has current version
function indexCheck_checkEngine {
  local path="$1" ; shift

  local engineDirPath="$path/engine"
  local enginePath="$engineDirPath/engine-embed.sh"

  echo "Check engine..."

  # check if there is engine-embed.sh file
  [[ ! -f "$enginePath" ]] && echo "WARNING: not found embeded engine in path: $enginePath" && return 1

  # check if version of this file is the same as current
  [[ "$(engineEmbed)" != "$(cat "$enginePath")" ]] && echo "WARNING: embeded engine has not original structure in file: $enginePath" && return 1

  echo ""

}

# Looking for potential start point of script
function indexCheck_startPoint {
  local path="$1" ; shift

  echo "Check start point..."

  for f in `ls "$path"`
  do
    if [[ -f "$path/$f" ]] && [[ -n $(cat "$path/$f" | grep engineCreateContext) ]]; then

      local executable=
      [[ ! -x "$path/$f" ]] \
        && executable="(not executable)"

      echo "INFO: found potential starting point file:" \
        && echo " - $path/$f $executable"

    fi
  done

  echo ""

}

# Checking config files
# if there is config directory
# if there is default config file
# it there are optional profiled config files
function indexCheck_checkConfig {
  local path="$1"
  local configDirPath="$1/config"

  echo "Check config..."

  [[ ! -d "$configDirPath" ]] \
    && echo "WARNING: config directory path not available: $configDirPath" \
    && return 1

  local foundDefaultConfig=false
  local foundProfiles=()
  for f in `ls "$configDirPath"`
  do

    [[ "$f" = "config.sh" ]] && foundDefaultConfig=true && continue

    [[ "$f" =~ ^config- ]] && foundProfiles=("${foundProfiles[@]}" "${f/config-/}") && continue

  done

  [[ "$foundDefaultConfig" = false ]] \
    && echo "WARNING: default config file not found in $configDirPath/config.sh"

  [[ ${#foundProfiles[@]} -gt 0 ]] \
    && echo "INFO: found ${#foundProfiles[@]} profiles:" \
    && for p in "${foundProfiles[@]}" ; do echo " - ${p/.sh/}" ; done

  echo ""

}

# Checking resources and lib directories main and test
function indexCheck_checkSources {
  local path="$1" ; shift
  local type="$1" ; shift

  local mainPath="$type/main/script"
  local testPath="$type/test/script"

  echo "Check $type/main..."

  if [[ -d "$path/$mainPath" ]]; then

  # trzeba by jeszcze zrobic sprawdzenie rozszerzen plikow czy nie ma duplikatow i czy mozna je ignorowac w indexach

    indexCheck_checkMainFilesDirs           "$path" "$mainPath"
    indexCheck_checkMissingIndexFiles       "$path" "$mainPath"
    indexCheck_checkEmptyIndexFiles         "$path" "$mainPath"
    indexCheck_checkMissingIndexPositions   "$path" "$mainPath"
    indexCheck_checkNotIndexedSources       "$path" "$mainPath"

  else
    echo "ERROR: main sources directory not found"
  fi

#  echo "Check $type/test..."
#
#  if [[ -d "$path/$testPath" ]]; then
#    indexCheck_checkSourcesTestDir "$path" "$mainPath" "$testPath"
#  else
#    echo "INFO: test sources directory not found"
#  fi

  echo ""

}


function indexCheck_checkMainFilesDirs {
    local path="$1"     ; shift
    local mainPath="$1" ; shift

    local hasCorrectMainFile=0
    local hasIncorrectMainFile=0
    INDEX_CHECK_MAIN_FILES=()
    indexCheck_getMainFilesDirs "$path" "$mainPath"

    for f in "${INDEX_CHECK_MAIN_FILES[@]}"
    do
      [[ "$f" = "src/main/script"  ]] && hasCorrectMainFile=$((hasCorrectMainFile + 1))
      [[ "$f" != "src/main/script" ]] && hasIncorrectMainFile=$((hasIncorrectMainFile + 1))
    done

    [[ "$mainPath" = "src/main/script" ]] && [[ $hasCorrectMainFile = 0 ]]   && echo "ERROR: main.sh file not found where expected: $path/$mainPath/main.sh"
    [[ "$mainPath" = "src/main/script" ]] && [[ $hasCorrectMainFile = 1 ]]   && echo "INFO: main.sh found in correct path"
    [[ "$mainPath" = "src/main/script" ]] && [[ $hasCorrectMainFile -gt 1 ]] && echo "ERROR: too much implementations of main file in directory: $path/$mainPath"

    [[ $hasIncorrectMainFile -gt 0 ]] && echo "ERROR: found $hasIncorrectMainFile incorrect main files in directories:"
    [[ $hasIncorrectMainFile -gt 0 ]] && for f in "${INDEX_CHECK_MAIN_FILES[@]}" ; do     [[ "$f" != "src/main/script" ]] && echo " - $path/$f"     ; done

}

function indexCheck_getMainFilesDirs {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  local dirs=()
  for f in `ls "$path/$subPath"`
  do
    [[ "$f" = "main.sh"       ]] && INDEX_CHECK_MAIN_FILES=("${INDEX_CHECK_MAIN_FILES[@]}" "$subPath") && continue
    [[ "$f" = "main"          ]] && INDEX_CHECK_MAIN_FILES=("${INDEX_CHECK_MAIN_FILES[@]}" "$subPath") && continue
    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f") && continue
  done

  # recurrent for each directory
  for d in "${dirs[@]}" ; do indexCheck_getMainFilesDirs "$path" "$subPath/$d" ; done

}

function indexCheck_checkMissingIndexFiles {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  INDEX_CHECK_MISSING_INDEX_FILES=()
  indexCheck_getMissingIndexFiles "$path" "$mainPath"

  if [[ ${#INDEX_CHECK_MISSING_INDEX_FILES[@]} -gt 0 ]]; then
    echo "ERROR: missing ${#INDEX_CHECK_MISSING_INDEX_FILES[@]} index files in directories:"
    for index in "${INDEX_CHECK_MISSING_INDEX_FILES[@]}" ; do     echo " - $path/$index"     ; done
  fi

}

function indexCheck_getMissingIndexFiles {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  # read directory content
  local hasIndex=false
  local dirs=()

  for f in `ls "$path/$subPath"`
  do
    [[ "$f" = "index"         ]] && hasIndex=true               && continue
    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f")    && continue
  done

  [[ $hasIndex = false ]] && INDEX_CHECK_MISSING_INDEX_FILES=("${INDEX_CHECK_MISSING_INDEX_FILES[@]}" "$subPath")

  # recurrent for each directory
  for d in "${dirs[@]}" ; do indexCheck_getMissingIndexFiles "$path" "$subPath/$d" ; done

}

function indexCheck_checkEmptyIndexFiles {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  INDEX_CHECK_EMPTY_INDEX_FILES=()
  indexCheck_getEmptyIndexFiles "$path" "$mainPath"

  if [[ ${#INDEX_CHECK_EMPTY_INDEX_FILES[@]} -gt 0 ]]; then
    echo "WARNING: found ${#INDEX_CHECK_EMPTY_INDEX_FILES[@]} empty index files in directories:"
    for index in "${INDEX_CHECK_EMPTY_INDEX_FILES[@]}" ; do     echo " - $path/$index"     ; done
  fi

}

function indexCheck_getEmptyIndexFiles {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  # read directory content
  local hasIndex=false
  local dirs=()

  for f in `ls "$path/$subPath"`
  do
    [[ "$f" = "index"         ]] && hasIndex=true               && continue
    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f")    && continue
  done

  # check index file

  if [[ $hasIndex = true ]] ; then
    # read index file
    readarray -t indexFilesList < "$path/$subPath/index"
    # waring if index is empty
    [[ -z "${indexFilesList[*]}" ]] && INDEX_CHECK_EMPTY_INDEX_FILES=("${INDEX_CHECK_EMPTY_INDEX_FILES[@]}" "$subPath")
  fi

  # recurrent for each directory
  for d in "${dirs[@]}" ; do indexCheck_getEmptyIndexFiles "$path" "$subPath/$d" ; done

}

function indexCheck_checkMissingIndexPositions {
    local path="$1"     ; shift
    local subPath="$1"  ; shift

    INDEX_CHECK_MISSING_INDEX_POSITIONS=()
    indexCheck_getMissingIndexPositions "$path" "$mainPath"

    if [[ ${#INDEX_CHECK_MISSING_INDEX_POSITIONS[@]} -gt 0 ]]; then
      echo "ERROR: missing ${#INDEX_CHECK_MISSING_INDEX_POSITIONS[@]} index position that not exists:"
      for index in "${INDEX_CHECK_MISSING_INDEX_POSITIONS[@]}" ; do     echo " - $path/$index"     ; done
    fi
}

function indexCheck_getMissingIndexPositions {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  # read directory content
  local hasIndex=false
  local files=()
  local dirs=()

  for f in `ls "$path/$subPath"`
  do
    [[ "$f" = "index"         ]] && hasIndex=true               && continue
    [[ -f "$path/$subPath/$f" ]] && files=("${files[@]}" "$f")  && continue
    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f")    && continue
  done

  # check index file

  if [[ $hasIndex = true ]]; then
    readarray -t indexFilesList < "$path/$subPath/index"

    # for each import file position check if is on files or dirs list
    for line in "${indexFilesList[@]}"
    do

      local isExisting=false
      line="$(removeWhitespaces "$line")"
      for f in "${files[@]}" "${dirs[@]}" ; do [[ "$f" = "$line" ]] && isExisting=true && break ; done

      [[ $isExisting = false ]] && INDEX_CHECK_MISSING_INDEX_POSITIONS=("${INDEX_CHECK_MISSING_INDEX_POSITIONS[@]}" "$path/$subPath/$line")

    done
  fi

  # recurrent for each directory
  for d in "${dirs[@]}" ; do indexCheck_getMissingIndexPositions "$path" "$subPath/$d" ; done

}

function indexCheck_checkNotIndexedSources {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  INDEX_CHECK_DIRS_NOT_INDEXED=()
  INDEX_CHECK_FILES_NOT_INDEXED=()
  indexCheck_getNotIndexedSources "$path" "$mainPath"

  if [[ ${#INDEX_CHECK_DIRS_NOT_INDEXED[@]} -gt 0 ]]; then
    echo "WARNING: found ${#INDEX_CHECK_DIRS_NOT_INDEXED[@]} directories than might need to be indexed:"
    for index in "${INDEX_CHECK_DIRS_NOT_INDEXED[@]}" ; do     echo " - $path/$index"     ; done
  fi

  if [[ ${#INDEX_CHECK_FILES_NOT_INDEXED[@]} -gt 0 ]]; then
    echo "WARNING: found ${#INDEX_CHECK_FILES_NOT_INDEXED[@]} files than might need to be indexed:"
    for index in "${INDEX_CHECK_FILES_NOT_INDEXED[@]}" ; do     echo " - $path/$index"     ; done
  fi

}

function indexCheck_getNotIndexedSources {
  local path="$1"     ; shift
  local subPath="$1"  ; shift

  # read directory content
  local hasIndex=false
  local files=()
  local dirs=()
  local unknown=()

  for f in `ls "$path/$subPath"`
  do
    [[ "$f" = "index"         ]] && hasIndex=true               && continue
    [[ -f "$path/$subPath/$f" ]] && files=("${files[@]}" "$f")  && continue
    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f")    && continue
    unknown=("${unknown[@]}" "$f")
  done

  # check index file

  if [[ $hasIndex = true ]] ; then
    # read index file
    readarray -t indexFilesList < "$path/$subPath/index"
  fi


  # for each file check if is indexed
  for line in "${files[@]}"
  do

    local isIndexed=false
    for f in "${indexFilesList[@]}"
    do
      if [[ "$f" = "$line" ]] || [[ "$f.sh" = "$line" ]] ; then
        isExisting=true
        break;
      fi
    done

    [[ $isIndexed = false ]] && INDEX_CHECK_FILES_NOT_INDEXED=("${INDEX_CHECK_FILES_NOT_INDEXED[@]}" "$line")

  done

  # for each directory check if is indexed
  for line in "${dirs[@]}"
  do

    local isIndexed=false
    for f in "${indexFilesList[@]}" ; do [[ "$f" = "$line" ]] && isIndexed=true && break ; done
    [[ $isIndexed = false ]] && INDEX_CHECK_DIRS_NOT_INDEXED=("${INDEX_CHECK_DIRS_NOT_INDEXED[@]}" "$line")

  done

  # recurrent for each directory
  for d in "${dirs[@]}" ; do indexCheck_getNotIndexedSources "$path" "$subPath/$d" ; done

}


#
## Recurrent checking "main" directory of libs and src for
## - occurance of main.sh file
## - index file in directory
## - performance issue of empty index
## - invalid position of index file if exists and has content
## - missing files/dirs if index if index is not empty
#function indexCheck_checkSourcesMainDir {
#  local path="$1"     ; shift
#  local subPath="$1"  ; shift
#
#
#
#  # read directory content
#  local hasIndex=false
#  local files=()
#  local dirs=()
#  local unknown=()
#
#  for f in `ls "$path/$subPath"`
#  do
#    [[ "$f" = "index"         ]] && hasIndex=true               && continue
#    [[ -f "$path/$subPath/$f" ]] && files=("${files[@]}" "$f")  && continue
#    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f")    && continue
#    unknown=("${unknown[@]}" "$f")
#  done
#
#
#
#
#
#
#  # check index file
#
#  if [[ $hasIndex = true ]] ; then
#    # read index file
#    readarray -t indexFilesList < "$path/$subPath/index"
#    # waring if index is empty
#    [[ -z "${indexFilesList[*]}" ]] && echo "WARNING: empty index file may cause performance issues $path/$subPath/index" && echo
#  else
#    echo "ERROR: missing index file in directory: "$path/$subPath"" && echo
#  fi
#
#
#
#  # for each import file position check if is on files or dirs list
#  local filesNotExisting=()
#  for line in "${indexFilesList[@]}"
#  do
#
#    local isExisting=false
#    line="$(removeWhitespaces "$line")"
#    for f in "${files[@]}" "${dirs[@]}" ; do [[ "$f" = "$line" ]] && isExisting=true && break ; done
#    [[ $isExisting = false ]] && filesNotExisting=("${filesNotExisting[@]}" "$line")
#
#  done
#  if [[ "${#filesNotExisting[@]}" -gt 0 ]]; then
#    echo "ERROR: index file has positions that not exists $path/$subPath/index"
#    for f in "${filesNotExisting[@]}" ; do echo " - $f" ; done
#    echo
#  fi
#
#
#
#  # for each file check if is indexed
#  local filesNotIndexed=()
#  for line in "${files[@]}"
#  do
#
#    local isIndexed=false
#    for f in "${indexFilesList[@]}"
#    do
#      if [[ "$f" = "$line" ]] || [[ "$f.sh" = "$line" ]] ; then
#        isExisting=true
#        break;
#      fi
#    done
#
#    [[ $isIndexed = false ]] && filesNotIndexed=("${filesNotIndexed[@]}" "$line")
#
#  done
#  if [[ "${#filesNotIndexed[@]}" -gt 0 ]]; then
#    echo "WARNING: there are files that might need to be indexed in directory $path/$subPath"
#    for f in "${filesNotIndexed[@]}" ; do echo " - $f" ; done
#    echo
#  fi
#
#
#
#  # for each directory check if is indexed
#  local dirsNotIndexed=()
#  for line in "${dirs[@]}"
#  do
#
#    local isIndexed=false
#    for f in "${indexFilesList[@]}" ; do [[ "$f" = "$line" ]] && isIndexed=true && break ; done
#    [[ $isIndexed = false ]] && dirsNotIndexed=("${dirsNotIndexed[@]}" "$line")
#
#  done
#  if [[ "${#dirsNotIndexed[@]}" -gt 0 ]]; then
#    echo "WARNING: there are directories that might need to be indexed in directory $path/$subPath"
#    for f in "${dirsNotIndexed[@]}" ; do echo " - $f" ; done
#    echo
#  fi
#
#
#
#  # recurrent for each directory
#  for d in "${dirs[@]}" ; do indexCheck_checkSourcesMainDir "$path" "$subPath/$d" ; done
#
#}
#
#
##
##function indexCheck_checkSourcesTestDir {
##  local path="$1"         ; shift
##  local subMainPath="$1"  ; shift
##  local subPath="$1"  ; shift
##
##
##
##  # read directory content
##  local hasIndex=false
##  local hasMainFile=false
##  local files=()
##  local dirs=()
##  local unknown=()
##
##  for f in `ls "$path/$subPath"`
##  do
##    [[ "$f" = "main.sh"       ]] && hasMainFile=true            && continue
##    [[ "$f" = "index"         ]] && hasIndex=true               && continue
##    [[ -f "$path/$subPath/$f" ]] && files=("${files[@]}" "$f")  && continue
##    [[ -d "$path/$subPath/$f" ]] && dirs=("${dirs[@]}" "$f")    && continue
##    unknown=("${unknown[@]}" "$f")
##  done
##
##
##
##  # check main.sh file existing
##
##  [[ $hasMainFile = true  ]] && echo "ERROR: file main.sh should never be in test directory $path/$subPath" && echo
##
##
##
##  # check index file
##
##  if [[ $hasIndex = true ]] ; then
##    # read index file
##    readarray -t indexFilesList < "$path/$subPath/index"
##    # waring if index is empty
##    [[ -z "${indexFilesList[*]}" ]] && echo "WARNING: empty index file may cause performance issues $path/$subPath/index" && echo
##  else
##    echo "ERROR: missing index file in directory: "$path/$subPath"" && echo
##  fi
##
##
##
##  # for each import file position check if is on files or dirs list
##  local filesNotExisting=()
##  for line in "${indexFilesList[@]}"
##  do
##
##    local isExisting=false
##    line="$(removeWhitespaces "$line")"
##    for f in "${files[@]}" "${dirs[@]}" ; do [[ "$f" = "$line" ]] && isExisting=true && break ; done
##    [[ $isExisting = false ]] && filesNotExisting=("${filesNotExisting[@]}" "$line")
##
##  done
##  if [[ "${#filesNotExisting[@]}" -gt 0 ]]; then
##    echo "ERROR: index file has positions that not exists $path/$subPath/index"
##    for f in "${filesNotExisting[@]}" ; do echo " - $f" ; done
##    echo
##  fi
##
##
##
##  # for each file check if is indexed
##  # and check if there is corresponding file in main directory
##  local filesNotIndexed=()
##  local filesHasNotMatchInMainDir=()
##  for line in "${files[@]}"
##  do
##
##    local isIndexed=false
##    for f in "${indexFilesList[@]}"
##    do
##      if [[ "$f" = "$line" ]] || [[ "$f.sh" = "$line" ]] ; then
##        isExisting=true
##      fi
##    done
##
##    [[ $isIndexed = false ]] && filesNotIndexed=("${filesNotIndexed[@]}" "$line")
##
##  done
##  if [[ "${#filesNotIndexed[@]}" -gt 0 ]]; then
##    echo "WARNING: there are files that might need to be indexed in directory $path/$subPath"
##    for f in "${filesNotIndexed[@]}" ; do echo " - $f" ; done
##    echo
##  fi
##
##
##
##  # for each directory check if is indexed
##  local dirsNotIndexed=()
##  for line in "${dirs[@]}"
##  do
##
##    local isIndexed=false
##    for f in "${indexFilesList[@]}" ; do [[ "$f" = "$line" ]] && isIndexed=true && break ; done
##    [[ $isIndexed = false ]] && dirsNotIndexed=("${dirsNotIndexed[@]}" "$line")
##
##  done
##  if [[ "${#dirsNotIndexed[@]}" -gt 0 ]]; then
##    echo "WARNING: there are directories that might need to be indexed in directory $path/$subPath"
##    for f in "${dirsNotIndexed[@]}" ; do echo " - $f" ; done
##    echo
##  fi
##
##
##
##
##  # recurrent for each directory
##  for d in "${dirs[@]}" ; do indexCheck_checkSourcesMainDir "$path" "$subPath/$d" ; done
##
##}
##

# engine-index-update.sh
function indexUpdate {
  local path="$1"        ; shift

  echo "index update $path"
}

# engine-main.sh
########### ENGINE MANAGEMENT #################################################

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
        echo "$path"
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
        buildProject "$path" "$@"
        exit 1
        ;;

      *)
        echo "ERROR: unknown options: $*"
        exit 1
        ;;

    esac
  done
}
# engine-utility.sh
function toUpperSnakeCase {
  local value="$(sed --expression 's/\([A-Z]\)/_\1/g' --expression 's/^_//' <<< "$1")"
  echo "${value^^}"
}

function pathToProjectName {
    local path="$1"
    local projectName=${path//*"\\"/}
    local projectName=${projectName//*"/"/}
    echo "$projectName"
}

function removeWhitespaces {
  local value=$1

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  echo "$value"
}
engine "$@"
