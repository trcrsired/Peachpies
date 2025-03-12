local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies",true)
if not Peachpies then return end
Peachpies.grids = {}
local LSM = LibStub("LibSharedMedia-3.0")

local default =
{
	Lock = false,
	Enable = true,
	x = 0,
	y = -400,
	Size = 30,
	CenterTextFont = LSM:GetDefault("font"),
	CenterTextSize = 30,
	BottomTextFont = LSM:GetDefault("font"),
	BottomTextSize = 12,

	LowColorR = 1,
	LowColorG = 1,
	LowColorB = 1,
	LowColorA = 1,

	MidColorR = 0,
	MidColorG = 0,
	MidColorB = 1,
	MidColorA = 1,

	HighColorR = 1,
	HighColorG = 0,
	HighColorB = 0,
	HighColorA = 1,

	BottomTextColorR = 1,
	BottomTextColorG = 1,
	BottomTextColorB = 1,
	BottomTextColorA = 1,
}
default.__index = default

Peachpies.modulesdefaultmetatable.grids = default

function Peachpies.CreateGrids(nameinfo,singleregions,aoeregions,buffregions)
-- data driven design
	local grids_meta = {}
	grids_meta.singleregions = singleregions
	grids_meta.aoeregions = aoeregions
	grids_meta.buffregions = buffregions
	Peachpies.AddComponentNameinfo("grids",grids_meta,nameinfo)
	local globalframe = CreateFrame("Frame",nil,UIParent)
	globalframe:Hide()
--	globalframe:SetFrameStrata("MEDIUM")
--	globalframe:SetClampedToScreen(true)

	grids_meta.globalframe = globalframe
	local frame_tbls = {}
	grids_meta.frames = frame_tbls
	local background_tbls = {}
	grids_meta.backgrounds = background_tbls
	local center_text_tbls = {}
	grids_meta.center_texts = center_text_tbls
	local bottom_text_tbls = {}
	grids_meta.bottom_texts = bottom_text_tbls
	local cd_tbls = {}
	grids_meta.cooldowns = cd_tbls
	local n = 0
	local m
	local p
	if singleregions == 0 then
		singleregions = nil
	end
	if singleregions then
		n = n + singleregions
	end
	if aoeregions == 0 then
		aoeregions = nil
	end
	if aoeregions then
		p = n + 1
		n = n + aoeregions
	end
	if buffregions == 0 then
		buffregions = nil
	end
	if buffregions then
		m = n + 1
		n = n + buffregions
	end
	grids_meta.singleregions = singleregions
	grids_meta.aoeregions = aoeregions
	grids_meta.buffregions = buffregions
	grids_meta.n = n
	for i=1,n do
		local frme = CreateFrame("Frame",nil,globalframe)
		local point, relativeFrame, relativePoint, ofsx, ofsy
		if i == 1 then
			point = "BOTTOMLEFT"
			relativeFrame = globalframe
			relativePoint = point
		elseif i == p then
			point = "BOTTOMLEFT"
			relativeFrame = frame_tbls[i-1]
			relativePoint = "BOTTOMRIGHT"
		elseif i == m then
			point = "BOTTOMLEFT"
			relativeFrame = frame_tbls[1]
			relativePoint = "TOPLEFT"
		else
			point = "BOTTOMLEFT"
			relativeFrame = frame_tbls[i-1]
			relativePoint = "BOTTOMRIGHT"
			if p and i == p - 1 then
				ofsx = 5
				ofsy = 0
			end
		end
		frme:SetPoint(point,relativeFrame,relativePoint,ofsx, ofsy)
		frame_tbls[i] = frme
		local b =  frme : CreateTexture(nil, "BACKGROUND")
		b:SetAllPoints(frme)
		b:SetTexCoord(0.1,0.9,0.1,0.9)
		background_tbls[i] = b
		local ct = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		ct:SetPoint("CENTER", frme, "CENTER",0, 0)
		center_text_tbls[i] = ct
		local btmt = frme:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		btmt:SetPoint("BOTTOM", frme, "BOTTOM",0, 0)
		bottom_text_tbls[i] = btmt
		local cd = CreateFrame("Cooldown", nil, frme, "CooldownFrameTemplate")
		cd:SetHideCountdownNumbers(true)
		cd_tbls[i] = cd
	end
	return grids_meta
end

