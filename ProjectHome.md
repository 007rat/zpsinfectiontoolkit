Some big changes for the infection toolkit in the name of making it nicer:

Changed the name (since it no longer requires the C++ extension)

The library functions are all prefixed with ZIT

The offsets are loaded from a config file so there's no need to recompile for windows/linux or every time zps is updated

The simple example plugin is now just part of the plugin and the target arguments accept standard target style (#userid, or "username")

Special thanks:
Sammy-ROCK! for updating the infection time offset and adding the IsCarrier flag offset