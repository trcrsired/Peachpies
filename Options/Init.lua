local AceAddon = LibStub("AceAddon-3.0")
local Peachpies = AceAddon:GetAddon("Peachpies")
local Peachpies_Options = AceAddon:NewAddon("Peachpies_Options","AceEvent-3.0")
Peachpies_Options.options = {
	type = "group",
	name = "Peachpies",
	args = {profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Peachpies.db)}
}
function Peachpies_Options:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Peachpies", Peachpies_Options.options)
	Peachpies.db.RegisterCallback(Peachpies_Options, "OnProfileChanged")
	Peachpies.db.RegisterCallback(Peachpies_Options, "OnProfileCopied", "OnProfileChanged")
	Peachpies.db.RegisterCallback(Peachpies_Options, "OnProfileReset", "OnProfileChanged")
end

function Peachpies_Options:Peachpies_ChatCommand(message,input)
	if not input or input:trim() == "" then
		LibStub("AceConfigDialog-3.0"):Open("Peachpies")
	else
		LibStub("AceConfigCmd-3.0"):HandleCommand("Peachpies", "Peachpies",input)
	end
end

function Peachpies_Options:OnProfileChanged()
	Peachpies_Options:SendMessage("Peachpies_OnProfileChanged")
end

function Peachpies_Options.set_func(info,val)
	local id = info[2]
	local p = Peachpies.db.profile[id][info[1]]
	local meta = getmetatable(p)
	local name = info[3]
	if meta[name] == val then
		val = nil
	end
	rawset(p,name,val)
	Peachpies_Options:SendMessage("Peachpies_OnProfileChanged")
end

function Peachpies_Options.get_func(info)
	return Peachpies.db.profile[info[2]][info[1]][info[3]]
end

function Peachpies_Options.set_func_color(info,r,g,b,a)
	local id = info[2]
	local p = Peachpies.db.profile[id][info[1]]
	local n = info[3]
	local meta = getmetatable(p)
	local function mrawset(c,val)
		local nm = n..c
		if meta[nm] == val then
			val = nil
		end
		rawset(p,nm,val)
	end
	mrawset("R",r)
	mrawset("G",g)
	mrawset("B",b)
	mrawset("A",a)
	coroutine.resume(Peachpies[info[1]][id],0)
end

function Peachpies_Options.get_func_color(info)
	local id = info[2]
	local p = Peachpies.db.profile[id][info[1]]
	local n = info[3]
	return p[n.."R"],p[n.."G"],p[n.."B"],p[n.."A"]
end

function Peachpies_Options.GenerateB(key,name,b)
	local gm = {}
	for k,v in pairs(Peachpies[key]) do
		gm[k] = 
		{
			name = k,
			type = "group",
			args = b
		}
	end
	Peachpies_Options.options.args[key] = 
	{
		type = "group",
		name = name,
		args = gm
	}
end
