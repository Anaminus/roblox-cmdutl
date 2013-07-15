META.PLUGIN_NAME = "CmdUtl"
META.PLUGIN_VERSION = "6.0"

read ( META )
read [[lua/Utility.lua]]
read [[lua/Plugin.lua]]
read [[lua/CommandManager.lua]]
read [[lua/ActionManager.lua]]
read [[lua/Initialize.lua]]
write ( META.PLUGIN_NAME .. [[.lua]] )

read [[images/icon.png]]

bwrite ( META.PLUGIN_NAME .. [[.png]] )
