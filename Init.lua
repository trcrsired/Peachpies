local Peachpies = LibStub("AceAddon-3.0"):NewAddon("Peachpies","AceEvent-3.0","AceConsole-3.0")

function Peachpies:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("PeachpiesDB",{},true)
	self:RegisterChatCommand("Peachpies", "ChatCommand")
	local _,_,classId = UnitClass("player")
	local classidstr = tostring(classId)
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

local coroutines = {}
Peachpies.coroutines = coroutines

local modulesdefaultmetatable = {}
Peachpies.modulesdefaultmetatable = modulesdefaultmetatable

function Peachpies.AddCoroutine(co)
	coroutines[#coroutines+1]=co
end

function Peachpies.GetProfile(name)
	local profile = Peachpies.db.profile
	local t = profile[name]
	if t == nil then
		t = {}
		profile[name] = t
	end
	return t
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
	local function functionresume(tag,_,unit)
		if unit == "player" or UnitIsUnit(unit,"player") then
			coresume(current,tag)
		end
	end
	local runnings = {}
	local yd = 0
	local fullyrunning
	while true do
		if yd == 0 then
			fullyrunning = nil
			for i=1,#coroutines do
				local status,yval = coresume(coroutines[i],0)
				if status then
					if yval then
						fullyrunning = true
						runnings[i] = true
					else
						runnings[i] = false
					end
				else
					Peachpies:Print(status,yval)
				end
			end
			if fullyrunning then
				Peachpies:RegisterEvent("ACTIONBAR_UPDATE_STATE",resume,2)
				Peachpies:RegisterEvent("ACTIONBAR_UPDATE_USABLE",resume,2)
				Peachpies:RegisterEvent("SPELL_UPDATE_CHARGES",resume,2)
				Peachpies:RegisterEvent("PLAYER_TARGET_CHANGED",resume,2)
				Peachpies:RegisterEvent("UNIT_SPELLCAST_SENT",functionresume,3)
				Peachpies:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED",functionresume,3)
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
				if ticker then
					ticker:Cancel()
					ticker = nil
				end
			end
		end
		for i=1,#coroutines do
			if runnings[i] then
				coresume(coroutines[i],2)
			end
		end
		yd = coyield()
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

function Peachpies.unit_range(uId)
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
