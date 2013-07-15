--[==[

plugin.lua

	Combines together multiple Lua files into a single Roblox plugin file.

	This program attempts to run a "makefile". This file is used to determine
	how the Lua files will be combined. It also defines extra information
	about the plugin.

	This program can be run with the following arguments, all of which are
	optional:

		lua plugin.lua [file] [-p]

		file

			Specifies the location of the makefile. If unspecified, then this
			program attempts to open "makeplugin.lua" in the current directory.

		-p

			Indicates that the program should attempt to automatically output
			the plugin to Roblox's plugin folder.

]==]

local warningCount = 0
local function warn(...)
	warningCount = warningCount + 1
	print(...)
end

-- OS_TYPE=(windows|unix)
-- OS_VERSION=(win5|win6|osx)
local OS_TYPE,OS_VERSION do
	local function capture(cmd,raw)
		local file = io.popen(cmd,'r')
		if not file then return nil end
		local content = file:read('*a')
		file:close()
		return raw and content or content:gsub('^%s+',''):gsub('%s+$',''):gsub('[\r\n]+',' ')
	end

	-- try windows
	local ver = capture[[ver]]
	if #ver == 0 then
		-- not windows, try unix
		ver = capture[[uname -v]]
		OS_TYPE = 'unix'
	else
		OS_TYPE = 'windows'
	end

	local versionPatterns = {
		['^Microsoft Windows .-%[Version 5.-%]$'] = 'win5';
		['^Microsoft Windows .-%[Version 6.-%]$'] = 'win6';
		['^Darwin Kernel Version .-$']            = 'osx';
	}

	for pattern,name in pairs(versionPatterns) do
		if ver:match(pattern) then
			OS_VERSION = name
			break
		end
	end

	if not OS_TYPE then
		warn("could not determine operating system type; some features may not be available")
	end

	if not OS_VERSION then
		warn("could not determine operating system version; some features may not be available")
	end
end

