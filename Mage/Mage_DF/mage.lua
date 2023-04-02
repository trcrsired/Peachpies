local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridsSpellMinitoring = Peachpies.GridsSpellMinitoring
local coyield = coroutine.yield
local GetSpellTexture = GetSpellTexture
local is_spell_known = Peachpies.is_spell_known
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetTime = GetTime
local GetMasteryEffect = GetMasteryEffect
local GetHaste = GetHaste
local player_in_pvp = Peachpies.player_in_pvp
local UnitCastingInfo = UnitCastingInfo
local Peachpies_GridCenter = Peachpies.GridCenter
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsVisible = UnitIsVisible

local arcane_power_spellid = 365350
local arcane_power_buff_id = 365362

--Arcane: Arcane Power, Touch of the Magi,Radiant Spark , Rune of Power, Mirror, Timewrap

local arcane_monitor_spells = {arcane_power_spellid,321507,376103,116011,55342,80353}

--Frost: Frozen Orb, Deathborne, icy veins, rune of power, mirror image, summon water elemental, time wrap
local ice_monitor_spells = {84714,324220,12472,116011,55342,80353}

--Fire to do
local fire_monitor_spells = {80353}

local to_monitors_buffs = #arcane_monitor_spells
if to_monitors_buffs < #ice_monitor_spells then
	to_monitors_buffs = #ice_monitor_spells
end
if to_monitors_buffs < #fire_monitor_spells then
	to_monitors_buffs = #fire_monitor_spells
end

