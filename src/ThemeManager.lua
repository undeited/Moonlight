local SchemeIndexes = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

local ThemeManager = {
	Library = nil,
	CurrentThemeName = nil,
	Watcher = nil,

	Themes = {
		["Moonlight"] = { FontColor = "e8eeff", MainColor = "10162c", AccentColor = "b0c4ff", BackgroundColor = "080b1a", OutlineColor = "2c3a64", FontFace = "Code" },
		["Halloween"] = { FontColor = "ffe8cc", MainColor = "1f1209", AccentColor = "ff7a00", BackgroundColor = "120a05", OutlineColor = "5a3414", FontFace = "Code" },
		["Christmas"] = { FontColor = "ffffff", MainColor = "12261a", AccentColor = "d42426", BackgroundColor = "0b1a10", OutlineColor = "2e6b3a", FontFace = "Code" },
		["St. Patricks"] = { FontColor = "e8ffe8", MainColor = "0d2415", AccentColor = "3ddc61", BackgroundColor = "07140b", OutlineColor = "1f5c32", FontFace = "Code" },
		["Easter"] = { FontColor = "fff7ff", MainColor = "241f33", AccentColor = "f7a8d8", BackgroundColor = "1a1626", OutlineColor = "4b4263", FontFace = "Code" },
	},
}

function ThemeManager:SetLibrary(Library)
	ThemeManager.Library = Library
end

local function GetEaster(Year: number): (number, number)
	local A = Year % 19
	local B = Year // 100
	local C = Year % 100
	local D = B // 4
	local E = B % 4
	local F = (B + 8) // 25
	local G = (B - F + 1) // 3
	local H = (19 * A + B - D - G + 15) % 30
	local I = C // 4
	local K = C % 4
	local L = (32 + 2 * E + 2 * I - H - K) % 7
	local M = (A + 11 * H + 22 * L) // 451
	local Total = H + L - 7 * M + 114

	return Total // 31, Total % 31 + 1
end

function ThemeManager:GetCurrentThemeName(): string
	local Now = os.date("*t")
	local Month, Day = Now.month, Now.day

	if Month == 10 and Day == 31 then
		return "Halloween"
	end

	if Month == 12 and Day == 25 then
		return "Christmas"
	end

	if Month == 3 and Day == 17 then
		return "St. Patricks"
	end

	local EasterMonth, EasterDay = GetEaster(Now.year)

	if Month == EasterMonth and Day == EasterDay then
		return "Easter"
	end

	return "Moonlight"
end

function ThemeManager:ApplyTheme(ThemeName: string): boolean
	local Library = ThemeManager.Library
	local Theme = ThemeManager.Themes[ThemeName]

	if not Library or not Theme then
		return false
	end

	for _, SchemeIndex in SchemeIndexes do
		Library.Scheme[SchemeIndex] = Color3.fromHex(Theme[SchemeIndex])
	end

	Library.Scheme.Font = Font.fromEnum(Enum.Font[Theme.FontFace])
	Library:UpdateColorsUsingRegistry()
	ThemeManager.CurrentThemeName = ThemeName

	return true
end

function ThemeManager:Start()
	ThemeManager:ApplyTheme(ThemeManager:GetCurrentThemeName())

	if ThemeManager.Watcher then
		return
	end

	ThemeManager.Watcher = task.spawn(function()
		repeat
			task.wait(60)

			if getgenv().MoonlightRunning then
				local ThemeName = ThemeManager:GetCurrentThemeName()

				if ThemeName ~= ThemeManager.CurrentThemeName then
					ThemeManager:ApplyTheme(ThemeName)
				end
			end
		until not getgenv().MoonlightRunning

		ThemeManager.Watcher = nil
	end)
end

getgenv().MoonlightThemeManager = ThemeManager
return ThemeManager
