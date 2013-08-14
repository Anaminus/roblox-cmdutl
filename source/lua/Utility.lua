local function getarg(n,arg,argtype,default)
	if type(argtype) == 'table' then
		default = default or {}
		for i = 1,#argtype do
			local value = arg[i]
			if default[i] ~= nil and value == nil then
				arg[i] = default[i]
			elseif type(value) ~= argtype[i] then
				error(string.format("bad argument #%d (%s expected, got %s)",i+n-1,argtype[i],type(value)),3)
			end
		end
		return unpack(arg)
	else
		if default ~= nil and arg == nil then
			return default
		elseif type(arg) ~= argtype then
			error(string.format("bad argument #%d (%s expected, got %s)",n,argtype,type(arg)),3)
		end
		return arg
	end
end

function Preload(content)
	Game:GetService('ContentProvider'):Preload(content)
	return content
end

InternalSettings = {
	GuiColor = {
		Background      = Color3.new(233/255, 233/255, 233/255);
		Border          = Color3.new(149/255, 149/255, 149/255);
		Selected        = Color3.new( 63/255, 119/255, 189/255);
		Text            = Color3.new(  0/255,   0/255,   0/255);
		TextDisabled    = Color3.new(128/255, 128/255, 128/255);
		TextSelected    = Color3.new(255/255, 255/255, 255/255);
		Button          = Color3.new(221/255, 221/255, 221/255);
		ButtonBorder    = Color3.new(149/255, 149/255, 149/255);
		ButtonSelected  = Color3.new(255/255,   0/255,   0/255);
		Field           = Color3.new(255/255, 255/255, 255/255);
		FieldBorder     = Color3.new(191/255, 191/255, 191/255);
		TitleBackground = Color3.new(178/255, 178/255, 178/255);
	};
	GuiButtonSize = 32+6;
	GuiWidgetSize = 16;
	IconMap = {};
}

-- Sets the properties of a new or existing Instance using values from a table.
local function Create(ty,data)
	local obj
	if type(ty) == 'string' then
		obj = Instance.new(ty)
	else
		obj = ty
	end
	for k, v in pairs(data) do
		if type(k) == 'number' then
			v.Parent = obj
		else
			obj[k] = v
		end
	end
	return obj
end

--Gets a descendant of an object by child order
function DescendantByOrder(object,...)
	local children = object:GetChildren()
	for i,v in pairs{...} do
		object = children[v]
		if not object then return nil end
		children = object:GetChildren()
	end
	return object
end