local function cofunc(yd)
	local monitor_spells

	local grids_meta = Peachpies.CreateGrids("default",5,5,to_monitors_buffs)
	local globalframe = grids_meta.globalframe
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local grid_profile
	local center_text1 = center_texts[1]
	local bottom_text1 = bottom_texts[1]
	local specialization
	while true do
		repeat
		if yd == 0 then
			specialization = GetSpecialization()
			if specialization == 1 then
				monitor_spells = arcane_monitor_spells
				grid_profile = Peachpies.GridsConfig(Peachpies.GetProfile("default"),grids_meta)
				if grid_profile.Enable then
					yd=coyield(2)
				else
					yd=coyield()
				end
			else
				globalframe:Hide()
				yd=coyield()
			end
			break
		else
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
				local max_arcane_harmony_stacks = 20
				local suggest_min_arcane_harmony_stacks = 12
				if player_in_pvp() then
					max_arcane_harmony_stacks = 10
					suggest_min_arcane_harmony_stacks = 6
				end
				local has_clearcasting = false
				local has_rune_of_power = false
				local has_arcane_power = false	-- arcane_power is arcane surge on dragonflight
				for i=1,40 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("PLAYER",i,"PLAYER|HELPFUL")
					if name == nil then
						break
					end
					if spellId == 384455 then	--arcane harmony
						arcane_harmony_stacks = count
					end
					if spellId == 263725 then
						has_clearcasting = true
					end
					if spellId == 116014 then
						has_rune_of_power = true
					end
					if spellId == arcane_power_buff_id then
						has_arcane_power = true
					end
				end
				if arcane_harmony_stacks == 0 then
					bottom_text1:Hide()
				else
					Peachpies_GridCenter(grid_profile,arcane_harmony_stacks,suggest_min_arcane_harmony_stacks,max_arcane_harmony_stacks,bottom_text1)
					bottom_text1:Show()
				end
				local has_radiant_spark
				local radiant_spark_vulnerability_counts = 0
				for i=1,40 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("TARGET",i,"PLAYER|HARMFUL")
					if name == nil then
						break
					end
					if spellId == 376104 then
						radiant_spark_vulnerability_counts = count
					end
					if spellId == 376103 then	-- Radiant Spark
						has_radiant_spark = true
					end
					
				end
				local burn_totm, burn_arcane_power
				if not has_rune_of_power then
					local start, duration, enabled, modRate = GetSpellCooldown(116011)	--rune of power
					if duration ~= gcd_duration and duration ~= 0 then
						if starttime < start + 1 then
							has_rune_of_power = true
						end
					end
				end
				local arcane_orb_casted = false
				local casting_first_spell = true
				local totm_casted = false
				local i = 1
				local has_rune_of_power_or_arcane_power = has_rune_of_power or has_arcane_power
				local burn_phase = has_radiant_spark or has_rune_of_power_or_arcane_power
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				if castspellId == 116011 or castspellId == 376103 or castspellId == 321507 or castspellId == arcane_power_spellid then
					burn_phase = true
				end
				if burn_phase then
					local start, duration, enabled, modRate
					if not has_rune_of_power then
						start, duration, enabled, modRate = GetSpellCooldown(116011)	--rune of power
						if duration ~= gcd_duration and duration ~= 0 then
							if start + 1 < starttime then
								has_rune_of_power = true
							end
						end
						start, duration, enabled, modRate = GetSpellCooldown(arcane_power_spellid)	--arcane power
						if duration ~= gcd_duration and duration ~= 0 then
							if start + 1 < starttime then
								has_arcane_power = true
							end
						end
						start, duration, enabled, modRate = GetSpellCooldown(376103)	--radiant spark
						if duration ~= gcd_duration and duration ~= 0 then
							if start + 1 < starttime then
								has_radiant_spark = true
							end
						end
					end
					if castspellId == 376103 then
						has_radiant_spark = true
					else
						start, duration, enabled, modRate = GetSpellCooldown(376103)	--radiant spark
						if duration == gcd_duration or duration == 0 then
							has_radiant_spark = true
						end
					end
					if castspellId == 321507 then
						charges = max_charges
					else
						start, duration, enabled, modRate = GetSpellCooldown(321507)	--touch of the magi
						if duration == gcd_duration or duration == 0 then
							burn_totm = true
							charges = max_charges
						end
					end
					if not has_rune_of_power and castspellId ~= 116011 then
						start, duration, enabled, modRate = GetSpellCooldown(arcane_power_spellid)	--arcane power
						if duration == 0 then
							burn_arcane_power = true
						end
					end
					if has_radiant_spark then
						burn_phase = true
					end
				end
				--GetSpellCooldown(376103)
				while i <= 4 do
					local current_spell = 44425
					repeat
						if (not has_arcane_power or not isretail) and percentage < chargemana then
							-- Evocation
							if is_spell_known(12051) then
								local evocation_start,evocation_duration,evocation_enabled,evocation_modRate = GetSpellCooldown(12051)
								if gcd_duration < evocation_duration or (evocation_duration <= gcd_duration and current_time + gcd_duration >= evocation_start + evocation_duration)  then
									current_spell = 12051
									current_time = current_time + 6/haste_effect
									percentage = val
								end
								break
							end
						end
						if burn_phase then
							if burn_arcane_power then
								if radiant_spark_vulnerability_counts == 3 then
									current_spell = arcane_power_spellid
									burn_arcane_power = false
									radiant_spark_vulnerability_counts = radiant_spark_vulnerability_counts + 1
									burn_totm = true
									break
								end
							end
							if burn_totm then
								if charges < max_charges then
									current_spell = 321507
									charges = max_charges
								else
									current_spell = 44425
									charges = 0
								end
								burn_totm = false
								break
							end
							if charges < max_charges then
								-- Arcane Orb
								if is_spell_known(153626) then
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
							if has_clearcasting and not burn_phase then
								arcane_harmony_stacks = arcane_harmony_stacks + 8
								current_spell = 5143
								has_clearcasting = false
								break
							end
							if charges == 0 then
								-- Touch of the Magi
								if is_spell_known(321507) then
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
								if is_spell_known(153626) then
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
				Peachpies_GridsSpellMinitoring(grid_profile,grids_meta,monitor_spells)
				globalframe:Show()
			else
				globalframe:Hide()
			end
		end
		yd=coyield()
		until true
	end
end

Peachpies.AddCoroutine(coroutine.create(cofunc))