local function getopt(args)
	local opt = {}
	for i = 1,#args do
		local arg = args[i]
		if arg:sub(1,1) == '-' then
			opt[arg:sub(2)] = true
		else
			opt[#opt+1] = arg
		end
	end
	return opt
end

-- expand environment variables
-- also normalize separators
local expandPath do
	if OS_TYPE == 'windows' then
		function expandPath(path)
			path = path:gsub('%%([%a_][%w_]-)%%',os.getenv):gsub('/','\\'):gsub('\\+','\\')
			return path
		end
	elseif OS_TYPE == 'unix' then
		function expandPath(path)
			path = path:gsub('^~','$HOME')
			path = path:gsub('$([%a_][%w_]*)',os.getenv):gsub('\\','/'):gsub('/+','/')
			return path
		end
	else
		function expandPath(path)
			return path:gsub('\\','/'):gsub('/+','/')
		end
	end
end

-- attempt to create subfolders that don't exist
local function makeFolderPath(path,...)
	if not OS_TYPE then return end
	path = expandPath(path)
	local folders = {...}
	for i = 1,#folders do
		path = expandPath(path .. "/" .. folders[i])
		-- syntax should be valid on both windows and unix
		local r = os.execute('mkdir "' .. path .. '"')
		if r == 0 then
			print("created folder `" .. path .. "`")
		end
	end
end

-- get a list of folders from a file path
local function getFolderList(path)
	path = path:gsub('\\','/'):match([[^(.+/).+$]])
	local folders = {}
	for folder in path:gmatch("[^/]+") do
		folders[#folders+1] = folder
	end
	return folders
end

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-- run makefile

local options = getopt{...}
local makePath = options[1] or "makeplugin.lua"
local currentFile = {}
local readData = {}

-- environment for makefile
local makeEnv = setmetatable({
	META = {};
	read = function(path)
		if type(path) == 'string' or type(path) == 'table' then
			currentFile[#currentFile+1] = path
		else
			warn("argument `" .. tostring(path) .. "` must be a string or table")
		end
	end;
	write = function(path)
		readData[#readData+1] = {
			currentFile; -- read
			path; -- write
			false; -- binary
		}
		-- reset current file
		currentFile = {}
	end;
	bwrite = function(path)
		readData[#readData+1] = {
			currentFile; -- read
			path; -- write
			true; -- binary
		}
		currentFile = {}
	end;
},{__index=_G})


local makeFile
if _VERSION == 'Lua 5.2' then
	local make,err = loadfile(makePath,'bt',makeEnv)
	if not make then
		warn("ERROR:" .. err)
		return
	end
	makeFile = make
else
	local make,err = loadfile(makePath)
	if not make then
		warn("ERROR:" .. err)
		return
	end
	setfenv(make,makeEnv)
	makeFile = make
end

makeFile()

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-- handle makefile results

if type(makeEnv.META) ~= 'table' then
	warn("ERROR: META must be a table")
	return
end

if type(makeEnv.META.PLUGIN_NAME) ~= 'string' then
	warn("ERROR: META.PLUGIN_NAME must be defined as a string")
	return
end

local writeData = {}
for i = 1,#readData do
	local read = readData[i][1]
	local write = readData[i][2]
	local binary = readData[i][3]

	print("building `" .. expandPath(write) .. "`")

	local content = ""
	for i = 1,#read do
		local path = read[i]
		if type(path) == 'string' then
			path = expandPath('source/' .. path)
			local f = io.open(path,binary and 'rb' or 'r')
			if f then
				local c = f:read('*a')
				f:close()
				content = content .. c .. "\n"
				print("appended `" .. path .. "`")
			else
				warn("could not open `" .. path .. "`")
			end
		elseif type(path) == 'table' then
			local sorted = {}
			for k in pairs(path) do
				sorted[#sorted+1] = k
			end
			table.sort(sorted)
			for i = 1,#sorted do
				local name = sorted[i]
				if name:match('^[%a_][%w_]*$') then
					local value = path[name]
					content = content .. name .. " = "
					if type(value) == 'string' then
						content = content .. string.format('%q',value)
					else
						content = content .. tostring(value)
					end
					content = content .. "\n"
					print("appended variable `" .. name .. "`")
				end
			end
			content = content .. "\n"
		end
	end

	writeData[i] = {
		write; -- path
		binary; -- binary
		content; -- content
	}
end

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-- write content to output file

local pluginName = makeEnv.META.PLUGIN_NAME

local function writeFiles(path,...)
	-- verify that plugin path exists
	local pluginPath do
		pluginPath = path
		for _,folder in pairs({...}) do
			pluginPath = pluginPath .. "/" .. folder
		end

		local temp = expandPath(pluginPath .. "/temp")

		local file = io.open(temp,'w')
		if not file then
			makeFolderPath(path,...)
			file = io.open(temp,'w')
		end

		if not file then
			warn("cannot open `" .. expandPath(pluginPath) .. "`; certain folders may be missing")
			return
		end

		file:close()
		if not os.remove(temp) then
			warn("could not remove temporary file")
		end
	end

	-- write each file
	for i = 1,#writeData do
		local path = writeData[i][1]
		local binary = writeData[i][2]
		local content = writeData[i][3]

		local fileName = expandPath(pluginPath .. '/' .. path)
		local file = io.open(fileName, binary and 'wb' or 'w')

		if not file then
			-- create subfolders that don't exist
			makeFolderPath(pluginPath, unpack(getFolderList(path)) )
			file = io.open(fileName, binary and 'wb' or 'w')
		end

		if not file then
			warn("could not write `" .. fileName .. "`")
		else
			file:write(content)
			file:flush()
			file:close()
			print("wrote to `" .. fileName .. "`")
		end
	end

end

-- always write to build folder
writeFiles(".","build",pluginName)

-- write to plugin folder if -p option is given
if options.p then
	-- find the path of the plugins folder from the GlobalSettings file
	if not OS_VERSION then
		warn("could not locate plugin path: unknown operating system")
	else
		local settingsPath = ({
			win5 = [[%USERPROFILE%/Local Settings/Application Data/Roblox/GlobalSettings_13.xml]];
			win6 = [[%LOCALAPPDATA%/Roblox/GlobalSettings_13.xml]];
			osx = [[$HOME/Library/Roblox/GlobalSettings_13.xml]];
		})[OS_VERSION]

		-- read settings file
		settingsPath = expandPath(settingsPath)
		local f = io.open(settingsPath)
		if not f then
			warn("could not locate plugin path: could not open settings file located at:\n" .. settingsPath)
		else
			local content = f:read('*a')
			f:close()

			-- find plugin path
			local pluginPath = content:match[[<QDir name="PluginsDir">(.-)</QDir>]]
			if not pluginPath then
				warn("could not locate plugin path: could not find PluginsDir setting")
			else
				writeFiles(pluginPath,pluginName)
			end
		end
	end
end

print("Done (" .. warningCount .. " warnings)")
return
