do
	local Action = {
		Name = "Dragger";
	}

	local draggerObj
	local maid
	local down

	function Action:Initialize()
		draggerObj = Instance.new('Dragger')
		maid = CreateMaid()
		down = false
	end

	function Action:Start()
		maid.mouseDown = Mouse.Button1Down:connect(function()
			down = true
			maid.mouseUp = Mouse.Button1Up:connect(function()
				down = false
			end)
		end)
	end

	function Action:Stop()
		maid:DoCleaning()
		if down then
			draggerObj:MouseUp()
			down = false
		end
	end
end
