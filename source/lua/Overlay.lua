--[[Overlay

]]

function CreateOverlay()
	local overlay = {}

	local CoreGui = Game:GetService("CoreGui")
	local adornmentSet = {}
	local overlayPart = Create 'Part' {
		Name			= "SelectionOverlay";
		Anchored		= true;
		CanCollide		= false;
		Locked			= true;
		FormFactor		= "Custom";
		TopSurface		= 0;
		BottomSurface	= 0;
		Transparency	= 1;
		Archivable		= false;
	}

	overlay.Adorn = adornmentSet

	function overlay:RemoveAdorn(name)
		local adornment = adornmentSet[name]
		adornmentSet[name] = nil
		adornment:Destroy()
	end

	function overlay:NewAdorn(name,class,props)
		local properties = {
			Adornee		= overlayPart;
			Archivable	= false;
		}
		for k,v in pairs(props) do
			properties[k] = v
		end
		local adornment = Create(class)(properties)
		adornment.Name = name
		if adornmentSet[name] then
			self:RemoveAdorn(name)
		end
		adornmentSet[name] = adornment
		return adornment
	end

	function overlay:SetParent(parent)
		for name,adornment in pairs(adornmentSet) do
			adornment.Parent = parent
		end
	end

	function overlay:Clear()
		for name,adornment in pairs(adornmentSet) do
			adornmentSet[name] = nil
			adornment:Destroy()
		end
	end

	function overlay:SetSize(size)
		local cf = overlayPart.CFrame
		overlayPart.Size = size
		overlayPart.CFrame = cf
	end

	function overlay:Wrap(object,min_size)
		if type(object) == "table" then
			if #object > 0 then
				local size,pos,parts = GetBoundingBox(object,true)
				if min_size and size.magnitude < min_size.magnitude then
					overlayPart.Size = min_size
				else
					overlayPart.Size = size
				end
				overlayPart.CFrame = CFrame.new(pos)
				self:SetParent(CoreGui)
				return size,pos,parts
			else
				self:SetParent(nil)
			end
		elseif object == nil then
			self:SetParent(nil)
		elseif object:IsA"BasePart" then
			local size,pos = object.Size,object.CFrame
			if min_size and size.magnitude < min_size.magnitude then
				overlayPart.Size = min_size
			else
				overlayPart.Size = size
			end
			overlayPart.CFrame = pos
			self:SetParent(CoreGui)
			return size,pos
		end
	end

	function overlay:Destroy()
		setmetatable(self,nil)
		self:Clear()
		overlayPart:Destroy()
		for k in pairs(self) do
			self[k] = nil
		end
	end

	setmetatable(overlay,{
		__index = overlayPart;
		__newindex = overlayPart;
	})
end
