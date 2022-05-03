local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridSpellMinitoring = Peachpies.GridSpellMinitoring
local coyield = coroutine.yield
local GetSpellTexture = GetSpellTexture
local IsUsableSpell = IsUsableSpell
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetTime = GetTime
local GetMasteryEffect = GetMasteryEffect
local GetHaste = GetHaste
local C_PvP_IsPVPMap = C_PvP.IsPVPMap
local UnitCastingInfo = UnitCastingInfo
local Peachpies_GridCenter = Peachpies.GridCenter
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsVisible = UnitIsVisible
local UnitIsEnemy = UnitIsEnemy

local function cofunc(yd)
	local m = 5
	--Arcane Power, Touch of the Magi,Radiant Spark , Rune of Power, Mirror, Timewrap in reverse order
	local monitor_spells = {116011,307443,321507,12042,55342}
	local n = #monitor_spells + m

	local specid,specname = GetSpecializationInfoByID(62)

	local grids_meta = Peachpies.CreateGrids(specname,n,m)
	local globalframe = grids_meta.globalframe
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local grid_profile
	local center_text1 = center_texts[1]
	local bottom_text1 = bottom_texts[1]
	while true do
		repeat
		if yd ==1 or yd == 2 then
			local player_self = UnitIsUnit("player","target")
			if UnitAffectingCombat("player") or (not player_self and UnitIsVisible("target")) then
				local gcd_start, gcd_duration, gcd_enabled, gcd_modRate = GetSpellCooldown(61304)
				local charges = UnitPower("player", 16)
				local max_charges = UnitPowerMax("player", 16)

				local mana = UnitPower("player", 0)
				local max_mana = UnitPowerMax("player", 0)
				local val = GetMasteryEffect()/100 + 1
				local mana_no_master = max_mana/val
				local percentage = mana / mana_no_master
				local chargemana =  max_charges * (max_charges + 1) * 0.01375
				local starttime = GetTime()
				local current_time = starttime
				local haste_effect = 1 + GetHaste()/100
				local real_gcd_val = 1.5 / haste_effect
				local arcane_harmony_stacks = 0
				local max_arcane_harmony_stacks = 18
				if C_PvP_IsPVPMap() then
					max_arcane_harmony_stacks = 10
				end
				local has_clearcasting = false
				local has_rune_of_power = false
				local has_rune_of_power_or_arcane_power = false
				for i=1,40 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("PLAYER",i,"PLAYER|HELPFUL")
					if name == nil then
						break
					end
					if spellId == 332777 then	--arcane harmony
						arcane_harmony_stacks = count
					end
					if spellId == 263725 then
						has_clearcasting = true
					end
					if spellId == 116014 then
						has_rune_of_power = true
						has_rune_of_power_or_arcane_power = true
					end
					if spellId == 12042 then
						has_rune_of_power_or_arcane_power = true
					end
				end
				if arcane_harmony_stacks == 0 then
					bottom_text1:Hide()
				else
					Peachpies_GridCenter(grid_profile,arcane_harmony_stacks,12,18,bottom_text1)
					bottom_text1:Show()
				end
				local has_radiant_spark
				local radiant_spark_vulnerability_counts = 0
				for i=1,40 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("TARGET",i,"PLAYER")
					if name == nil then
						break
					end
					if spellId == 307454 then
						radiant_spark_vulnerability_counts = count
					end
					if spellId == 307443 then	-- Radiant Spark
						has_radiant_spark = true
					end
				end
				local arcane_orb_casted = false
				local casting_first_spell = true
				local totm_casted = false
				local i = 1
				local burst_phase = has_radiant_spark or has_rune_of_power_or_arcane_power
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				if castspellId == 116011 or castspellId == 307443 or castspellId == 321507 or castspellId == 12042 then
					burst_phase = true
				end
				local burst_radiant_spark,burst_totm, burst_arcane_power
				if burst_phase then
					local start, duration, enabled, modRate
					if castspellId ~= 307443 then
						start, duration, enabled, modRate = GetSpellCooldown(307443)	--radiant spark
						if duration == gcd_duration or duration == 0 then
							burst_radiant_spark = true
						end
					end
					start, duration, enabled, modRate = GetSpellCooldown(321507)	--touch of the magi
					if duration == gcd_duration or duration == 0 then
						burst_totm = true
					end
					if not has_rune_of_power and castspellId ~= 116011 then
						start, duration, enabled, modRate = GetSpellCooldown(12042)	--arcane power
						if duration == 0 then
							burst_arcane_power = true
						end
					end
				end

				--GetSpellCooldown(307443)
				while i <= 4 do
					local current_spell = 44425
					repeat
						if percentage < chargemana then
							-- Evocation
							if IsUsableSpell(12051) then
								local evocation_start,evocation_duration,evocation_enabled,evocation_modRate = GetSpellCooldown(12051)
								if gcd_duration < evocation_duration or (evocation_duration <= gcd_duration and current_time + gcd_duration >= evocation_start + evocation_duration)  then
									current_spell = 12051
									current_time = current_time + 6/haste_effect
									percentage = val
								end
								break
							end
						end
						if burst_phase then
							if burst_radiant_spark then
								current_spell = 307443
								burst_radiant_spark = false
								break
							end
							if burst_totm then
								current_spell = 321507
								burst_totm = false
								charges = max_charges
								break
							end
							if burst_arcane_power then
								current_spell = 12042
								burst_arcane_power = false
								break
							end
							if charges < max_charges then
								-- Arcane Orb
								if IsUsableSpell(153626) then
									if not arcane_orb_casted then
										local start, duration, enabled, modRate = GetSpellCooldown(153626)
										if duration <= gcd_duration then
											current_spell = 153626
											charges = charges + 1
											percentage = percentage - 0.1
											current_time = current_time + real_gcd_val
											arcane_orb_casted = true
											break
										end
									end
								end
							end
						else
							if has_clearcasting and not burst_phase then
								arcane_harmony_stacks = arcane_harmony_stacks + 8
								current_spell = 5143
								has_clearcasting = false
								break
							end
							if charges == 0 then
								-- Touch of the Magi
								if IsUsableSpell(321507) then
									if totm_casted then
										local start, duration, enabled, modRate = GetSpellCooldown(321507)
										if duration <= gcd_duration then
											current_spell = 321507
											charges = max_charges
											current_time = current_time + real_gcd_val
											totm_casted = true
											break
										end
									end
								end
								-- Arcane Orb
								if IsUsableSpell(153626) then
									if not arcane_orb_casted then
										local start, duration, enabled, modRate = GetSpellCooldown(153626)
										if duration <= gcd_duration then
											current_spell = 153626
											charges = charges + 1
											percentage = percentage - 0.1
											current_time = current_time + real_gcd_val
											arcane_orb_casted = true
											break
										end
									end
								end
							end
						end
						if charges < max_charges then
							current_spell = 30451
							charges = charges + 1
							break
						end
						if has_radiant_spark and radiant_spark_vulnerability_counts ~= 4 then
							current_spell = 30451
							radiant_spark_vulnerability_counts = radiant_spark_vulnerability_counts + 1
						elseif not has_radiant_spark and has_rune_of_power_or_arcane_power then
							current_spell = 5143
							if has_clearcasting then
								arcane_harmony_stacks = arcane_harmony_stacks + 8
								has_clearcasting = false
							else
								arcane_harmony_stacks = arcane_harmony_stacks + 5
							end
						else
							current_spell = 44425
							charges = 0
							arcane_harmony_stacks = 0
						end
					until true
					local skip_this_round = false
					if casting_first_spell then
						if castname then
							if castspellId == current_spell then
								skip_this_round = true
							end
							casting_first_spell = false
						end
					end
					if not skip_this_round then
						backgrounds[i]:SetTexture(GetSpellTexture(current_spell))
						cooldowns[i]:SetCooldown(gcd_start, gcd_duration, gcd_enabled, gcd_modRate)
						i = i + 1
					end
				end
				local t = unit_range("target")
				if t then
					Peachpies_GridCenter(grid_profile,t,10,43,center_text1,"%.0f")
				end
				for j = 1,#monitor_spells do
					local jmm1 = j+m-1
					Peachpies_GridSpellMinitoring(grid_profile,
					monitor_spells[j],backgrounds[jmm1],center_texts[jmm1],bottom_texts[jmm1],cooldowns[jmm1])
				end
				globalframe:Show()
			else
				globalframe:Hide()
			end	
		elseif yd == 0 then
			if GetSpecialization() == 1 then
				grid_profile = Peachpies.GridsConfig(Peachpies.GetProfile(specname),grids_meta)
				if grid_profile.Enable then
					yd=coyield(true)
				else
					yd=coyield(false)
				end
			else
				globalframe:Hide()
				yd=coyield(false)
			end
			break
		end
		yd=coyield()
		until true
	end
end

Peachpies.AddCoroutine(coroutine.create(cofunc))
