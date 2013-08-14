--[[ToolManager

Only one tool can run at a time.

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

	ToolManager = {
		Tools = Tools;
		RunningTool = nil;
	}

	local eventToolStarted = CreateSignal(ToolManager,'ToolStarted')
	local eventToolStopped = CreateSignal(ToolManager,'ToolStopped')

	local function getfield(t,k,tv)
		if type(t[k]) ~= tv then
			error(string.format("bad field in table (%s expected, got %s)",tv,type(t[k])),3)
		end
		return t[k]
	end

	function ToolManager:AddTool(tool)
		local name = getfield(tool,'Name','string')
		getfield(tool,'Start','function')
		getfield(tool,'Stop','function')

		if Tools[name] then
			error("tool `" .. name .. "` already exists",2)
		end

		Tools[name] = tool
	end

	function ToolManager:StartTool(name,...)
		if self.Status('Stopped') or self.Status('Stopping') then return end

		local tool = Tools[name]

		if not tool then
			error("`" .. tostring(name) .. "` is not a valid tool",2)
		end

		if self.RunningTool then
			self:StopTool(self.RunningTool)
		end
		if tool.Initialize and not tool.IsInitialized then
			if tool.Initialize(...) == false then
				return
			end
			tool.IsInitialized = true
		end
		if tool.Start(...) ~= false then
			self.RunningTool = name
			eventToolStarted:Fire(name)
		end
	end

	function ToolManager:StopTool(name,...)
		if not Tools[name] then
			error("`" .. tostring(name) .. "` is not a valid tool",2)
		end

		-- only stop if tool is running
		if self.RunningTool == name then
			Tools[name].Stop(...)
			self.RunningTool = nil
			eventToolStopped:Fire(name)
		end
	end

	AddServiceStatus(ToolManager,{
		Start = function()end;
		Stop = function(self)
			if self.RunningTool then
				self:StopTool(self.RunningTool)
			end
		end;
	})
end
