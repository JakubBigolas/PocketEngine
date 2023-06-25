


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



