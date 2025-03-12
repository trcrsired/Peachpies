local LibStub = LibStub
local AceAddon = LibStub("AceAddon-3.0")
local Peachpies = AceAddon:GetAddon("Peachpies")
local Peachpies_Options = AceAddon:NewAddon("Peachpies_Options","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Peachpies")
Peachpies_Options.options = {
	type = "group",
	name = "Peachpies",
	args = {profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Peachpies.db)}
}
function Peachpies_Options:OnInitialize()
	local profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Peachpies.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Peachpies", Peachpies_Options.options)
	local LibDualSpec = LibStub('LibDualSpec-1.0',true)
	if LibDualSpec then
		LibDualSpec:EnhanceOptions(profile, Peachpies.db)
	end
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
	local profile = Peachpies.GetProfile(info[2])
	local info1 = info[1]
	local pinfo1 = profile[info1]
	if pinfo1 == nil then
		pinfo1 = {}
		profile[info1] = pinfo1
	end
	local gridsdefault = Peachpies.modulesdefaultmetatable[info[1]]
	setmetatable(pinfo1,gridsdefault)
	return pinfo1[info[3]]
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
	Peachpies_Options:SendMessage("Peachpies_OnProfileChanged")
--	coroutine.resume(Peachpies[info[1]][id],0)
end

function Peachpies_Options.get_func_color(info)
	local id = info[2]
	local p = Peachpies.db.profile[id][info[1]]
	local n = info[3]
	return p[n.."R"],p[n.."G"],p[n.."B"],p[n.."A"]
end

function Peachpies_Options.GenerateB(key,name,b)
	local gm = {}

	local pkey = Peachpies[key]

	if next(pkey) == nil then
		return
	end

	for k,v in pairs(pkey) do
		local name_str
		local desc_str
		if k == "default" then
			name_str = DAMAGER
			desc_str = L.default_desc_str
		else
			local nameinfo = v.nameinfo
			local spellid = nameinfo.spellid
			name_str = nameinfo.name
			if name_str == nil and spellid then
				name_str = Peachpies.GetSpellInfo(spellid)
			elseif nameinfo.name_use_acelocale3 then
				name_str = L[desc_str]
			end
			desc_str = nameinfo.desc
			if nameinfo.desc_use_acelocale3 then
				desc_str = L[desc_str]
			end
		end
		gm[k] =
		{
			name = name_str,
			desc = desc_str,
			type = "group",
			args = b
		}
	end
	Peachpies_Options.options.args[key] = 
	{
		type = "group",
		name = name,
		args = gm,
		childGroups = "select"
	}
end
