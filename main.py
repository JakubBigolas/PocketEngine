import sys
import config
from modules.pe.app import App
from modules.pe.error import PeError

try:

    pocketEngine = App(config.get_app_config())

    args = sys.argv[1:]

    # always read default context
    args.insert(0, "c/default")

    pocketEngine.execute(args)

except PeError as e:
    print(e)
    exit(1)

exit(0)
