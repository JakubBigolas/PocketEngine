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
