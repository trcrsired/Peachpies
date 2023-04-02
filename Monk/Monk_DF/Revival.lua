local Myta = LibStub("AceAddon-3.0"):GetAddon("Myta")

local function cofunc(yd)
	local spellid = 115310
	local revival_name,_,revival_texture = GetSpellInfo(spellid)
	local bframe,bbackground,statusbar,percentage,amount = Myta.CreateBar(spellid,coroutine.running())
	local gframe,gbackground,center_text,bottom_text,cd,secure_frame,actionbutton,hider = Myta.CreateGrid(spellid,coroutine.running(),revival_name)
	gbackground:SetTexture(revival_texture)
	local bar_profile,grid_profile
	while true do
		repeat
		if 0 < yd then
			local start,duration,enabled,modrate= GetSpellCooldown(spellid)
			if GetTime() + 8 < start + duration then
				hider:Show()
				bframe:Hide()
				gframe:Hide()
				break
			end
			cd:SetCooldown(start,duration,enabled,modrate)
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
			local UnitIsDeadOrGhost = UnitIsDeadOrGhost
			local UnitIsVisible = UnitIsVisible
			local UnitInRange = UnitInRange
			local UnitHealth = UnitHealth
			local UnitHealthMax = UnitHealthMax
			local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
			local spell_healing_base = GetSpellBonusHealing() * 2.83
			local counts,vcounts = 0, 0
			local health_deficits = 0
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
			for i = 1,members do
				local u
				if i == members then
					if fmt == "raid" then
						u = fmt..i
					else
						u = "player"
					end
				else
					u = fmt..i
				end
				if not UnitIsDeadOrGhost(u) then
					if UnitIsVisible(u) then
						vcounts = vcounts + 1
					end
					if u == "player" or UnitInRange(u) then
						counts = counts + 1
						local h,m = UnitHealth(u),(UnitHealthMax(u)+UnitGetTotalHealAbsorbs(u))
						if h < m then
							local ele = m-h
							if ele < spell_healing_base then
								health_deficits = health_deficits + ele
							elseif ele < full_point then
								health_deficits = health_deficits + spell_healing_base * (1-crit) + crit * ele
							else
								health_deficits = health_deficits + full_effect
							end
						end
					end
				end
			end
			if vcounts == 0 then
				gframe:Hide()
				bframe:Hide()
				hider:Show()
				break
			end
			Myta.GridCenter(grid_profile,counts,vcounts*0.8,vcounts,center_text)
			if Myta.BarSet(bar_profile,health_deficits, full_effect * vcounts,statusbar,percentage,amount) then
				hider:Hide()
			else
				hider:Show()
			end
			bframe:Show()
			gframe:Show()
		elseif yd == 0 then
			local p = Myta.GetProfile(spellid)
			bar_profile = Myta.BarConfig(p,bframe,bbackground,statusbar,percentage,amount)
			grid_profile = Myta.GridConfig(p,gframe,gbackground,center_text,bottom_text,cd,secure_frame,actionbutton)
		elseif yd == -1 then
			bframe:Hide()
			gframe:Hide()
		end
		until true
		yd = coroutine.yield()
	end
end

Myta.AddCoroutine(coroutine.create(cofunc))
