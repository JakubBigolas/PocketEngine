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