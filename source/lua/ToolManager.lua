--[[ToolManager

Only one tool can run at a time.

When an tool is added, it may be specified as an "ITool" (independent
tool), which means that it will run regardless of normal tools.

Tools are tables containing the following fields:
	Name

		A string indicating the name of the tool. This name is used when
		starting or stopping an tool.

	Start

		A function called when the tool is started.

	Stop

		A function called when the tool is stopped. This function should be
		able to handle 0 arguments, in the event that the tool is stopped
		when the ToolManager is stopped.

	Initialize

		An optional function called before the tool is started for the first
		time. After this function is called, the IsInitialized field will be
		set to true.

API:

Fields:

ToolManager.RunningTool

	The name of the tool that is currently running.

ToolManager.RunningITools

	A table of independent tools that are currently running. The table
	contains toolName=true pairs.

ToolManager.Tools

	A table of tools that have been added to the ToolManager. The table
	contains toolName=tool pairs.

ServiceStatus.Status
	Whether the service is started or not.


Methods:

ToolManager:AddTool ( tool, independent )

	`tool` is an tool table. `independent` is a bool indicating whether
	the tool is independent.

ToolManager:StartTool ( name, ... )

	Begins tool `name`. The remaining arguments are passed to the tool's
	Start function.

ToolManager:StopTool ( name, ... )

	Stops tool `name`, if it is running. The remaining arguments are passed
	to the tool's Start function.

ToolManager:Start ( )

	Starts the manager.

ToolManager:Stop ( )

	Stops the manager. Any running tools will be stopped.

Events:

ToolManager.ToolStarted ( name )
	Fired after tool `name` has been started.

ToolManager.ToolStopped ( name )
	Fired after tool `name` has been stopped.

]]

do
	local Tools = {}
	local ITools = {}
	local RunningITools = {}

	ToolManager = {
		Tools = Tools;
		RunningTool = nil;
		RunningITools = RunningITools;
	}

	local StartTool = {}
	local StopTool = {}
	local ToolRunning = {}
	ToolManager.ToolRunning = ToolRunning

	local eventToolStarted = CreateSignal(ToolManager,'ToolStarted')
	local eventToolStopped = CreateSignal(ToolManager,'ToolStopped')

	local function getfield(t,k,tv)
		if type(t[k]) ~= tv then
			error(string.format("bad field in table (%s expected, got %s)",tv,type(t[k])),3)
		end
		return t[k]
	end

	function ToolManager:AddTool(tool,independent)
		local name = getfield(tool,'Name','string')
		getfield(tool,'Start','function')
		getfield(tool,'Stop','function')

		if Tools[name] then
			error("tool `" .. name .. "` already exists",2)
		end

		Tools[name] = tool

		if independent then
			ITools[name] = true
		end
	end

	function ToolManager:StartTool(name,...)
		if self.Status('Stopped') or self.Status('Stopping') then return end

		if not Tools[name] then
			error("`" .. tostring(name) .. "` is not a valid tool",2)
		end

		if ITools[name] then
			if RunningITools[name] then
				self:StopTool(name)
			end
			if not Tools.IsInitialized and Tools[name].Initialize then
				Tools[name].Initialize()
				Tools.IsInitialized = true
			end
			if Tools[name].Start(...) ~= false then
				RunningITools[name] = true
				eventToolStarted:Fire(name)
			end
		else
			if self.RunningTool then
				self:StopTool(self.RunningTool)
			end
			if Tools[name].Start(...) ~= false then
				self.RunningTool = name
				eventToolStarted:Fire(name)
			end
		end
	end

	function ToolManager:StopTool(name,...)
		if not Tool[name] then
			error("`" .. tostring(name) .. "` is not a valid tool",2)
		end

		if ITools[name] then
			-- only stop if tool is running
			if RunningITools[name] then
				Tools[name].Stop(...)
				RunningITools[name] = nil
				eventToolStopped:Fire(name)
			end
		else
			if self.RunningTool == name then
				Tools[name].Stop(...)
				self.RunningTool = nil
				eventToolStopped:Fire(name)
			end
		end
	end

	AddServiceStatus(ToolManager,{
		Start = function()end;
		Stop = function(self)
			if self.RunningTool then
				self:StopTool(self.RunningTool)
			end
			for name in pairs(self.RunningITools) do
				self:StopTool(name)
			end
		end;
	})
end
