local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitIsVisible = UnitIsVisible
local UnitInRange = UnitInRange
local is_spell_known = Peachpies.is_spell_known
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime
local GetNumGroupMembers = GetNumGroupMembers
local coyield = coroutine.yield
local GetCritChance = GetCritChance
local GetSpellBonusHealing = GetSpellBonusHealing
local player_in_pvp = Peachpies.player_in_pvp
local Peachpies_GridCenter = Peachpies.GridCenter
local Peachpies_Barset = Peachpies.BarSet
local GetSpellTexture = GetSpellTexture

local macrotext = table.concat({
"/use [known:115310] ",
GetSpellInfo(115310),
";[known:388615] ",
GetSpellInfo(388615),nil})

local function cofunc(yd)
	local grid_meta = Peachpies.CreateGrid({key="monk_mw_revival",spellid=115310},macrotext)
	local bar_meta = Peachpies.CreateBar({key="monk_mw_revival",spellid=115310})
	local grid_frame = grid_meta.frame
	local grid_secureframe = grid_meta.globalframe
	local grid_cooldown = grid_meta.cooldown
	local grid_center_text = grid_meta.center_text
	local grid_background = grid_meta.background
	local grid_actionbutton = grid_meta.actionbutton
	local grid_hider = grid_meta.actionbutton_hider
	local grid_profile
	local bar_frame = bar_meta.frame
	local bar_profile
	while true do
		repeat
		if yd == 0 then
			if GetSpecialization() == 2 then
				local profile = Peachpies.GetProfile("monk_mw_revival")
				grid_profile = Peachpies.GridConfig(profile,grid_meta)
				bar_profile = Peachpies.BarConfig(profile,bar_meta)
				if grid_profile.Enable or bar_profile.Enable then
					if grid_profile.Enable then
						if not InCombatLockdown() and not grid_secureframe:IsForbidden() then
							grid_secureframe:Show()
						end
					end
					yd=coyield(5)
					break
				end
			end
			grid_frame:Hide()
			bar_frame:Hide()
			grid_hider:Show()
			if not InCombatLockdown() and not grid_secureframe:IsForbidden() then
				grid_secureframe:Hide()
			end
			yd=coyield()
			break
		else
			local revival_known = is_spell_known(115310)
			local restoral_known = is_spell_known(388615)
			if not revival_known and not restoral_known then
				grid_frame:Hide()
				bar_frame:Hide()
				grid_actionbutton:SetMouseClickEnabled(false)
				grid_hider:Show()
				yd = coyield()
				break
			end
			local spellid = 115310
			if restoral_known then
				spellid = 388615
			end
			grid_background:SetTexture(GetSpellTexture(spellid))


			local start,duration,enabled,modrate= GetSpellCooldown(spellid)
			if GetTime() + 8 < start + duration then
				bar_frame:Hide()
				grid_frame:Hide()
				grid_hider:Show()
				yd = coyield()
				break
			end

			grid_cooldown:SetCooldown(start,duration,enabled,modrate)
			local crit = GetCritChance() / 100
			local constant = 3.2545*1.08
			local spell_healing_base = GetSpellBonusHealing() * constant

			local playerinraid = IsInRaid()
			if not playerinraid then
				spell_healing_base = spell_healing_base * 2
			end
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


			local fmt
			local members
			if playerinraid then
				fmt = "raid"
				members = GetNumGroupMembers()
			elseif IsInGroup() then
				fmt = "party"
				members = GetNumGroupMembers()
			else
				members = 1
			end

			local counts,vcounts = 0, 0
			local health_deficits = 0
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
				bar_frame:Hide()
				grid_frame:Hide()
				grid_hider:Show()
				yd = coyield()
				break
			end
			Peachpies_GridCenter(grid_profile,counts,vcounts*0.8,vcounts,grid_center_text)

			if Peachpies_Barset(bar_profile,health_deficits,full_effect * vcounts,bar_meta) then
				grid_hider:Hide()
			else
				grid_hider:Show()
			end
			bar_frame:Show()
			grid_frame:Show()
		end
		yd = coyield()
		until true
	end
end

Peachpies.AddCoroutine(coroutine.create(cofunc))
