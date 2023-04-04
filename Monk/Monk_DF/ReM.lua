local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitIsFriend = UnitIsFriend
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local is_spell_known = Peachpies.is_spell_known
local UnitAura = UnitAura
local wipe = wipe
local GetTime = GetTime
local GetNumGroupMembers = GetNumGroupMembers
local coyield = coroutine.yield
local GetCritChance = GetCritChance
local GetHaste = GetHaste
local GetSpellBonusHealing = GetSpellBonusHealing
local player_in_pvp = Peachpies.player_in_pvp
local Peachpies_GridCenter = Peachpies.GridCenter
local Peachpies_Barset = Peachpies.BarSet
local GetSpellTexture = GetSpellTexture

local function cofunc(yd)
	local grid_meta = Peachpies.CreateGrid({key="monk_mw_rem",spellid=115151})
	local bar_meta = Peachpies.CreateBar({key="monk_mw_rem",spellid=116670})
	local grid_frame = grid_meta.frame
	local grid_cooldown = grid_meta.cooldown
	local grid_center_text = grid_meta.center_text
	local grid_bottom_text = grid_meta.bottom_text
	local grid_background = grid_meta.background
	local grid_profile
	local bar_frame = bar_meta.frame
	local bar_profile
	local tb = {}
	while true do
		repeat
		if yd == 0 then
			if GetSpecialization() == 2 then
				local profile = Peachpies.GetProfile("monk_mw_rem")
				grid_profile = Peachpies.GridConfig(profile,grid_meta)
				bar_profile = Peachpies.BarConfig(profile,bar_meta)
				if grid_profile.Enable or bar_profile.Enable then
					yd=coyield(5)
					break
				end
			end
			grid_frame:Hide()
			bar_frame:Hide()
			yd=coyield()
			break
		else
			grid_frame:Show()
			grid_background:SetTexture(GetSpellTexture(115151))
			local fmt
			local members
			if UnitInRaid("player") then
				fmt = "raid"
				members = GetNumGroupMembers()
			elseif UnitInParty("player") then
				fmt = "party"
				members = GetNumGroupMembers()
			else
				members = 1
			end
			local counts = 0
			wipe(tb)
			local timestamp = GetTime()
			local first_disappear = math.huge
			local first_disappear_expiration = 0
			local maximum_expiration = 0
			local effective_duration = 20
			local i = 1
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
				else
					u = "nameplate"..(i-members)
					if not UnitExists(u) then
						break
					end
					if UnitInParty(u) or UnitInRaid(u) or UnitIsUnit(u,"player") then
						u = nil
					end
				end
				if u and not UnitIsDeadOrGhost(u) and UnitIsFriend(u,"player") then
					for i=1,40 do
						local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
						nameplateShowPersonal, spellId = UnitAura(u,i,"PLAYER|HELPFUL")
						if name == nil then
							break
						end
						if spellId == 119611 then
							local start_timestamp = expirationTime - duration 
							if timestamp < expirationTime and start_timestamp <= timestamp then
								if expirationTime < first_disappear then
									first_disappear = expirationTime
									first_disappear_expiration = expirationTime
								end
								if maximum_expiration < start_timestamp then
									maximum_expiration = start_timestamp
									effective_duration = duration
								end
								counts = counts + 1
								local h,m = UnitHealth(u),(UnitHealthMax(u)+UnitGetTotalHealAbsorbs(u))
								if h < m then
									tb[#tb+1] = m-h
								end
							end
							break
						end
					end
				end
				i = i + 1
			end
			if counts == 0 then
				grid_frame:Hide()
				bar_frame:Hide()
				yd = coyield()
				break
			end
			grid_cooldown:SetCooldown(maximum_expiration,effective_duration)
			local injured_counts = #tb
			local health_deficits = 0

			local spell_healing_base = GetSpellBonusHealing() * 1.04
			local full_potential = 0
			if 6 < injured_counts then
				full_potential = spell_healing_base * 6
				spell_healing_base = spell_healing_base * 6 / injured_counts
			else
				if counts < 3 then
					full_potential = spell_healing_base * 3
				elseif counts < 6 then
					full_potential = spell_healing_base * counts
				else
					full_potential = spell_healing_base * 6
				end
			end
			local crit = GetCritChance() / 100
			local full_point = spell_healing_base
			local pvp_coeff = (1+crit * 0.5)
			if player_in_pvp() then
				full_point = full_point * 1.5
				pvp_coeff = 1 + 0.5 * crit
			else
				full_point = full_point * 2
				pvp_coeff = 1 + crit
			end
			local full_effect = spell_healing_base * pvp_coeff
			full_potential = full_potential * pvp_coeff
			for i= 1,injured_counts do
				local ele = tb[i]
				if ele < spell_healing_base then
					health_deficits = health_deficits + ele
				elseif ele < full_point then
					health_deficits = health_deficits + spell_healing_base * (1-crit) + crit * ele
				else
					health_deficits = health_deficits + full_effect
				end
			end
			local effective_green_number = 12
			local effective_blue_number = 15
			Peachpies_GridCenter(grid_profile,counts,effective_green_number,effective_blue_number,grid_center_text)
			local gcd = 1.5/(1+GetHaste()/100)
			Peachpies_GridCenter(grid_profile,first_disappear_expiration-timestamp,gcd,gcd*3,grid_bottom_text,"%.1f")
			health_deficits = health_deficits/4.1
			full_potential = full_potential/4.1
			Peachpies_Barset(bar_profile,health_deficits,full_potential,bar_meta)
			bar_frame:Show()
			grid_frame:Show()
			yd = coyield(grid_meta,bar_meta,health_deficits,full_potential,counts,effective_green_number,effective_blue_number)
			break
		end
		yd = coyield()
		until true
	end
end

Peachpies.AddCoroutine(coroutine.create(cofunc))
