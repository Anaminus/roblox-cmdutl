PluginData = {
	Toolbar = "Plugins";
	ActivationButton = {"", "Open " .. PLUGIN_NAME, PLUGIN_NAME .. ".png"};
}

--[[PluginActivator
A wrapper for a plugin that consists of one toolbar and a single button.
The button is used to toggle whether the wrapper is active or not.

API:
	PluginActivator.Plugin            The Plugin object.
	PluginActivator.Toolbar           The Toolbar object.
	PluginActivator.Button            The Button object.
	PluginActivator.IsInitialized     Whether the plugin has been initialized.
	PluginActivator.IsActive          Whether the plugin is active.

	PluginActivator:Start()           Starts detecting plugin events.

	PluginActivator.Initialized       Fired before the plugin activates for the first time.
	PluginActivator.Activated         Fired after the plugin activates.
	PluginActivator.Deactivated       Fired after the plugin deactivates.
]]

do
	local Plugin = PluginManager():CreatePlugin()
	local Toolbar = Plugin:CreateToolbar(PluginData.Toolbar)
	local Button = Toolbar:CreateButton(unpack(PluginData.ActivationButton))

	PluginActivator = {
		Plugin = Plugin;
		Toolbar = Toolbar;
		Button = Button;
		IsInitialized = false;
		IsActive = false;
		OnInitialize = function()end;
		OnActivate = function()end;
		OnDeactivate = function()end;
	}

	local eventInitialized = CreateSignal(PluginActivator,'Initialized')
	local eventActivated = CreateSignal(PluginActivator,'Activated')
	local eventDeactivated = CreateSignal(PluginActivator,'Deactivated')

	function PluginActivator:Start()
		Button.Click:connect(function()
			if self.IsActive then
				self.IsActive = false
				-- automatically deactivates
				Button:SetActive(false)
			else
				if not self.IsInitialized then
					eventInitialized:Fire()
					self.IsInitialized = true
				end
				self.IsActive = true
				Plugin:Activate(true)
				Button:SetActive(true)
				eventActivated:Fire()
			end
		end)
		Plugin.Deactivation:connect(function()
			self.IsActive = false
			Button:SetActive(false)
			if self.IsInitialized then
				eventDeactivated:Fire()
			end
		end)
	end
end

local Mouse = PluginActivator.Plugin:GetMouse()
