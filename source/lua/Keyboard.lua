--[[Keyboard

]]

do
	Keyboard = {
		shiftActive = false;
		capslockActive = false;
	}

	local Player = Game:GetService('Players').LocalPlayer
	local Mouse = Player:GetMouse()

	local char = string.char

	local conflictGroup = {
		['numlock'] = {
			active = false;
			[true ] = {
				[char(  8)] = 'kp8';
				[char(  9)] = 'kp9';
				[char( 13)] = 'kp-';
			};
			[false] = {
				[char(  8)] = 'backspace';
				[char(  9)] = 'tab';
				[char( 13)] = 'return';
			};
		};
		['system']= {
			active = false;
			[true ] = {
				[char( 19)] = 'pause';
				[char( 61)] = 'print';
			};
			[false] = {
				[char( 19)] = 'right';
				[char( 61)] = '=';
			};
		};
		['func'] = {
			active = false;
			[true ] = {
				[char( 27)] = 'f2';
				[char( 32)] = 'f7';
			};
			[false] = {
				[char( 27)] = 'escape';
				[char( 32)] = ' ';
			};
		};
		['modifier'] = {
			active = false;
			[true ] = {
				[char( 44)] = 'numlock';
				[char( 45)] = 'capslock';
				[char( 46)] = 'scrollock';
				[char( 47)] = 'rshift';
				[char( 48)] = 'lshift';
				[char( 49)] = 'rctrl';
				[char( 50)] = 'lctrl';
				[char( 51)] = 'ralt';
				[char( 52)] = 'lalt';
				[char( 53)] = 'rsuper';
				[char( 54)] = 'lsuper';
			};
			[false] = {
				[char( 44)] = ',';
				[char( 45)] = '-';
				[char( 46)] = '.';
				[char( 47)] = '/';
				[char( 48)] = '0';
				[char( 49)] = '1';
				[char( 50)] = '2';
				[char( 51)] = '3';
				[char( 52)] = '4';
				[char( 53)] = '5';
				[char( 54)] = '6';
			};
		};
	}

	local keyConstant = {
		[char(  0)] = 'kp0';
		[char(  1)] = 'kp1';
		[char(  2)] = 'kp2';
		[char(  3)] = 'kp3';
		[char(  4)] = 'kp4';
		[char(  5)] = 'kp5';
		[char(  6)] = 'kp6';
		[char(  7)] = 'kp7';
		[char(  8)] = conflictGroup.numlock;
		[char(  9)] = conflictGroup.numlock;
		[char( 10)] = 'kp.';
		[char( 11)] = 'kp/';
		[char( 12)] = 'kp*';
		[char( 13)] = conflictGroup.numlock;
		[char( 14)] = 'kp+';
		[char( 15)] = 'kpenter';

		[char( 17)] = 'up';
		[char( 18)] = 'down';
		[char( 19)] = conflictGroup.system;
		[char( 20)] = 'left';
		[char( 21)] = 'insert';
		[char( 22)] = 'home';
		[char( 23)] = 'end';
		[char( 24)] = 'pageup';
		[char( 25)] = 'pagedown';
		[char( 26)] = 'f1';
		[char( 27)] = conflictGroup.func;
		[char( 28)] = 'f3';
		[char( 29)] = 'f4';
		[char( 30)] = 'f5';
		[char( 31)] = 'f6';
		[char( 32)] = conflictGroup.func;
		[char( 33)] = 'f8';
		[char( 34)] = 'f9';
		[char( 35)] = 'f10';
		[char( 36)] = 'f11';
		[char( 37)] = 'f12';

		[char( 39)] = '\'';

		[char( 44)] = conflictGroup.modifier;
		[char( 45)] = conflictGroup.modifier;
		[char( 46)] = conflictGroup.modifier;
		[char( 47)] = conflictGroup.modifier;
		[char( 48)] = conflictGroup.modifier;
		[char( 49)] = conflictGroup.modifier;
		[char( 50)] = conflictGroup.modifier;
		[char( 51)] = conflictGroup.modifier;
		[char( 52)] = conflictGroup.modifier;
		[char( 53)] = conflictGroup.modifier;
		[char( 54)] = conflictGroup.modifier;
		[char( 55)] = '7';
		[char( 56)] = '8';
		[char( 57)] = '9';

		[char( 59)] = ';';

		[char( 61)] = conflictGroup.system;

		[char( 63)] = 'menu';

		[char( 91)] = '[';
		[char( 92)] = '\\';
		[char( 93)] = ']';

		[char( 96)] = '`';
		[char( 97)] = 'a';
		[char( 98)] = 'b';
		[char( 99)] = 'c';
		[char(100)] = 'd';
		[char(101)] = 'e';
		[char(102)] = 'f';
		[char(103)] = 'g';
		[char(104)] = 'h';
		[char(105)] = 'i';
		[char(106)] = 'j';
		[char(107)] = 'k';
		[char(108)] = 'l';
		[char(109)] = 'm';
		[char(110)] = 'n';
		[char(111)] = 'o';
		[char(112)] = 'p';
		[char(113)] = 'q';
		[char(114)] = 'r';
		[char(115)] = 's';
		[char(116)] = 't';
		[char(117)] = 'u';
		[char(118)] = 'v';
		[char(119)] = 'w';
		[char(120)] = 'x';
		[char(121)] = 'y';
		[char(122)] = 'z';

		[char(127)] = 'delete';
	}

	local shiftMap = {
		['a'] = 'A'; ['b'] = 'B'; ['c'] = 'C'; ['d'] = 'D';
		['e'] = 'E'; ['f'] = 'F'; ['g'] = 'G'; ['h'] = 'H';
		['i'] = 'I'; ['j'] = 'J'; ['k'] = 'K'; ['l'] = 'L';
		['m'] = 'M'; ['n'] = 'N'; ['o'] = 'O'; ['p'] = 'P';
		['q'] = 'Q'; ['r'] = 'R'; ['s'] = 'S'; ['t'] = 'T';
		['u'] = 'U'; ['v'] = 'V'; ['w'] = 'W'; ['x'] = 'X';
		['y'] = 'Y'; ['z'] = 'Z'; ['1'] = '!'; ['2'] = '@';
		['3'] = '#'; ['4'] = '$'; ['5'] = '%'; ['6'] = '^';
		['7'] = '&'; ['8'] = '*'; ['9'] = '('; ['0'] = ')';
		['`'] = '~'; ['-'] = '_'; ['='] = '+'; ['['] = '{';
		[']'] = '}'; ['\\']= '|'; [';'] = ':'; ['\'']= '"';
		[','] = '<'; ['.'] = '>'; ['/'] = '?';
	}

	local capsMap = {
		['a'] = 'A'; ['b'] = 'B'; ['c'] = 'C'; ['d'] = 'D';
		['e'] = 'E'; ['f'] = 'F'; ['g'] = 'G'; ['h'] = 'H';
		['i'] = 'I'; ['j'] = 'J'; ['k'] = 'K'; ['l'] = 'L';
		['m'] = 'M'; ['n'] = 'N'; ['o'] = 'O'; ['p'] = 'P';
		['q'] = 'Q'; ['r'] = 'R'; ['s'] = 'S'; ['t'] = 'T';
		['u'] = 'U'; ['v'] = 'V'; ['w'] = 'W'; ['x'] = 'X';
		['y'] = 'Y'; ['z'] = 'Z'; ['A'] = 'a'; ['B'] = 'b';
		['C'] = 'c'; ['D'] = 'd'; ['E'] = 'e'; ['F'] = 'f';
		['G'] = 'g'; ['H'] = 'h'; ['I'] = 'i'; ['J'] = 'j';
		['K'] = 'k'; ['L'] = 'l'; ['M'] = 'm'; ['N'] = 'n';
		['O'] = 'o'; ['P'] = 'p'; ['Q'] = 'q'; ['R'] = 'r';
		['S'] = 's'; ['T'] = 't'; ['U'] = 'u'; ['V'] = 'v';
		['W'] = 'w'; ['X'] = 'x'; ['Y'] = 'y'; ['Z'] = 'z';
	}

	local function getKey(c)
		local key = keyConstant[c]
		if type(key) == 'table' then
			key = key[key.active][c]
		end
		if not key then
			key = 'undefined_' .. c:byte()
		end
		if Keyboard.shiftActive then
			key = shiftMap[key] or key
		end
		if Keyboard.capslockActive then
			key = capsMap[key] or key
		end
		return key
	end

	local keyState = {}
	Mouse.KeyDown:connect(function(c)
		local key = getKey(c)
		keyState[key] = true
	end)
	Mouse.KeyUp:connect(function(c)
		local key = getKey(c)
		keyState[key] = nil
	end)

	function Keyboard.isDown(key)
		return not not keyState[key]
	end

	function Keyboard.setConflictState(group,active)
		if conflictGroup[group] then
			conflictGroup[group].active = not not active
		end
	end
end
