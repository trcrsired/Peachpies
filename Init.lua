local Peachpies = LibStub("AceAddon-3.0"):NewAddon("Peachpies","AceEvent-3.0","AceConsole-3.0")
local cvar_width,cvar_height

if GetCurrentScaledResolution then
	cvar_width,cvar_height=GetCurrentScaledResolution()
else
	cvar_width,cvar_height = string.match(GetScreenResolutions(), "(%d+)x(%d+)")
	cvar_width = tonumber(cvar_width)
	cvar_height = tonumber(cvar_height)
end
Peachpies.cvar_width = cvar_width
Peachpies.cvar_height = cvar_height
Peachpies.cvar_min = min(cvar_width,cvar_height)

local C_AddOns = C_AddOns
if C_AddOns == nil then
	C_AddOns = _G
end

local LoadAddOn = C_AddOns.LoadAddOn
local GetNumAddOns = C_AddOns.GetNumAddOns
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetAddOnInfo = C_AddOns.GetAddOnInfo

function Peachpies:OnInitialize()
	local LibStub = LibStub
	self.db = LibStub("AceDB-3.0"):New("PeachpiesDB",{},true)
	local LibDualSpec = LibStub('LibDualSpec-1.0',true)
	if LibDualSpec then
		LibDualSpec:EnhanceDatabase(self.db, "Peachpies")
	end
	self:RegisterChatCommand("Peachpies", "ChatCommand")
	local _,_,classId = UnitClass("player")
	local classidstr = tostring(classId)
	local GetAddOnMetadata = GetAddOnMetadata
	local gmatch = gmatch
	local LoadAddOn = LoadAddOn
	for i = 1, GetNumAddOns() do
		if GetAddOnMetadata(i,"X-Peachpies-CLASS") == classidstr then
			LoadAddOn(i)
		end
		local event = GetAddOnMetadata(i, "X-Peachpies-EVENT")
		if event then
			self:RegisterEvent(event,"loadevent",i)
		end
		local messages = GetAddOnMetadata(i,"X-Peachpies-MESSAGE")
		if messages then
			for message in gmatch(messages, "([^,]+)") do
				self:RegisterMessage(message,"loadevent",i)
			end
		end
	end
end

function Peachpies:ChatCommand(input)
	self:SendMessage("Peachpies_ChatCommand",input)
end

function Peachpies:loadevent(p,event,...)
	Peachpies:UnregisterEvent(event)
	Peachpies:UnregisterMessage(event)
	if IsAddOnLoaded(p) then
		self:SendMessage(event,...)
		return true
	end
	LoadAddOn(p)
	if IsAddOnLoaded(p) then
		local addon = GetAddOnInfo(p)
		local a = LibStub("AceAddon-3.0"):GetAddon(addon)
		a[event](a,event,...)
		return true
	end
end


if GetSpellCooldown then
Peachpies.GetSpellCooldown = GetSpellCooldown
else
local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
function Peachpies.GetSpellCooldown(...)
	local t = C_Spell_GetSpellCooldown(...)
	return t.startTime, t.duration, t.isEnabled, t.modRate
end
end

if IsUsableSpell then
Peachpies.IsUsableSpell = IsUsableSpell
else
Peachpies.IsUsableSpell = C_Spell.IsSpellUsable
end

if GetSpellCharges then
	Peachpies.GetSpellCharges = GetSpellCharges
else
	Peachpies.GetSpellCharges = C_Spell.GetSpellCharges
end

if UnitAura then
	Peachpies.UnitAura = UnitAura
else
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local AuraUtil_UnpackAuraData = AuraUtil.UnpackAuraData
function Peachpies.UnitAura(...)
	local auraData = C_UnitAuras_GetAuraDataByIndex(...)
	if not auraData then
		return
	end
	return AuraUtil_UnpackAuraData(auraData)
end

end

if GetSpellInfo then
	Peachpies.GetSpellInfo = GetSpellInfo
else
	local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
	function Peachpies.GetSpellInfo(...)
		local spellInfo = C_Spell_GetSpellInfo(...)
		if spellInfo == nil then
			return
		end
		-- name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon
		return spellInfo.name, spellInfo.rank, spellInfo.iconID, spellInfo.castTime,
			spellInfo.minRange, spellInfo.maxRange, spellInfo.maxRange, spellInfo.originalIconID
	end
