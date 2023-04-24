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