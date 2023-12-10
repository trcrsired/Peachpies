local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies",true)
if not Peachpies then return end

local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers
local GetSpellTexture = GetSpellTexture
local GetSpellCooldown = GetSpellCooldown
local GetSpellBonusHealing = GetSpellBonusHealing
local GetCritChance = GetCritChance
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local player_in_pvp = Peachpies.player_in_pvp
local UnitIsVisible = UnitIsVisible
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local Peachpies_GridCenter = Peachpies.GridCenter
local Peachpies_Barset = Peachpies.BarSet
local is_spell_known = Peachpies.is_spell_known
local coyield = coroutine.yield
local GetSpecialization = GetSpecialization
local InCombatLockdown = InCombatLockdown
local GetTime = GetTime
local wipe = wipe
local UnitIsFriend = UnitIsFriend
local UnitAura = UnitAura
local UnitExists = UnitExists
local UnitInRaid = UnitInRaid
local UnitIsUnit = UnitIsUnit
local UnitInParty = UnitInParty
local GetHaste = GetHaste
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates
local math_huge = math.huge
local UnitGUID = UnitGUID

local temp_tb = {}

local function find_known_spell(spells)
	if type(spells) == "table" then
		for i=1,#spells do
			local spellsi = spells[i]
			if is_spell_known(spellsi) then
				return spellsi
			end
		end
	elseif spells then
		if is_spell_known(spells) then
			return spells
		end
	end
end

function Peachpies.handle_range_healing_spell(spells, grid_meta,grid_profile,
	bar_meta,bar_profile,metadata, temporary_data, yd, arg0, arg1, arg2, arg3, arg4)
	local with_buff = metadata.with_buff
--[[
	local temporary_data1 = temporary_data[1]
	if arg0 == "UNIT_AURA" then
		if arg2 then
			if arg2.isFullUpdate then
				return
			end
			for i=1,#arg2 do
			if arg2.spellId == with_buff then
				local sourceunit = arg2.sourceunit
				if sourceunit and UnitIsUnit(sourceunit,"player") then
					temporary_data1[arg1] = arg2
					quit_func = false
				end
			end
			end
		end
	end
]]
	local grid_background = grid_meta.background
	local grid_cooldown = grid_meta.cooldown
	local bar_frame
	if bar_meta then
		bar_frame = bar_meta.frame
	end
	local grid_frame = grid_meta.frame
	local grid_hider = grid_meta.actionbutton_hider

	local spellid = find_known_spell(spells)
	if spellid and not is_spell_known(spellid) then
		grid_frame:Hide()
		bar_frame:Hide()
		if grid_hider then
			grid_hider:Show()
		end
		return
	end
	grid_background:SetTexture(GetSpellTexture(spellid))

	local timestamp = GetTime()
	do
		local start,duration,enabled,modrate = GetSpellCooldown(spellid)
		grid_cooldown:SetCooldown(start,duration,enabled,modrate)

		local hide_on_cooldown = metadata.hide_on_cooldown
		if hide_on_cooldown then
			if timestamp + hide_on_cooldown < start + duration then
				bar_frame:Hide()
				grid_frame:Hide()
				if grid_hider then
					grid_hider:Show()
				end
				return
			end
		end

	end
	local inraid = IsInRaid()

	local fmt
	local members
	if inraid then
		fmt = "raid"
		members = GetNumGroupMembers()
	elseif IsInGroup() then
		fmt = "party"
		members = GetNumGroupMembers()
	else
		members = 1
	end


	local pbuff = with_buff and metadata.pbuff

	local range_function = metadata.unit_in_range
	local visible_counts = 0
	local applying_counts = 0

--	local eventfeedback = metadata.eventfeedback

	local first_disappear = math_huge
	local first_disappear_expiration = 0
	local maximum_expiration = 0
--	local effective_duration = metadata.effective_duration


--	local first_disappear = math.huge
--	local first_disappear_expiration = 0

	wipe(temp_tb)


	local i = 1
