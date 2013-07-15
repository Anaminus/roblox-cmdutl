PluginActivator.Initialized:connect(function()
	print("INIT",PLUGIN_NAME,PLUGIN_VERSION)
end)

PluginActivator.Activated:connect(function()
	ActionManager:Start()
	print("ACTIVATE",PLUGIN_NAME,PLUGIN_VERSION)
end)

PluginActivator.Deactivated:connect(function()
	print("DEACTIVATE",PLUGIN_NAME,PLUGIN_VERSION)
end)

PluginActivator:Start()
