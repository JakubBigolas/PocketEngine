[[ ! -f "$POCKET_ENGINE_HOME/engine/engine.sh" ]] && echo "ERROR: PocketEngine home variable not set properly: \$POCKET_ENGINE_HOME=$POCKET_ENGINE_HOME" && exit 1

########### MANAGEMENT / PUBLIC INTERFACE ####################################################

function engineCreateContext {
  local home="$1"

  engineImport "$POCKET_ENGINE_HOME"
  [[ ! "$POCKET_ENGINE_HOME" = "$home" ]] && engineImport "$home"

  # read main file
  . "$home/src/main/script/main.sh"
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
  POCKET_ENGINE_ENABLE_TESTS=false
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

  file=$(cat "$home/$path/index")
  [[ -z $file ]] && file=`ls "$home/$path"`
  for line in $file
  do
      line="${line//[$'\t\r\n']/}"
      [[ $line =~ index      ]]  && continue # ommit comment lines
      [[ $line =~ main.sh    ]]  && continue # ommit comment lines
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

  if [[ -f "$fullpath" ]] || [[ -f "$fullpath.sh" ]]; then
    engineReadIndexFile "$home" "$path" "$file"
  elif [[ -d "$fullpath" ]]; then
    engineReadIndex "$home" "$path/$file"
  else
    echo "ERROR: cannot read sources from $fullpath"
    echo "ERROR: cannot read sources from $fullpath.sh"
  fi
}

function engineReadIndexFile {
  local home="$1"
  local path="$2"
  local file="$3"

  local fullpath="$home/$path/$file"
  [[ -f "$fullpath"    ]] && . "$fullpath"
  [[ -f "$fullpath.sh" ]] && . "$fullpath.sh"
}

########### TEST SOURCES ######################################################

function engineRunIndexTests {
  local home="$1"
  local path="$2"

  file=$(cat "$home/$path/index")
  [[ -z $file ]] && file=`ls "$home/$path"`
  for line in $file
  do
      line="${line//[$'\t\r\n']/}"
      [[ $line =~ index      ]]  && continue # ommit comment lines
      [[ $line =~ main.sh    ]]  && continue # ommit comment lines
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

  if [[ -f "$fullpath" ]] || [[ -f "$fullpath.sh" ]]; then
    engineTestIndexFile "$home" "$path" "$file"
  elif [[ -d "$fullpath" ]]; then
    engineRunIndexTests "$home" "$path/$file"
  else
    echo "ERROR: cannot read sources from $fullpath"
    exit
  fi
}

function engineTestIndexFile {
  local home="$1"
  local path="$2"
  local file="$3"
  local fullpath="$home/${path/main/test}/$file"

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