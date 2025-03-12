local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridsSpellMinitoring = Peachpies.GridsSpellMonitoring
local coyield = coroutine.yield
local is_spell_known = Peachpies.is_spell_known
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetTime = GetTime
local GetHaste = GetHaste
local player_in_pvp = Peachpies.player_in_pvp
local UnitCastingInfo = UnitCastingInfo
local Peachpies_GridCenter = Peachpies.GridCenter
local UnitIsUnit = UnitIsUnit
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsVisible = UnitIsVisible
local GetSpellCooldown = GetSpellCooldown
local UnitAura = Peachpies.UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe
local math_floor = math.floor
local enemies_in_range_count = Peachpies.enemies_in_range_count
local GetMasteryEffect = GetMasteryEffect
local UnitHealthMax = UnitHealthMax
local UnitExists = UnitExists
local UnitHealth = UnitHealth
--local UnitIsPlayer = UnitIsPlayer

local monitored_spells =
{
--Arcane
{
376103,
12051,
365350,
321507,
116011,
382440,
55342,
80353
},
--Fire
{
80353
},
--Frost
{
84714,
382440,
12472,
116011,
55342,
80353
}
}

local to_monitored_buffs = Peachpies.monitor_spells_maximum(monitored_spells)

local is_spell_known_not_cooldown = Peachpies.is_spell_known_not_cooldown

local function cofunc(yd)
	local monitor_spells
	local single_target_grids_count = 5
	local aoe_grids_count = 5
	local grids_meta = Peachpies.CreateGrids(nil,single_target_grids_count,aoe_grids_count,to_monitored_buffs)
	local globalframe = grids_meta.globalframe
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local grids_profile
	local center_text1 = center_texts[1]
	local bottom_text1 = bottom_texts[1]
	local center_text5 = center_texts[5]
	local specialization
	local spell_queue = {}
	while true do
		repeat
		if yd == 0 then
			specialization = GetSpecialization()
			if specialization ~= 2 then
				monitor_spells = monitored_spells[specialization]
				grids_profile = Peachpies.GridsConfig(Peachpies.GetProfile(),grids_meta)
				if grids_profile.Enable then
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
				Peachpies_GridCenter(grids_profile,unit_range("target"),10,43,center_text1)
				Peachpies_GridsSpellMinitoring(grids_profile,grids_meta,monitor_spells)
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				local charges = UnitPower("player", 16)
				local max_charges = UnitPowerMax("player", 16)
				local has_nether_tempest
				local has_brain_freeze = false
				local arcane_barrage_usable = is_spell_known(44425)
				local ice_lance_known = is_spell_known(30455)
				local flurry_known = is_spell_known(44614)
				if specialization == 1 then

					local mana = UnitPower("player", 0)
					local max_mana = UnitPowerMax("player", 0)

					local val = GetMasteryEffect()/100 + 1
					local mana_no_master = max_mana/val

					local percentage = mana / mana_no_master

					local chargemana =  max_charges * (max_charges + 1) * 0.01375
