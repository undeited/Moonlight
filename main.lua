local BaseURL = "https://raw.githubusercontent.com/undeited/moonlight/main/src/"
local Order = { "Library", "ThemeManager", "SaveManager", "Icons", "Main", "Bootstrap" }

if type(loadstring) ~= "function" then
	return nil, "This executor does not support loadstring"
end

local function Fetch(Name)
	local Ok, Body = pcall(game.HttpGet, game, BaseURL .. Name .. ".lua", true)
	if not Ok or type(Body) ~= "string" or #Body < 16 or Body:sub(1, 14) == "404: Not Found" then
		return nil
	end
	return Body
end

local Sources = {}

for _, Name in ipairs(Order) do
	local Body = Fetch(Name) or Fetch(Name)
	if not Body then
		return nil, "Failed to fetch module: " .. Name
	end
	Sources[Name] = Body
end

local Run, Message = loadstring(Sources.Bootstrap, "@Moonlight/Bootstrap")
if not Run then
	return nil, Message
end

return Run(Sources)
