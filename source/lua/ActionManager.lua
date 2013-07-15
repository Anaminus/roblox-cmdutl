--[[ActionManager

Only one action can run at a time.

When an action is added, it may be specified as an "IAction" (independent
action), which means that it will run regardless of normal actions.

Actions are tables containing the following fields:
	Name

		A string indicating the name of the action. This name is used when
		starting or stopping an action.

	Start

		A function called when the action is started.

	Stop

		A function called when the action is stopped. This function should be
		able to handle 0 arguments, in the event that the action is stopped
		when the ActionManager is stopped.

	Initialize

		An optional function called before the action is started for the first
		time. After this function is called, the IsInitialized field will be
		set to true.

API:

Fields:

ActionManager.RunningAction

	The name of the action that is currently running.

ActionManager.RunningIActions

	A table of independent actions that are currently running. The table
	contains actionName=true pairs.

ActionManager.Actions

	A table of actions that have been added to the ActionManager. The table
	contains actionName=action pairs.

ServiceStatus.Status
	Whether the service is started or not.


Methods:

ActionManager:AddAction ( action, independent )

	`action` is an action table. `independent` is a bool indicating whether
	the action is independent.

ActionManager:StartAction ( name, ... )

	Begins action `name`. The remaining arguments are passed to the action's
	Start function.

ActionManager:StopAction ( name, ... )

	Stops action `name`, if it is running. The remaining arguments are passed
	to the action's Start function.

ActionManager:Start ( )

	Starts the manager.

ActionManager:Stop ( )

	Stops the manager. Any running actions will be stopped.

Events:

ActionManager.ActionStarted ( name )
	Fired after action `name` has been started.

ActionManager.ActionStopped ( name )
	Fired after action `name` has been stopped.

]]

do
	local Actions = {}
	local IActions = {}
	local RunningIActions = {}

	ActionManager = {
		Actions = Actions;
		RunningAction = nil;
		RunningIActions = RunningIActions;
	}

	local StartAction = {}
	local StopAction = {}
	local ActionRunning = {}
	ActionManager.ActionRunning = ActionRunning

	local eventActionStarted = CreateSignal(ActionManager,'ActionStarted')
	local eventActionStopped = CreateSignal(ActionManager,'ActionStopped')

	local function getfield(t,k,tv)
		if type(t[k]) ~= tv then
			error(string.format("bad field in table (%s expected, got %s)",tv,type(t[k])),3)
		end
		return t[k]
	end

	function ActionManager:AddAction(action,independent)
		local name = getfield(action,'Name','string')
		getfield(action,'Start','function')
		getfield(action,'Stop','function')

		if Actions[name] then
			error("action `" .. name .. "` already exists",2)
		end

		Actions[name] = action

		if independent then
			IActions[name] = true
		end
	end

	function ActionManager:StartAction(name,...)
		if self.Status('Stopped') or self.Status('Stopping') then return end

		if not Actions[name] then
			error("`" .. tostring(name) .. "` is not a valid action",2)
		end

		if IActions[name] then
			if RunningIActions[name] then
				self:StopAction(name)
			end
			if not Actions.IsInitialized and Actions[name].Initialize then
				Actions[name].Initialize()
				Actions.IsInitialized = true
			end
			if Actions[name].Start(...) ~= false then
				RunningIActions[name] = true
				eventActionStarted:Fire(name)
			end
		else
			if self.RunningAction then
				self:StopAction(self.RunningAction)
			end
			if Actions[name].Start(...) ~= false then
				self.RunningAction = name
				eventActionStarted:Fire(name)
			end
		end
	end

	function ActionManager:StopAction(name,...)
		if not Action[name] then
			error("`" .. tostring(name) .. "` is not a valid action",2)
		end

		if IActions[name] then
			-- only stop if action is running
			if RunningIActions[name] then
				Actions[name].Stop(...)
				RunningIActions[name] = nil
				eventActionStopped:Fire(name)
			end
		else
			if self.RunningAction == name then
				Actions[name].Stop(...)
				self.RunningAction = nil
				eventActionStopped:Fire(name)
			end
		end
	end

	CommandManager:Add('start-action',{{"name",'string'}},function(name,...)
		ActionManager:StartAction(name,...)
	end)

	CommandManager:Add('stop-action',{{"name",'string'}},function(name,...)
		ActionManager:StopAction(name,...)
	end)

	AddServiceStatus(ActionManager,{
		Start = function()end;
		Stop = function(self)
			if self.RunningAction then
				self:StopAction(self.RunningAction)
			end
			for name in pairs(self.RunningIActions) do
				self:StopAction(name)
			end
		end;
	})
end