end

if GetSpellTexture then
	local GetSpellTexture = GetSpellTexture
	Peachpies.GetSpellTexture = function(spellIdentifier)
		local filedataid = GetSpellTexture(spellIdentifier)
		return filedataid,filedataid
	end
else
	Peachpies.GetSpellTexture = C_Spell.GetSpellTexture
end

local coroutines = {}
Peachpies.coroutines = coroutines

local modulesdefaultmetatable = {}
Peachpies.modulesdefaultmetatable = modulesdefaultmetatable

function Peachpies.AddCoroutine(co)
	coroutines[#coroutines+1]=co
end

function Peachpies.GetProfile(key)
	if key == nil then
		key = "default"
	end
	local profile = Peachpies.db.profile
	local t = profile[key]
	if t == nil then
		t = {}
		profile[key] = t
	end
	return t
end

function Peachpies.AddComponentNameinfo(key,component_meta,nameinfo)
	local component = Peachpies[key]
	if nameinfo then
		component_meta.nameinfo = nameinfo
		component[nameinfo.key] = component_meta
	else
		component.default = component_meta
	end
end

local function cofunc()
	local current = coroutine.running()
	local coresume = coroutine.resume
	local coyield = coroutine.yield
	local function resume(...)
		coresume(current,...)
	end
	local ticker
	Peachpies:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED",resume,0)
	Peachpies:RegisterEvent("PLAYER_TALENT_UPDATE",resume,0)
	Peachpies:RegisterMessage("Peachpies_OnProfileChanged",resume,0)
	local UnitIsUnit = UnitIsUnit
	local function functionresume(tag,s,unit,...)
		if unit == "player" or UnitIsUnit(unit,"player") then
			coresume(current,tag,s,unit,...)
		end
	end
	local runnings = {}
	local yd,p1,p2,p3,p4,p5,p6,p7 = 0
	local running_level
	while true do
		if yd == 0 then
			running_level = nil
			for i=1,#coroutines do
				local status,yval = coresume(coroutines[i],0)
				if status then
					if yval then
						if running_level == nil then
							running_level = 0
						end
						if running_level < yval then
							running_level = yval
						end
						runnings[i] = yval
					else
						runnings[i] = false
					end
				else
					Peachpies:Print(status,yval)
				end
			end
			if running_level then
				if 1 < running_level then
					Peachpies:RegisterEvent("ACTIONBAR_UPDATE_STATE",resume,2)
					Peachpies:RegisterEvent("ACTIONBAR_UPDATE_USABLE",resume,2)
					Peachpies:RegisterEvent("SPELL_UPDATE_CHARGES",resume,2)
					Peachpies:RegisterEvent("PLAYER_TARGET_CHANGED",resume,2)
				end
				if 2 < running_level then
					Peachpies:RegisterEvent("UNIT_SPELLCAST_SENT",functionresume,3)
					Peachpies:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED",functionresume,3)
				end
				if 3 < running_level then
					Peachpies:RegisterEvent("UNIT_HEALTH",resume,4)
				end
				if 4 < running_level then
					Peachpies:RegisterEvent("UNIT_AURA",resume,5)
				end
				if ticker == nil then
					ticker = C_Timer.NewTicker(0.05,function()
						coroutine.resume(current,1)
					end)
				end
			else
				Peachpies:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
				Peachpies:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")
				Peachpies:UnregisterEvent("SPELL_UPDATE_CHARGES")
				Peachpies:UnregisterEvent("PLAYER_TARGET_CHANGED")
				Peachpies:UnregisterEvent("UNIT_SPELLCAST_SENT")
				Peachpies:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
				Peachpies:UnregisterEvent("UNIT_HEALTH")
				Peachpies:UnregisterEvent("UNIT_AURA")
				if ticker then
					ticker:Cancel()
					ticker = nil
				end
			end
			yd = 1
		end
		if running_level then
			for i=1,#coroutines do
				local running_val = runnings[i]
				if running_val and yd <= running_val then
					local status,yval = coresume(coroutines[i],yd,p1,p2,p3,p4,p5,p6,p7)
					if not status then
						Peachpies:Print(status,i,yval)
						runnings[i]=false
					end
				end
			end
		end
		yd,p1,p2,p3,p4,p5,p6,p7 = coyield()
	end
end

function Peachpies:OnEnable()
	if #coroutines ~= 0 then
		coroutine.wrap(cofunc)()
	end
end
local IsItemInRange = IsItemInRange
local CheckInteractDistance = CheckInteractDistance
local UnitInRange = UnitInRange
local InCombatLockdown = InCombatLockdown
local UnitIsVisible = UnitIsVisible

function Peachpies.unit_range(uId)
	if InCombatLockdown() then
		return
	end
	if IsItemInRange(90175, uId) then return 4
	elseif IsItemInRange(16114, uId) then return 6
	elseif IsItemInRange(8149, uId) then return 8
	elseif CheckInteractDistance(uId, 3) then return 10
	elseif CheckInteractDistance(uId, 2) then return 11
	elseif IsItemInRange(32321, uId) then return 13
	elseif IsItemInRange(6450, uId) then return 18
	elseif IsItemInRange(21519, uId) then return 23
	elseif IsItemInRange(13289, uId) then return 28
	elseif CheckInteractDistance(uId, 1) then return 30
	elseif IsItemInRange(1180, uId) then return 33
	elseif UnitInRange(uId) then return 43
	elseif IsItemInRange(32698, uId) then return 48
	elseif IsItemInRange(116139, uId) then return 53
	elseif IsItemInRange(32825, uId) then return 60
	elseif IsItemInRange(35278, uId) then return 80
	end
end

if WOW_PROJECT_MAINLINE == WOW_PROJECT_MAINLINE then

local C_PvP_IsPVPMap = C_PvP.IsPVPMap

function Peachpies.player_in_pvp()
	return C_PvP_IsPVPMap()
end

else

Peachpies.player_in_pvp = nop

end

if IsSpellKnown then
Peachpies.is_spell_known = IsSpellKnown
elseif IsUsableSpell then
Peachpies.is_spell_known = IsUsableSpell
else
Peachpies.is_spell_known = function() return true end
end

local is_spell_known = Peachpies.is_spell_known

local GetSpellCooldown = Peachpies.GetSpellCooldown

local function is_spell_not_cooldown(spellid)
	local start, duration, enabled, modRate = GetSpellCooldown(spellid)

	local _, gcd_duration = GetSpellCooldown(61304)
	if duration == gcd_duration or duration == 0 then
		return true
	end
	return false
end

Peachpies.is_spell_not_cooldown = is_spell_not_cooldown

local function is_spell_known_not_cooldown(spellid)
	if not is_spell_known(spellid) then
		return nil
	end
	local start, duration, enabled, modRate = GetSpellCooldown(spellid)

	local _, gcd_duration = GetSpellCooldown(61304)
	if duration == gcd_duration or duration == 0 then
		return true
	end
	return false
end

Peachpies.is_spell_known_not_cooldown = is_spell_known_not_cooldown

function Peachpies.monitor_spells_maximum(tb)
	local maximum_count = 0
	for i=1,#tb do
		local tbi = tb[i]
		if maximum_count < #tbi then
			maximum_count = #tbi
		end
	end
	return maximum_count,tb
end

local UnitCanAttack = UnitCanAttack
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates

local unit_range = Peachpies.unit_range

function Peachpies.enemies_in_range_count(range)
	local count = 0
	local nameplates = C_NamePlate_GetNamePlates()
	if nameplates then
		for i=1,#nameplates do
			local utoken = nameplates[i].namePlateUnitToken
			if utoken then
				if UnitCanAttack("player",utoken) then
					local rg = unit_range(utoken)
					if rg and rg <= range then
						count = count + 1
					end
				end
			end
		end
	end
	return count
end

local UnitAura = Peachpies.UnitAura

function Peachpies.AurasList(tb,auras,unit,filter)
	if tb == nil then
		tb = {}
	end
	wipe(tb)
	local gtime = GetTime()
	for i=1,100 do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
		nameplateShowPersonal, spellId = UnitAura(unit,i,filter)
		if name == nil then
			break
		end
		if (expirationTime == 0 or gtime <= expirationTime) and (auras == nil or auras[spellId]) then
			tb[spellId] = i
		end
	end
	return tb
end
