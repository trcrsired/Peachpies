local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridsSpellMinitoring = Peachpies.GridsSpellMonitoring
local coyield = coroutine.yield
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitCastingInfo = UnitCastingInfo
local Peachpies_GridCenter = Peachpies.GridCenter
local UnitIsUnit = UnitIsUnit
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsVisible = UnitIsVisible
local UnitAura = Peachpies.UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe
local is_spell_known_not_cooldown = Peachpies.is_spell_known_not_cooldown
local enemies_in_range_count = Peachpies.enemies_in_range_count
local IsUsableSpell = Peachpies.IsUsableSpell
local GetSpellCharges = Peachpies.GetSpellCharges

local monitored_spells =
{
{},
{
116680,
197908,
123988,
325197
},
{
137639,	-- Storm, Earth and Fire
123904,	-- Xuen
386276, -- Bonedust Brew
123986, -- Chi Burst
122470, -- Touch of the karma
}
}

local to_monitors_buffs = Peachpies.monitor_spells_maximum(monitored_spells)

local function cofunc(yd)
	local single_target_grids_count = 5
	local aoe_grids_count = 5
	local grids_meta = Peachpies.CreateGrids(nil,single_target_grids_count,aoe_grids_count,to_monitors_buffs)
	local globalframe = grids_meta.globalframe
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
--	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local grids_profile
	local center_text1 = center_texts[1]
