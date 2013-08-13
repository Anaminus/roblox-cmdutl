--[[Command

Implements a command system that pushes onto the history stack. An argument
fitler allows multiple types of history patterns to be used.

API:

Command:Add ( name, command, inverse, filter )

	`name`

		The name of the command. Must be unique.

	`command`

		The function to execute.

	`inverse`

		The inverse function of `command`.

	`filter`

		Receives the arguments to be passed to `command`, and returns the
		arguments to be passed to `inverse`. Arguments are filtered when the
		command is run. These filtered arguments are pushed onto the history
		stack. When the inverse of the command is called, then the filtered
		arguments are used.

	Memento Pattern:
		(Save current state to stack; use same command to revert to state)
		command ( obj, name )
			obj.Name = name
		filter ( obj, name )
			-- save current state
			return obj, obj.Name
		inverse (obj, name )
			-- same function as command
			obj.Name = name

	Command Pattern:
		(Apply inverse of command using the same arguments)
		command ( obj, change )
			obj.Position = obj.Position + change
		filter ( ... )
			-- reuse same arguments
			return ...
		inverse ( obj, change )
			-- logical inverse of command
			obj.Positon = obj.Position - change


Command:Do ( name, ... )

	Executes command `name` with `...` as arguments. Pushes command to
	history.

Command:Undo ( )
	Undoes the most recently done command.

Command:Redo ( )
	Redoes the most recently undone command.

]]

do
	Command = {}
	local commandLookup = {}
	local inverseLookup = {}
	local filterLookup = {}

	local historyPast = {}
	local historyFuture = {}

	function Command:Add(name,command,inverse,filter)
		if commandLookup[name] then
			error("command `" .. tostring(name) .. "` already exists",2)
		end

		commandLookup[name] = command
		inverseLookup[name] = inverse or command
		filterLookup[name] = filter or nil
	end

	function Command:Do(name,...)
		local command = commandLookup[name]
		if not command then
			error("invalid command `" .. tostring(name) .. "`",2)
		end

		local filteredArgs = nil
		if filterLookup[name] then
			filteredArgs = {filterLookup[name](...)}
		end

		-- push command onto history stack
		table.insert(historyPast,{
			command;
			{...};
			inverseLookup[name];
			filteredArgs;
		})
		-- reset redo stack
		historyFuture = {}

		command(...)
	end

	function Command:Undo()
		local cmd = table.remove(historyPast)
		if cmd then
			table.insert(historyFuture,cmd)
			;(cmd[3] or cmd[1])(unpack(cmd[4] or cmd[2]))
			return true
		end
		return false
	end

	function Command:Redo()
		local cmd = table.remove(historyFuture)
		if cmd then
			table.insert(historyFuture,cmd)
			cmd[1](unpack(cmd[2]))
			return true
		end
		return false
	end
end