--[[
					local starttime = GetTime()
					local current_time = starttime
					local haste_effect = 1 + GetHaste()/100
					local real_gcd_val = 1.5 / haste_effect
]]
					local killing_mode
					if UnitExists("target") then
						local playerhealthmax = UnitHealthMax("player")
						local targethealth = UnitHealth("target")
						local dividemax = playerhealthmax * 0.8
						if targethealth < dividemax and percentage > 0.5 then
							killing_mode = true
						end
					end
					local arcane_harmony_stacks = 0
					local max_arcane_harmony_stacks = 20
					local suggest_min_arcane_harmony_stacks = 12
					if player_in_pvp() then
						max_arcane_harmony_stacks = 10
						suggest_min_arcane_harmony_stacks = 6
					end
					local has_clearcasting = false
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
					end
					if arcane_harmony_stacks == 0 then
						bottom_text1:Hide()
					else
						Peachpies_GridCenter(grids_profile,arcane_harmony_stacks,suggest_min_arcane_harmony_stacks,max_arcane_harmony_stacks,bottom_text1)
						bottom_text1:Show()
					end
					local in_radiant_spark
					local radiant_spark_vulnerability_counts = 0

					for i=1,40 do
						local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
						nameplateShowPersonal, spellId = UnitAura("TARGET",i,"PLAYER|HARMFUL")
						if name == nil then
							break
						end
						if spellId == 376104 then
							radiant_spark_vulnerability_counts = count
							in_radiant_spark = true
						elseif spellId == 114923 then
							has_nether_tempest = true
						end
						if spellId == 376103 then	-- Radiant Spark
							in_radiant_spark = true
						end
					end
					
					if castspellId == 376103 then
						in_radiant_spark = true
					end
					wipe(spell_queue)

					local arcane_orb_usable = is_spell_known_not_cooldown(153626)
					local arcane_surge_usable = is_spell_known_not_cooldown(365350)

					local arcane_missile_usable = is_spell_known(44425)
					if not arcane_missile_usable then
						has_clearcasting = false
					end
					local in_touch_of_the_magi = in_radiant_spark and is_spell_known_not_cooldown(321507)

					local single_charages = charges
					for i=1,single_target_grids_count do
						local thisroundspell = 30451
						if in_radiant_spark then
							if radiant_spark_vulnerability_counts == 4 then
								if arcane_barrage_usable then
									thisroundspell = 44425
								end
								in_radiant_spark = false
								radiant_spark_vulnerability_counts = 0
							else
								if radiant_spark_vulnerability_counts == 3 then
									if arcane_surge_usable then
										thisroundspell = 365350
										arcane_surge_usable = false
									end
								end
								radiant_spark_vulnerability_counts = radiant_spark_vulnerability_counts + 1
							end
						elseif in_touch_of_the_magi then
							thisroundspell = 321507
							in_touch_of_the_magi = false
						elseif arcane_orb_usable then
							thisroundspell = 153626
							arcane_orb_usable = false
						elseif single_charages == max_charges then
							if has_clearcasting then
								thisroundspell = 5143
								has_clearcasting = false
							elseif not killing_mode and arcane_barrage_usable then
								thisroundspell = 44425
							end
						end
						if thisroundspell == 30451 or thisroundspell == 153626 then
							single_charages = single_charages + 1
						elseif thisroundspell == 321507 then
							single_charages = single_charages + 4
						elseif thisroundspell == 44425 then
							single_charages = 0
						end
						if max_charges < single_charages then
							single_charages = max_charges
						end
						spell_queue[i]=thisroundspell
					end
					GridsQueueSpells(castspellId,castendTimeMS,spell_queue,backgrounds,cooldowns,1,single_target_grids_count-1)
				elseif specialization == 3 then
					local gcd_start, gcd_duration, gcd_enabled, gcd_modRate = GetSpellCooldown(61304)
					local realgcd_duration = 1.5/(1+GetHaste()/100)
					local target_winterschillcharges_counts
					for i=1,100 do
						local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
						nameplateShowPersonal, spellId = UnitAura("TARGET",i,"PLAYER|HARMFUL")
						if name == nil then
							break
						end
						local gtime = GetTime()
						if spellId == 228358 and gtime <= expirationTime then
							local expiration_count = math_floor((expirationTime - gtime)/realgcd_duration)
							target_winterschillcharges_counts = count
							if expiration_count < count then
								expiration_count = target_winterschillcharges_counts
							end
							break
						end
					end
					local fof_count
					for i=1,100 do
						local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
						nameplateShowPersonal, spellId = UnitAura("PLAYER",i,"PLAYER|HELPFUL")
						if name == nil then
							break
						end
						if spellId == 190446 then
							has_brain_freeze = true
						elseif spellId == 44544 then
							fof_count = count
						end
					end
					wipe(spell_queue)
					local single_has_brain_freeze = has_brain_freeze
					for i=1,single_target_grids_count do
						local thisroundspell = 116
						if single_has_brain_freeze then
							if flurry_known then
								thisroundspell = 44614
								single_has_brain_freeze = false
							end
						else
							if target_winterschillcharges_counts then
								if ice_lance_known then
									if not fof_count or fof_count < target_winterschillcharges_counts then
										fof_count = target_winterschillcharges_counts
										thisroundspell = 30455
										fof_count = fof_count + 1
									end
								end
							end
						end
						spell_queue[#spell_queue+1] = thisroundspell
					end
--					Peachpies_GridCenter(grids_profile,arcane_explosion_count,3,10,center_text5,"%d")
					GridsQueueSpells(castspellId,castendTimeMS,spell_queue,backgrounds,cooldowns,1,single_target_grids_count-1)
				end
				local arcane_explosion_count = enemies_in_range_count(10)
				wipe(spell_queue)
				local nether_tempest_usable = is_spell_known(114923)
				local blizzard_usable = is_spell_known_not_cooldown(190356)
				local orb_usable
				if is_spell_known_not_cooldown(153626) then
					orb_usable = 153626
				elseif is_spell_known_not_cooldown(84714) then
					orb_usable = 84714
				end
				local aoe_charges = charges
				for i=1,aoe_grids_count do
					local thisroundspell = 1449
					if max_charges == aoe_charges and arcane_barrage_usable then
						thisroundspell = 44425
					elseif orb_usable then
						thisroundspell = orb_usable
						orb_usable = nil
					elseif not has_nether_tempest and nether_tempest_usable then
						thisroundspell = 114923
						has_nether_tempest = true
					elseif blizzard_usable then
						thisroundspell = 190356
						blizzard_usable = false
					else
--[[
						if has_brain_freeze then
							if flurry_known then
								thisroundspell = 44614
								has_brain_freeze = false
							end
						end
]]
						if ice_lance_known and thisroundspell ~= 44614 then
							thisroundspell = 30455
						end
					end
					if thisroundspell == 1449 then
						if 0 < arcane_explosion_count then
							aoe_charges = aoe_charges + 1
						end
					elseif thisroundspell == 153626 then
						aoe_charges = aoe_charges + 2
					elseif thisroundspell == 44425 then
						aoe_charges = 0
					end
					if max_charges < aoe_charges then
						aoe_charges = max_charges
					end
					spell_queue[#spell_queue + 1] = thisroundspell
				end
				Peachpies_GridCenter(grids_profile,arcane_explosion_count,3,10,center_text5,"%d")
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
