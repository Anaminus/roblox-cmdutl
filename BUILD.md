# Building

This project is built with the **plugin.lua** file. By default, plugin.lua runs
another lua file called **makeplugin.lua**, which is located in the working
directory. makeplugin.lua contains the specific building instructions.

All you really need to do is get a Lua interpreter, then run plugin.lua with
makeplugin.lua in the same directory.

plugin.lua is compatible with Lua 5.1 and 5.2.

Here's an example in Windows:

1. Download the Lua binary corresponding to your version of Windows:
	- [32-bit](http://sourceforge.net/projects/luabinaries/files/5.2/Executables/lua-5.2_Win32_bin.zip/download)
	- [64-bit](http://sourceforge.net/projects/luabinaries/files/5.2/Executables/lua-5.2_Win64_bin.zip/download)

2. Unzip to the same directory as plugin.lua.
3. Open command prompt in the same directory.
4. Do `Lua52 plugin.lua`.
5. Check for warnings. If it says "Done (0 warnings)", then the build was successful.
6. The results of the build will be located in the **build** folder.


Alternative binaries:

- [LuaBinaries Downloads](http://sourceforge.net/projects/luabinaries/files/5.2/Executables/)
- [LuaBinaries Website](http://luabinaries.sourceforge.net/)
- [List of Lua binaries](http://lua-users.org/wiki/LuaBinaries)
- [Lua for Windows](http://code.google.com/p/luaforwindows/)

Sublime Text 2 project build system:

	{
		"build_systems":
		[
			{
				"cmd":
				[
					"lua52",
					"plugin.lua"
				],
				"name": "Lua Build Plugin",
				"working_dir": "$project_path"
			}
		]
	}
