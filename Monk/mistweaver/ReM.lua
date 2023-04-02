local Myta = LibStub("AceAddon-3.0"):GetAddon("Myta")

local function cofunc(yd)
	local rem_spellid = 115151
	local vivify_spellid = 116670
	local _,_,rem_texture = GetSpellInfo(rem_spellid)
	local bframe,bbackground,statusbar,percentage,amount = Myta.CreateBar(vivify_spellid,coroutine.running())
	local gframe,gbackground,center_text,bottom_text,cd,secure_frame = Myta.CreateGrid(rem_spellid,coroutine.running())
	gbackground:SetTexture(rem_texture)
	local bar_profile,grid_profile
	local tb = {}
	local rising_mist
	while true do
		repeat
		if yd == 1 or yd == 3 then
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
			local UnitIsDeadOrGhost = UnitIsDeadOrGhost
			local UnitHealth = UnitHealth
			local UnitHealthMax = UnitHealthMax
			local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
			local UnitIsFriend = UnitIsFriend
			local UnitInParty = UnitInParty
			local UnitInRaid = UnitInRaid
			local UnitIsUnit = UnitIsUnit
			local UnitExists = UnitExists
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
				gframe:Hide()
				bframe:Hide()
				yd = coroutine.yield()
				break
			end
			cd:SetCooldown(maximum_expiration,effective_duration)
			local injured_counts = #tb
			local health_deficits = 0
-- 1.41
			local spell_healing_base = GetSpellBonusHealing() * 1.04
--			local maximum_effect_base = spell_healing_base * (6 < injured_counts and 6 or counts)
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
			if UnitIsPVP("player") then
				full_point = full_point * 1.5
				pvp_coeff = 1 + 0.5 * crit
			else
				full_point = full_point * 2
				pvp_coeff = 1 + crit
			end
			local full_effect = spell_healing_base * pvp_coeff
			full_potential = full_potential * pvp_coeff
			for i = 1,injured_counts do
				local ele = tb[i]
				if ele < spell_healing_base then
					health_deficits = health_deficits + ele
				elseif ele < full_point then
					health_deficits = health_deficits + spell_healing_base * (1-crit) + crit * ele
				else
					health_deficits = health_deficits + full_effect
				end
			end
			local effective_green_number = 2
			local effective_blue_number = 3
			if rising_mist then
				effective_green_number = members * 0.6
				if effective_green_number < 2 then
					effective_green_number = 2
				end
				effective_blue_number = members * 0.8
				if effective_blue_number < 3 then
					effective_blue_number = 3
				end
			end
			Myta.GridCenter(grid_profile,counts,effective_green_number,effective_blue_number,center_text)
			local gcd = 1.5/(1+GetHaste()/100)
			Myta.GridCenter(grid_profile,first_disappear_expiration-timestamp,gcd,gcd*3,bottom_text,"%.1f")
			health_deficits = health_deficits/4.1
			full_potential = full_potential/4.1
			Myta.BarSet(bar_profile,health_deficits,full_potential,statusbar,percentage,amount)
			bframe:Show()
			gframe:Show()
			yd = coroutine.yield(health_deficits,full_potential,rem_texture,counts,effective_green_number,effective_blue_number)
			break
		elseif yd == 0 then
			rising_mist = select(5,GetTalentInfo(7,3,1))
			bar_profile = Myta.BarConfig(Myta.GetProfile(vivify_spellid),bframe,bbackground,statusbar,percentage,amount)
			grid_profile = Myta.GridConfig(Myta.GetProfile(rem_spellid),gframe,gbackground,center_text,bottom_text,cd,secure_frame)
		elseif yd == -1 then
			bframe:Hide()
			gframe:Hide()
		end
		yd = coroutine.yield()
		until true
	end
end

Myta.AddCoroutine(coroutine.create(cofunc))
