local AceAddon = LibStub("AceAddon-3.0")
local Peachpies = AceAddon:GetAddon("Peachpies")
local Peachpies_Options = AceAddon:GetAddon("Peachpies_Options")
local LSM = LibStub("LibSharedMedia-3.0")

local cvar_width,cvar_height,cvar_min = Peachpies.cvar_width,Peachpies.cvar_height,cvar_min

local set_func = Peachpies_Options.set_func
local get_func = Peachpies_Options.get_func
local set_func_color = Peachpies_Options.set_func_color
local get_func_color = Peachpies_Options.get_func_color

local order = 0
local function get_order()
	local temp = order
	order = order + 1
	return temp
end

Peachpies_Options.GenerateB("grids","Grids",
{
	Enable =
	{
		name = ENABLE,
		type = "toggle",
		order = get_order(),
		set = set_func,
		get = get_func,
	},
	Lock =
	{
		name = LOCK,
		type = "toggle",
		order = get_order(),
		set = set_func,
		get = get_func,
	},
	x =
	{
		name = "x",
		type = "range",
		min = -cvar_width/2,
		max = cvar_width/2,
		step = 1,
		order = get_order(),
		set = set_func,
		get = get_func,
	},
	y =
	{
		name = "y",
		type = "range",
		min = -cvar_height/2,
		max = cvar_height/2,
		step = 1,
		order = get_order(),
		set = set_func,
		get = get_func,
	},
	Size = 
	{
		name = "Size",
		type = "range",
		min = 0,
		max = cvar_min,
		step = 1,
		order = get_order(),
		set = set_func,
		get = get_func,
	},
	CenterTextFont = 
	{
		type = 'select',
		dialogControl = 'LSM30_Font',
		name = "CENTER",
		values = LSM:HashTable("font"),
		set = set_func,
		get = get_func,
	},
	CenterTextSize =
	{
		name = "Center Text Size",
		type = "range",
		min = 0,
		max = 500,
		step = 1,
		set = set_func,
		get = get_func,
	},
	BottomTextFont = 
	{
		type = 'select',
		dialogControl = 'LSM30_Font',
		name = "Bottom Text Font",
		values = LSM:HashTable("font"),
		set = set_func,
		get = get_func,
	},
	BottomTextSize =
	{
		name = "Bottom Text Size",
		type = "range",
		min = 0,
		max = 500,
		step = 1,
		set = set_func,
		get = get_func,
	},
	LowColor =
	{
		type = "color",
		order = get_order(),
		name = LOW,
		hasAlpha = true,
		set = set_func_color,
		get = get_func_color,
	},
	MidColor =
	{
		type = "color",
		order = get_order(),
		name = PLAYER_DIFFICULTY1,
		hasAlpha = true,
		set = set_func_color,
		get = get_func_color,
	},
	HighColor =
	{
		type = "color",
		order = get_order(),
		name = HIGH,
		hasAlpha = true,
		set = set_func_color,
		get = get_func_color,
	},
	BottomTextColor =
	{
		type = "color",
		order = get_order(),
		name = "Bottom Text",
		hasAlpha = true,
		set = set_func_color,
		get = get_func_color,
	}
})