function Peachpies.GridsConfig(db,grids_meta)
	local tb = db.grids
	if tb == nil then
		tb = {}
		db.grids = tb
	end
	setmetatable(tb,default)
	local globalframe = grids_meta.globalframe
	local enable = tb.Enable
	if enable then
		local size = tb.Size
		local frame_tbls = grids_meta.frames
		local center_text_tbls = grids_meta.center_texts
		local bottom_text_tbls = grids_meta.bottom_texts
		local singleregions = grids_meta.singleregions
		local aoeregions = grids_meta.aoeregions
		local buffregions = grids_meta.buffregions
		local n = 0
		local m
		local p
		if singleregions then
			n = n + singleregions
		end
		if aoeregions then
			p = n + 1
			n = n + aoeregions
		else
			p = -1
		end
		m = n + 1
		if buffregions then
			n = n + buffregions
		end
		for i=1,n do
			local frame = frame_tbls[i]
			local center_text = center_text_tbls[i]
			local bottom_text = bottom_text_tbls[i]
			local sz = size
			if i == 1 or i == p-1 or i >= m then
				sz = sz*2
			end
			frame:SetSize(sz,sz)
			center_text:SetFont(LSM:HashTable("font")[tb.CenterTextFont], tb.CenterTextSize, "OUTLINE")
			bottom_text:SetFont(LSM:HashTable("font")[tb.BottomTextFont], tb.BottomTextSize, "OUTLINE")
		end
		globalframe:SetSize(size*(n+1+n-m),size*2)
		globalframe:SetPoint("CENTER",UIParent,"CENTER",tb.x,tb.y)
		globalframe:Show()
	else
		globalframe:Hide()
	end
	return tb
end

function Peachpies.GridCenter(tb,count,L,M,center_text,format)
	if count == nil then
		center_text:Hide()
		return
	end
	if count < L then
		center_text:SetTextColor(tb.HighColorR,tb.HighColorG,tb.HighColorB,tb.HighColorA)
	elseif count < M then
		center_text:SetTextColor(tb.MidColorR,tb.MidColorG,tb.MidColorB,tb.MidColorA)
	else
		center_text:SetTextColor(tb.LowColorR,tb.LowColorG,tb.LowColorB,tb.LowColorA)
	end
	if format then
		center_text:SetFormattedText(format,count)
	else
		center_text:SetText(count)
	end
	center_text:Show()
end

local is_spell_known = Peachpies.is_spell_known


local GetSpellTexture = Peachpies.GetSpellTexture
local GetSpellCooldown = Peachpies.GetSpellCooldown
local GetTime = GetTime

function Peachpies.GridSpellMinitoring(tb,spellid,background,center_text,bottom_text,cooldown)
	if is_spell_known(spellid) then
		background:SetTexture(GetSpellTexture(spellid))
		local ap_start, ap_duration, ap_enabled, ap_modRate  = GetSpellCooldown(spellid)
		local gcd_start, gcd_duration, gcd_enabled, gcd_modRate = GetSpellCooldown(61304)
		cooldown:SetCooldown(ap_start, ap_duration, ap_modRate)
		if ap_duration ~= 0 or (gcd_duration ~=0 and ap_duration ~= gcd_duration) then
			local remain_time = ap_start+ap_duration-GetTime()
			local s = "%.0f"
			if remain_time < 5 then
				s = "%.1f"
			end
			if remain_time >= 0 and gcd_duration ~= ap_duration then
				Peachpies.GridCenter(tb,remain_time,5,10,center_text,s)
				center_text:Show()
			else
				center_text:Hide()
			end
		else
			center_text:Hide()
		end
		return true
	end
end

function Peachpies.GridsSpellMonitoring(grid_profile,grids_meta,monitoredspells)
	local buffregions = grids_meta.buffregions
	if buffregions == nil then
		return
	end
	if monitoredspells == nil then
		return
	end
	local framestbl = grids_meta.frames
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local spellmon = Peachpies.GridSpellMinitoring
	local n = grids_meta.n
	local diff = n - buffregions
	local monitoredspellsn = #monitoredspells
	for j = 1,buffregions do
		local jmm1 = j+diff
		local framejmm1 = framestbl[jmm1]
		if j > monitoredspellsn then
			framejmm1:Hide()
		else
			if spellmon(grid_profile,monitoredspells[j],backgrounds[jmm1],
			center_texts[jmm1],bottom_texts[jmm1],cooldowns[jmm1]) then
				framejmm1:Show()
			else
				framejmm1:Hide()
			end
		end

	end
end

function Peachpies.GridsQueueSpells(castingspellid,castendTimeMS,castingqueue,backgrounds,cooldowns,bgi,edi)
	local castingqueue1 = castingqueue[1]
	local starti = 1
	if castingqueue1 == castingspellid then
		local gtmms = GetTime()*1000
		if castendTimeMS < gtmms + 800 then
			starti = 2
		end
	end
	for i=bgi,edi do
		local spellid = castingqueue[starti]
		backgrounds[i]:SetTexture(GetSpellTexture(spellid))
		local cd_start, cd_duration, cd_enabled, cd_modRate = GetSpellCooldown(spellid)
		cooldowns[i]:SetCooldown(cd_start, cd_duration, cd_modRate)
		starti = starti + 1
	end
end
