--[[CommandManager

CommandManager:Add(cmd, args, func)

	Adds a command.

	`cmd`
		The name of the command.

	`args`
		A list of the possible arguments to the command.

		{
			{ name, type, default }
			...
		}

	`func`

CommandManager:Run(cmd, args)
CommandManager:Dump(cmd)

]]

do
	CommandManager = {}

	local cmdFunc = {}
	local cmdArgName = {}
	local cmdArgType = {}
	local cmdArgDefault = {}
	local cmdDesc = {}

	function CommandManager:Add(cmd,func,args,desc)
		getarg(1,cmd,'string')
		getarg(2,func,'function')
		getarg(3,args,'table')
		desc = getarg(4,desc,'string','No description.')

		if cmdFunc[cmd] then
			error("a `" .. cmd .. "` command has already been defined",2)
		end
		cmdFunc[cmd] = func

		local argName = {}
		local argType = {}
		local argDefault = {}
		for i = 1,#args do
			argName[i] = args[i][1]
			argType[i] = args[i][2]
			argDefault[i] = args[i][3]
		end
		cmdArgName[cmd] = argName
		cmdArgType[cmd] = argType
		cmdArgDefault[cmd] = argDefault

		cmdDesc[cmd] = desc
	end

	function CommandManager:Run(cmd,args)
		getarg(1,cmd,'string')
		if not cmdFunc[cmd] then
			return false,"command `" .. cmd .. "` is not a valid command"
		end

		local argList = {}
		local argName = cmdArgName[cmd]
		local argDefault = cmdArgDefault[cmd]
		for i = 1,#argName do
			if args[argName[i]] ~= nil then
				argList[i] = args[argName[i]]
			elseif args[i] ~= nil then
				argList[i] = args[i]
			else
				argList[i] = argDefault[i]
			end
		end

		cmdFunc[cmd](unpack(argList,1,#argName))
		return true
	end

	function CommandManager:Dump(cmd)
		if cmd ~= nil then
			getarg(1,cmd,'string')
			if not cmdFunc[cmd] then
				return "Invalid command  `" .. cmd .. "`"
			end

			local msg = cmd .. " ("

			local argName = cmdArgName[cmd]
			local argType = cmdArgType[cmd]
			local argDefault = cmdArgDefault[cmd]
			for i = 1,#argName do
				if i ~= 1 then
					msg = msg .. ","
				end
				msg = msg .. " " .. argName[i] .. ":" .. (argType[i] or "*")
				if argDefault[i] ~= nil then
					msg = msg .. " = " .. tostring(argDefault[i])
				end
			end
			return msg .. " )"
		else
			local sorted = {}
			for cmd in pairs(cmdFunc) do
				sorted[#sorted+1] = cmd
			end
			table.sort(sorted)

			local msg = self:Dump(sorted[1])
			for i = 2,#sorted do
				msg = msg .. "\n" .. self:Dump(sorted[i])
			end
			return msg
		end
	end
end
