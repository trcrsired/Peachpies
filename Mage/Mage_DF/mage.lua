local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridsSpellMinitoring = Peachpies.GridsSpellMonitoring
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
local GetSpellCooldown = GetSpellCooldown
local UnitAura = UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe

local arcane_power_spellid = 365350
--local arcane_power_buff_id = 365362

--Arcane: Arcane Power, Touch of the Magi,Radiant Spark , Rune of Power, Mirror, Timewrap

local arcane_monitor_spells = {arcane_power_spellid,321507,376103,116011,382440,55342,80353}

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

local evocation_start,evocation_duration,evocation_enabled,evocation_modRate = GetSpellCooldown(12051)

local is_spell_known_not_cooldown = Peachpies.is_spell_known_not_cooldown

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
	local spell_queue = {}
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
				local charges = UnitPower("player", 16)
				local max_charges = UnitPowerMax("player", 16)

--[[
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
]]
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
					Peachpies_GridCenter(grid_profile,arcane_harmony_stacks,suggest_min_arcane_harmony_stacks,max_arcane_harmony_stacks,bottom_text1)
					bottom_text1:Show()
				end
				local in_radiant_spark
				local radiant_spark_vulnerability_counts = 0
				local has_nether_tempest
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
				
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				if castspellId == 376103 then
					in_radiant_spark = true
				end
				wipe(spell_queue)

				local arcane_orb_usable = is_spell_known_not_cooldown(153626)
				local arcane_surge_usable = is_spell_known_not_cooldown(365350)
				local arcane_barrage_usable = is_spell_known(44425)
				local arcane_missile_usable = is_spell_known(44425)
				if not arcane_missile_usable then
					has_clearcasting = false
				end
				local in_touch_of_the_magi = in_radiant_spark
				if is_spell_known_not_cooldown(376103) == false then
					in_touch_of_the_magi = true
				end
				in_touch_of_the_magi = in_touch_of_the_magi and is_spell_known_not_cooldown(321507)
				for i=1,5 do
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
					elseif charges == max_charges then
						if has_clearcasting then
							thisroundspell = 5143
							has_clearcasting = false
						elseif arcane_barrage_usable then
							thisroundspell = 44425
						end
					end
					if thisroundspell == 30451 or thisroundspell == 153626 then
						charges = charges + 1
					elseif thisroundspell == 321507 then
						charges = charges + 4
					elseif thisroundspell == 44425 then
						charges = 0
					end
					if max_charges < charges then
						max_charges = charges
					end
					spell_queue[i]=thisroundspell
				end
				GridsQueueSpells(castspellId,castendTimeMS,spell_queue,backgrounds,cooldowns,1,4)
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