--[[Enums, CreateEnum
A system for custom enums.

API:
	CreateEnum(string,table)

		Returns a new enum. This Enum is also added to the Enums table.

	Enums[string]

		Returns an Enum.

	Enum.EnumItemName

		Gets an EnumItem.

	EnumItem:GetEnumItems()

		Returns a list of the Enum's EnumItems.

	Enum(value)

		Returns the EnumItem that matches the value, by the EnumItem, or its
	    Name or Value. Returns nil if no match is found.

	EnumItem.Name

		The name of the EnumItem.

	EnumItem.Value

		The EnumItem's Value.

	EnumItem(value)

		Returns whether the value matches the EnumItem, or its Name or Value.

]]
local Enums do
	Enums = {}
	local EnumName = {} -- used as unique key for enum name
	local enum_mt = {
		__call = function(self,value)
			return self[value] or self[tonumber(value)]
		end;
		__index = {
			GetEnumItems = function(self)
				local t = {}
				for i,item in pairs(self) do
					if type(i) == 'number' then
						t[#t+1] = item
					end
				end
				table.sort(t,function(a,b) return a.Value < b.Value end)
				return t
			end;
		};
		__tostring = function(self)
			return "Enum." .. self[EnumName]
		end;
	}
	local item_mt = {
		__call = function(self,value)
			return value == self or value == self.Name or value == self.Value
		end;
		__tostring = function(self)
			return "Enum." .. self[EnumName] .. "." .. self.Name
		end;
	}
	function CreateEnum(enumName,t)
		local e = {[EnumName] = enumName}
		for i,name in pairs(t) do
			local item = setmetatable({Name=name,Value=i,Enum=e,[EnumName]=enumName},item_mt)
			e[i] = item
			e[name] = item
			e[item] = item
		end
		Enums[enumName] = e
		return setmetatable(e,enum_mt)
	end
end

-- Adds values to a class that enable it to be started and stopped.
do
	local enumServiceStatus = CreateEnum('ServiceStatus',{'Stopped','Started','Starting','Stopping'})
	function AddServiceStatus(service,data)
		local start = data.Start
		local stop = data.Stop
		service.Status = enumServiceStatus.Stopped
		service.Start = function(...)
			if enumServiceStatus.Stopped(service.Status) then
				service.Status = enumServiceStatus.Starting
				start(...)
				service.Status = enumServiceStatus.Started
			end
		end
		service.Stop = function(...)
			if enumServiceStatus.Started(service.Status) then
				service.Status = enumServiceStatus.Stopping
				stop(...)
				service.Status = enumServiceStatus.Stopped
			end
		end
	end
end

function CreateSignal(instance,name)
	local connections = {}
	local waitEvent = Instance.new('BoolValue')
	local waitArguments = {} -- holds arguments from Fire to be returned by event:wait()

	local Event = {}
	local Invoker = {Event = Event}

	function Event:connect(func)
		local connection = {connected = true}
		function connection:disconnect()
			for i = 1,#connections do
				if connections[i][2] == self then
					table.remove(connections,i)
					break
				end
			end
			self.connected = false
		end
		connections[#connections+1] = {func,connection}
		return connection
	end

	function Event:wait()
		waitEvent.Changed:wait()
		return unpack(waitArguments) -- leaky
	end

	function Invoker:Fire(...)
		waitArguments = {...}
		waitEvent.Value = not waitEvent.Value
		for i,conn in pairs(connections) do
			conn[1](...)
		end
	end

	function Invoker:Destroy()
		instance[name] = nil
		for k in pairs(Event) do
			Event[k] = nil
		end
		for k in pairs(Invoker) do
			Invoker[k] = nil
		end
		for i in pairs(connections) do
			connections[i] = nil
		end
		for i in pairs(waitArguments) do
			waitArguments[i] = nil
		end
		waitEvent:Destroy()
	end

	instance[name] = Event
	return Invoker
end

--[[Maid
Manages the cleaning of events and other things.

API:
	Maid[key] = (function)

		Adds a task to perform when cleaning up.

	Maid[key] = (event connection)

		Manages an event connection. Anything that isn't a function is assumed
		to be this.

	Maid[key] = nil

		Removes a named task. If the task is an event, it is disconnected.

	Maid:GiveTask(task)

		Same as above, but uses an incremented number as a key.

	Maid:DoCleaning()

		Disconnects all managed events and performs all clean-up tasks.

]]
do
	local index = {
		GiveTask = function(self,task)
			local n = #self.Tasks+1
			self.Tasks[n] = task
			return n
		end;
		DoCleaning = function(self)
			local tasks = self.Tasks
			for name,task in pairs(tasks) do
				if type(task) == 'function' then
					task()
				else
					task:disconnect()
				end
				tasks[name] = nil
			end
		end;
	};
	local mt = {
		__index = function(self,k)
			if index[k] then
				return index[k]
			else
				return self.Tasks[k]
			end
		end;
		__newindex = function(self,k,v)
			local tasks = self.Tasks
			if v == nil then
				-- disconnect if the task is an event
				if type(tasks[k]) ~= 'function' then
					tasks[k]:disconnect()
				end
			elseif tasks[k] then
				-- clear previous task
				self[k] = nil
			end
			tasks[k] = v
		end;
	}
	function CreateMaid()
		return setmetatable({Tasks={}},mt)
	end
end

--[[EvaluateInput

Converts a string to a number by evaluating the string as a Lua, allowing
mathematical expressions to be used. All members of the math library can be
used (i.e. "sqrt(2)"). The variables "x" and "n" are also defined, whose
values may be previous input.

Arguments:
	expression
		The string to be evaluated.

	predefinedValues
		A table of values to be added to the environment of the expression.
		Optional.

Returns:
	evaluatedNumber
		The number evaluated from the expression. This value will be nil if
		the expression had bad syntax or the output could not be converted to
		a number.

]]
do
	local mathEnvironment = {
		abs = math.abs; acos = math.acos; asin = math.asin; atan = math.atan; atan2 = math.atan2;
		ceil = math.ceil; cos = math.cos; cosh = math.cosh; deg = math.deg;
		exp = math.exp; floor = math.floor; fmod = math.fmod; frexp = math.frexp;
		huge = math.huge; ldexp = math.ldexp; log = math.log; log10 = math.log10;
		max = math.max; min = math.min; modf = math.modf; pi = math.pi;
		pow = math.pow; rad = math.rad; random = math.random; sin = math.sin;
		sinh = math.sinh; sqrt = math.sqrt; tan = math.tan; tanh = math.tanh;
	}

	if _VERSION == 'Lua 5.2' then
		function EvaluateInput(str,values)
			local env = {}
			for k,v in pairs(mathEnvironment) do
				env[k] = v
			end
			if values then
				for k,v in pairs(values) do
					env[k] = v
				end
			end
			local f = load("return "..s,nil,nil,env)
			if f then
				local s,o = pcall(f)
				if s then return tonumber(o) end
			end
			return nil
		end
	else
		function EvaluateInput(str,values)
			local env = {}
			for k,v in pairs(mathEnvironment) do
				env[k] = v
			end
			if values then
				for k,v in pairs(values) do
					env[k] = v
				end
			end
			local f = loadstring("return "..str)
			if f then
				setfenv(f,env)
				local s,o = pcall(f)
				if s then return tonumber(o) end
			end
			return nil
		end
	end
end

-- returns the bounding box for a group of objects
-- returns Vector3 `size`, Vector3 `position`
-- may also return a list of parts in the bounding box
local GetBoundingBox do
	local bbPoints = {
		Vector3.new(-1,-1,-1);
		Vector3.new( 1,-1,-1);
		Vector3.new(-1, 1,-1);
		Vector3.new( 1, 1,-1);
		Vector3.new(-1,-1, 1);
		Vector3.new( 1,-1, 1);
		Vector3.new(-1, 1, 1);
		Vector3.new( 1, 1, 1);
	}

	-- helper for GetBoundingBox
	local function recurseGetBoundingBox(object,sides,parts)
		if object:IsA"BasePart" then
			local mod = object.Size/2
			local rot = object.CFrame
			for i = 1,#bbPoints do
				local point = rot*CFrame.new(mod*bbPoints[i]).p
				if point.x > sides[1] then sides[1] = point.x end
				if point.x < sides[2] then sides[2] = point.x end
				if point.y > sides[3] then sides[3] = point.y end
				if point.y < sides[4] then sides[4] = point.y end
				if point.z > sides[5] then sides[5] = point.z end
				if point.z < sides[6] then sides[6] = point.z end
			end
			if parts then parts[#parts + 1] = object end
		end
		local children = object:GetChildren()
		for i = 1,#children do
			recurseGetBoundingBox(children[i],sides,parts)
		end
	end

	function GetBoundingBox(objects,return_parts)
		local sides = {-math.huge;math.huge;-math.huge;math.huge;-math.huge;math.huge}
		local parts
		if return_parts then
			parts = {}
		end
		for i = 1,#objects do
			recurseGetBoundingBox(objects[i],sides,parts)
		end
		return
			Vector3.new(sides[1]-sides[2],sides[3]-sides[4],sides[5]-sides[6]),
			Vector3.new((sides[1]+sides[2])/2,(sides[3]+sides[4])/2,(sides[5]+sides[6])/2),
			parts
	end
end
