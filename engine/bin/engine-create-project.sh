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
