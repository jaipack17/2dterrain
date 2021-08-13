--[[
	You can fidget around with the values down below
]]--

-- terrain colors

local terraincolors = {
	water = Color3.fromRGB(85, 170, 255),
	sand = Color3.fromRGB(255, 242, 166),
	grass = Color3.fromRGB(85, 170, 0)
}

-- module

local TerrainModule = {}
TerrainModule.__index = TerrainModule

function TerrainModule.new(canvas: Instance)
	local ongen = Instance.new("BindableEvent")
	ongen.Name = "Generated"
	ongen.Parent = canvas
	
    local self = setmetatable({
		_terrain = canvas
	}, 	TerrainModule)
	
	return self
end

function TerrainModule:gen(cellsize: Vector2, scale: number) 
	
	--[[
		this function generates new terrain.
		Instance terrain - cells will be placed inside here
        Vector2 cellsize - size of each cell
        number scale - used for perlin noise pattern scale
	]]--

	local width = self._terrain.AbsoluteSize.x
	local height = self._terrain.AbsoluteSize.y
	
	-- clean terrain
	
	self._terrain:ClearAllChildren()
	
	-- generating colors for each cell
	
	local function genColor(x: number, y: number)
		math.randomseed(os.time()) -- generating seed
		local n = math.noise(x * scale, y * scale, math.random() * 100) -- 100 is some random constant
		
		if n < 0 then 
			return terraincolors.water
		elseif n < .1 then
			return terraincolors.sand
		elseif n < 1 then
			return terraincolors.grass
		end
	end
	
	-- forming terrain
		
	local cellsOnX = width/(cellsize.x)
	local cellsOnY = height/(cellsize.y)
	
	for cellx = 0, cellsOnX do
		for celly = 0, cellsOnY do
			local selectedcolor = genColor(cellx, celly)

			local tile = Instance.new("Frame")
			tile.Name = "TerrainCell"
			tile.Size = UDim2.new(0, cellsize.x, 0, cellsize.y)
			tile.Position = UDim2.new(0, cellx * cellsize.x, 0, celly * cellsize.y)
			tile.BorderColor3 = selectedcolor
			tile.BackgroundColor3 = selectedcolor
			tile.Parent = self._terrain			
		end
	end
	
	-- firing our event after terrain is generated
	
	if self._callback then self._callback() end
end

function TerrainModule:callback(func)
	assert(typeof(func) == "function", "argument must be a function")
	self._callback = func
end

return TerrainModule
