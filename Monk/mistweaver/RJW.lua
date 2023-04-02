local Myta = LibStub("AceAddon-3.0"):GetAddon("Myta")

local function cofunc(yd)
	local spellid = 196725
	local rjw_name,_,rjw_texture = GetSpellInfo(spellid)
	local bframe,bbackground,statusbar,percentage,amount,bsecureframe = Myta.CreateBar(spellid,coroutine.running())
	local gframe,gbackground,center_text,bottom_text,cd,secure_frame = Myta.CreateGrid(spellid,coroutine.running())
	gbackground:SetTexture(rjw_texture)
	local bar_profile,grid_profile
	local tb = {}
	local ok
	while true do
		repeat
		if yd == 1 or yd == 3 then
			if ok then
				yd = coroutine.yield()
				break
			end
			cd:SetCooldown(GetSpellCooldown(spellid))
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
			local CheckInteractDistance = CheckInteractDistance
			local UnitInRange = UnitInRange
			local UnitHealth = UnitHealth
			local UnitHealthMax = UnitHealthMax
			local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
			local UnitIsFriend = UnitIsFriend
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
				if not UnitIsDeadOrGhost(u) and CheckInteractDistance(u,3) and (u=="player" or (UnitIsFriend(u,"player") and UnitInRange(u))) then
					counts = counts + 1
					local h,m = UnitHealth(u),(UnitHealthMax(u)+UnitGetTotalHealAbsorbs(u))
					if h < m then
						tb[#tb+1] = m-h
					end
				end
			end
			if counts == 0 or members == 1 and #tb == 0 then
				gframe:Hide()
				bframe:Hide()
				yd = coroutine.yield()
				break
			end
			local injured_counts = #tb
			local spt = GetSpellBonusHealing() *
				(UnitIsPVP("player") and (1 + GetCritChance()/200) or (1 + GetCritChance()/100)) * 1.508
			local health_deficits = 0
			for i = 1,injured_counts do
				local ele = tb[i]
				if ele < spt then
					health_deficits = health_deficits + ele
				else
					health_deficits = health_deficits + spt
				end
			end
			Myta.GridCenter(grid_profile,counts,6,9,center_text)
			local tot = 6*spt
			Myta.BarSet(bar_profile,math.min(health_deficits,tot)/3.5,tot/3.5,statusbar,percentage,amount)
			bframe:Show()
			gframe:Show()
			yd = coroutine.yield(value,spt,ef_texture,counts,6,9)
			break
		elseif yd == 0 then
			if select(5,GetTalentInfo(6,2,1)) then
				local p = Myta.GetProfile(spellid)
				bar_profile = Myta.BarConfig(p,bframe,bbackground,statusbar,percentage,amount,bsecureframe)
				grid_profile = Myta.GridConfig(p,gframe,gbackground,center_text,bottom_text,cd,secure_frame)
				ok = nil
			else
				bframe:Hide()
				gframe:Hide()
				ok = true
			end
		elseif yd == -1 then
			bframe:Hide()
			gframe:Hide()
		end
		yd = coroutine.yield()
		until true
	end
end

Myta.AddCoroutine(coroutine.create(cofunc))