--	local bottom_text1 = bottom_texts[1]
	local center_text5 = center_texts[5]
	local specialization
	local spell_queue = {}
	local monitored
	while true do
		repeat
		if yd == 0 then
			specialization = GetSpecialization()
			monitored = monitored_spells[specialization]
			grids_profile = Peachpies.GridsConfig(Peachpies.GetProfile(),grids_meta)
			if grids_profile.Enable then
				yd=coyield(2)
			else
				yd=coyield()
			end
		else
			local player_self = UnitIsUnit("player","target")
			if UnitAffectingCombat("player") or (not player_self and UnitIsVisible("target")) then
				local t = unit_range("target")
				Peachpies_GridCenter(grids_profile,t,10,43,center_text1)
				Peachpies_GridsSpellMinitoring(grids_profile,grids_meta,monitored)
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				local charges = UnitPower("player", 12)
				local max_charges = UnitPowerMax("player", 12)

				local energy = UnitPower("player", 3)
				local max_energy = UnitPowerMax("player", 3)

				local charges_free = specialization == 2 -- Mistweaver monk does not use Chi since Legion
				local strike_of_the_windlord_usable = is_spell_known_not_cooldown(392983)
				local aoe_strike_of_the_windlord_usable = strike_of_the_windlord_usable
				local fists_of_fury_usable = is_spell_known_not_cooldown(113656)
				local aoe_fists_of_fury_usable = fists_of_fury_usable
				local blackout_kick_usable = is_spell_known_not_cooldown(100784)
				local rising_sun_kick_usable = is_spell_known_not_cooldown(107428)
				local touch_of_death_usable = is_spell_known_not_cooldown(322109) and IsUsableSpell(322109)
				local breath_of_fire_usable = is_spell_known_not_cooldown(115181)
				local spinning_crane_kick_usable = is_spell_known_not_cooldown(101546)

				local keg_smash_charges
				if is_spell_known_not_cooldown(121253) then
					keg_smash_charges = GetSpellCharges(121253)
				end
				local aoe_keg_smash_charges = keg_smash_charges

				local blackout_kick_charges
				if blackout_kick_usable then
					blackout_kick_charges = GetSpellCharges(205523)
				end
				local aoe_blackout_kick_charges = blackout_kick_charges
				local aoe_rising_sun_kick_usable = rising_sun_kick_usable
				local aoe_breath_of_fire_usable = breath_of_fire_usable

				local power_strikes_buff
				for i=1,40 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("PLAYER",i,"PLAYER|HELPFUL")
					if name == nil then
						break
					end
					if spellId == 129914 then	--arcane harmony
						power_strikes_buff = 129914
					end
				end

				local rjw_usable = is_spell_known_not_cooldown(116847)
				local single_charges = charges
				local single_energy = energy
				wipe(spell_queue)

				local faelinestomp_usable = is_spell_known_not_cooldown(388193)
				if specialization == 1 then
					local single_rjw_usable = rjw_usable
					for i=1,single_target_grids_count do
						local queue_spell = 100780
						if touch_of_death_usable then
							queue_spell = 322109
							touch_of_death_usable = false
						elseif single_rjw_usable then
							queue_spell = 116847
							single_rjw_usable = false
						elseif keg_smash_charges and 0 < keg_smash_charges then
							queue_spell = 121253
							keg_smash_charges = keg_smash_charges - 1
						elseif blackout_kick_charges and 0 < blackout_kick_charges then
							queue_spell = 205523
							blackout_kick_charges = blackout_kick_charges - 1
						elseif rising_sun_kick_usable then
							queue_spell = 107428
							rising_sun_kick_usable = false
						elseif breath_of_fire_usable then
							queue_spell = 115181
							breath_of_fire_usable = false
						end
						spell_queue[#spell_queue+1] = queue_spell
					end
				elseif specialization == 2 then
					local single_faelinestomp_usable = faelinestomp_usable
					for i=1,single_target_grids_count do
						local queue_spell = 100780
						if touch_of_death_usable then
							queue_spell = 322109
							touch_of_death_usable = false
						elseif single_faelinestomp_usable then
							queue_spell = 388193
							single_faelinestomp_usable = false
						elseif rising_sun_kick_usable then
							queue_spell = 107428
							rising_sun_kick_usable = false
						elseif blackout_kick_usable then
							queue_spell = 100784
							blackout_kick_usable = false
						else
							blackout_kick_usable = true
						end
						spell_queue[#spell_queue+1] = queue_spell
					end
				else
					for i=1,single_target_grids_count do
						local queue_spell = 100780
						if touch_of_death_usable then
							queue_spell = 322109
							touch_of_death_usable = false
						elseif 2 < max_charges - single_charges and 80 < single_energy then
						elseif strike_of_the_windlord_usable and 1 < single_charges then
							queue_spell = 392983
							strike_of_the_windlord_usable = false
							single_charges = single_charges - 2
						elseif fists_of_fury_usable and 2 < single_charges and single_energy < 80 then
							queue_spell = 113656
							fists_of_fury_usable = false
							single_charges = single_charges - 3
						elseif rising_sun_kick_usable and 1 < single_charges and 20 < single_energy then
							queue_spell = 107428
							rising_sun_kick_usable = false
							single_charges = single_charges - 2
						elseif blackout_kick_usable and 0 < single_charges and 10 < single_energy then
							queue_spell = 100784
							if charges_free then
								blackout_kick_usable = false
							end
							single_charges = single_charges - 1
						end
						if queue_spell == 100780 then
							single_charges = single_charges + 2
							if power_strikes_buff then
								single_charges = single_charges + 1
								power_strikes_buff = false
							end
							single_energy = single_energy - 50
						end

						if charges_free then
							single_energy = max_energy
							single_charges = max_charges
						else
							if max_charges < single_charges then
								single_charges = max_charges
							end
							if single_energy < 0 then
								single_energy = 0
							end
						end
						spell_queue[#spell_queue+1] = queue_spell
					end
				end
				GridsQueueSpells(castspellId,castendTimeMS,spell_queue,backgrounds,cooldowns,1,single_target_grids_count-1)
				wipe(spell_queue)
				local aoe_charges = charges
				local aoe_energy = energy
				local chiburst_usable = is_spell_known_not_cooldown(123986)
				if specialization == 1 then
					local aoe_rjw_usable = rjw_usable
					for i=1,aoe_grids_count do
						local queue_spell = 100780
						if chiburst_usable then
							queue_spell = 123986
							chiburst_usable = false
						elseif aoe_rjw_usable then
							queue_spell = 116847
							aoe_rjw_usable = false
						elseif aoe_keg_smash_charges and 0 < aoe_keg_smash_charges then
							queue_spell = 121253
							aoe_keg_smash_charges = aoe_keg_smash_charges - 1
						elseif aoe_blackout_kick_charges and 0 < aoe_blackout_kick_charges then
							queue_spell = 205523
							aoe_blackout_kick_charges = aoe_blackout_kick_charges - 1
						elseif aoe_rising_sun_kick_usable then
							queue_spell = 107428
							aoe_rising_sun_kick_usable = false
						elseif aoe_breath_of_fire_usable then
							queue_spell = 115181
							aoe_breath_of_fire_usable = false
						elseif spinning_crane_kick_usable then
							queue_spell = 322729
						end
						spell_queue[#spell_queue+1] = queue_spell
					end
				elseif specialization == 2 then
					local aoe_faelinestomp_usable = faelinestomp_usable
					for i=1,aoe_grids_count do
						local queue_spell = 100780
						if aoe_faelinestomp_usable then
							queue_spell = 388193
							aoe_faelinestomp_usable = false
						elseif chiburst_usable then
							queue_spell = 123986
							chiburst_usable = false
						elseif spinning_crane_kick_usable then
							queue_spell = 101546
						end
						spell_queue[#spell_queue+1] = queue_spell
					end
				else
					local aoe_rjw_usable = rjw_usable
					for i=1,aoe_grids_count do
						local queue_spell = 100780
						if aoe_rjw_usable and 0 < aoe_charges then
							queue_spell = 116847
							aoe_rjw_usable = false
							aoe_charges = aoe_charges - 1
						elseif 2 < max_charges - aoe_charges and 80 < aoe_energy then
						elseif aoe_strike_of_the_windlord_usable and 1 < aoe_charges then
							queue_spell = 392983
							aoe_strike_of_the_windlord_usable = false
							aoe_charges = aoe_charges - 2
						elseif aoe_fists_of_fury_usable and 2 < aoe_charges and aoe_energy < 80 then
							queue_spell = 113656
							aoe_fists_of_fury_usable = false
							aoe_charges = aoe_charges - 3
						elseif spinning_crane_kick_usable and 1 < aoe_charges and 10 < aoe_energy then
							queue_spell = 101546
							if charges_free then
								spinning_crane_kick_usable = false
							end
							aoe_charges = aoe_charges - 1
						end
						if queue_spell == 100780 then
							aoe_charges = aoe_charges + 2
							if power_strikes_buff then
								aoe_charges = aoe_charges + 1
								power_strikes_buff = false
							end
							aoe_energy = aoe_energy - 50
						end
						if charges_free then
							aoe_energy = max_energy
							aoe_charges = max_charges
						else
							if max_charges < aoe_charges then
								aoe_charges = aoe_charges
							end
							if aoe_charges < 0 then
								aoe_charges = 0
							end
						end
						spell_queue[#spell_queue+1] = queue_spell
					end
				end
				--Peachpies_GridCenter(grids_profile,enemies_in_range_count(8),3,10,center_text5,"%d")
				GridsQueueSpells(castspellId,castendTimeMS,spell_queue,backgrounds,cooldowns,single_target_grids_count,single_target_grids_count+aoe_grids_count-2)
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
