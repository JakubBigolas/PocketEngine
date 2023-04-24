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