--[[
	local nameplates
	if metadata.nameplates then
		nameplates = C_NamePlate_GetNamePlates()
	end
]]
	while true do
		local u
		if i <= members then
			if i == members then
				if fmt == "raid" then
					u = fmt..i
				else
					u = "player"
				end
			else
				u = fmt..i
			end
		elseif nameplates then
			local position = i-members
			if #nameplates < position then
				break
			end
			local ni = nameplates[position]
			if ni then
				u = ni.namePlateUnitToken
				if u then
					if UnitInParty(u) or UnitInRaid(u) or UnitIsUnit(u,"player") then
						u = nil
					end
				end
			end
		else
			break
		end
		i = i + 1
		if u and not UnitIsDeadOrGhost(u) and (UnitIsFriend(u,"player")) then
			local this_has_buff = true
			if with_buff then
				this_has_buff = false
				for buffi=1,40 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura(u,buffi,"PLAYER|HELPFUL")
					if name == nil then
						break
					end
					if spellId == with_buff then
						if pbuff then
							if duration == 0 then
								this_has_buff = true
							end
						else
							local start_timestamp = expirationTime - duration
							if timestamp < expirationTime and start_timestamp <= timestamp then
								this_has_buff = true
								if expirationTime < first_disappear then
									first_disappear = expirationTime
									first_disappear_expiration = expirationTime
								end
								if maximum_expiration < start_timestamp then
									maximum_expiration = start_timestamp
									--effective_duration = duration
								end
							end
						end
						break
					end
				end
			end
			local is_visible,is_applying
			if u == "player" then
				is_visible = true
				is_applying = true
			else
				if range_function then
					is_applying,is_visible = range_function(u)
					if is_applying then
						is_visible = true
					end
				else
					is_visible = UnitIsVisible(u)
					is_applying = is_visible
				end
			end
			if this_has_buff then
				if is_visible then
					visible_counts = visible_counts + 1
				end
				if is_applying then
					applying_counts = applying_counts + 1
					local h = UnitHealth(u)
					local m = UnitHealthMax(u)
					if UnitGetTotalHealAbsorbs then
						m = m + UnitGetTotalHealAbsorbs(u)
					end
					if h < m then
						temp_tb[#temp_tb+1] = m-h
					end
				end
			end
		end
	end

	if visible_counts == 0 then
		if bar_frame then
			bar_frame:Hide()
		end
		grid_frame:Hide()
		if grid_hider then
			grid_hider:Show()
		end
		return
	end
	local effective_green_number = metadata.effective_green_number
	local effective_blue_number = metadata.effective_blue_number
	if effective_green_number == nil then
		effective_green_number = visible_counts * 0.8
		effective_blue_number = visible_counts
	else
		local effective_callback = metadata.effective_callback
		if effective_callback then
			effective_green_number,effective_blue_number =
			effective_callback(temp_tb,applying_counts,visible_counts,members)
		end
	end

	if bar_frame == nil then
		Peachpies_GridCenter(grid_profile,applying_counts,effective_green_number,effective_blue_number,grid_meta.center_text)
		if with_buff and not pbuff then
			local gcd = 1.5/(1+GetHaste()/100)
			Peachpies_GridCenter(grid_profile,first_disappear_expiration-timestamp,gcd,gcd*3,grid_meta.bottom_text,"%.1f")
		end

		if grid_hider then
			grid_hider:Show()
		end
		grid_frame:Show()
		return
	end
	local crit = GetCritChance() / 100
	local spell_healing_base = GetSpellBonusHealing() * metadata.constant

	if not inraid and metadata.raidcooldown2x then
		spell_healing_base = spell_healing_base * 2
	end

	local applytype = metadata.applytype
--[[
0: no apply
1: instant (like vivify) -- this is the default one
2: hot
]]
	if applytype == nil then
		applytype = 1
	end
	local health_deficits = 0

	local inpvp = player_in_pvp()

	local full_point = spell_healing_base

	local scaled_shb = spell_healing_base

	local caps = metadata.caps

	if caps and 0 < caps and caps < #temp_tb then
		local factor = caps / #temp_tb
		scaled_shb = scaled_shb * factor
		full_point = full_point * factor
	end

	local pvp_coeff = (1+crit * 0.5)
	local total_healing = spell_healing_base * pvp_coeff
	local full_effect = total_healing
	if inpvp then
		full_point = full_point * 1.5
		pvp_coeff = 1 + 0.5 * crit
	else
		full_point = full_point * 2
		pvp_coeff = 1 + crit
	end
	if applytype == 1 then
		local crtht = scaled_shb * (1-crit)
		for i=1,#temp_tb do
			local ele = temp_tb[i]
			if ele < scaled_shb then
				health_deficits = health_deficits + ele
			elseif ele < full_point then
				health_deficits = health_deficits + crtht + crit * ele
			else
				health_deficits = health_deficits + full_effect
			end
		end
	elseif applytype == 2 then
		for i=1,#temp_tb do
			local ele = temp_tb[i]
			if ele < full_point then
				health_deficits = health_deficits + ele
			else
				health_deficits = health_deficits + full_effect
			end
		end
	end


	Peachpies_GridCenter(grid_profile,applying_counts,effective_green_number,effective_blue_number,grid_meta.center_text)

	if with_buff and not pbuff then
		local gcd = 1.5/(1+GetHaste()/100)
		Peachpies_GridCenter(grid_profile,first_disappear_expiration-timestamp,gcd,gcd*3,grid_meta.bottom_text,"%.1f")
	end

	if caps then
		total_healing = total_healing * caps
		if health_deficits > total_healing then
			health_deficits = total_healing
		end
	else
		total_healing = total_healing * visible_counts
	end
	local manacost = metadata.manacost
	if manacost then
		health_deficits = health_deficits/manacost
		total_healing = total_healing/manacost
	end
	local bret = Peachpies_Barset(bar_profile,health_deficits,total_healing,bar_meta)
	if grid_hider then
		if bret then
			grid_hider:Hide()
		else
			grid_hider:Show()
		end
	end
	bar_frame:Show()
	grid_frame:Show()
end

local function find_known_spell(spells)
	if type(spells) == "table" then
		for i=1,#spells do
			local spellsi = spells[i]
			if is_spell_known(spellsi) then
				return spellsi
			end
		end
	elseif spells then
		if is_spell_known(spells) then
			return spells
		end
	end
end

local handle_range_healing_spell = Peachpies.handle_range_healing_spell

function Peachpies.create_range_healing_spell_coroutine(metadata)
	return function(ydinit)
		local nameinfo = metadata.nameinfo
		local grid_meta = Peachpies.CreateGrid(nameinfo,metadata.secure)
		local nameinfobar = metadata.nameinfobar
		if nameinfobar == nil then
			nameinfobar = nameinfo
		end
		local bar_meta
		if not metadata.auraonly then
			bar_meta = Peachpies.CreateBar(nameinfobar)
		end
		local grid_frame = grid_meta.frame
		local grid_secureframe = grid_meta.globalframe
		local grid_hider = grid_meta.actionbutton_hider
		local grid_profile
		local bar_frame
		if bar_frame then
			bar_frame = bar_meta.frame
		end
		local bar_profile
		local spells = metadata.spells
		local specialization = metadata.specialization
		local current_spell
		local yd, arg0, arg1, arg2, arg3, arg4 = ydinit, nil, nil, nil, nil, nil
		local temporary_data = {{},{}}
		while true do
			repeat
			if yd == 0 then
				current_spell = find_known_spell(spells)
				if ( specialization == nil or GetSpecialization() == specialization ) and current_spell then
					local profile = Peachpies.GetProfile(nameinfo.key)
					grid_profile = Peachpies.GridConfig(profile,grid_meta)
					if bar_meta ~= nil and not bar_profile then
						bar_profile = Peachpies.BarConfig(profile,bar_meta)
					end
					if (grid_profile and grid_profile.Enable) or (bar_profile and bar_profile.Enable) then
						if grid_profile and grid_profile.Enable then
							if grid_hider then
								if not InCombatLockdown() and not grid_secureframe:IsForbidden() then
									grid_secureframe:Show()
								end
							end
						end
						yd=coyield(5)
						break
					end
				end
				grid_frame:Hide()
				if bar_frame then
					bar_frame:Hide()
				end
				if grid_hider then
					grid_hider:Show()
					if not InCombatLockdown() and not grid_secureframe:IsForbidden() then
						grid_secureframe:Hide()
					end
				end
				yd, arg0, arg1, arg2, arg3, arg4=coyield()
				break
			else
				handle_range_healing_spell(spells,
				grid_meta,grid_profile,
				bar_meta,bar_profile, metadata, temporary_data, yd, arg0, arg1, arg2, arg3, arg4)
			end
			yd, arg0, arg1, arg2, arg3, arg4 = coyield()
			until true
		end
	end
end
