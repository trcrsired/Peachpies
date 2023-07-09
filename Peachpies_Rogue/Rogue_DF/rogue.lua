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
local GetSpellCharges = GetSpellCharges
local UnitAura = UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe
local enemies_in_range_count = Peachpies.enemies_in_range_count

local monitored_spells =
{
--Assassination
{
114018
},
--Outlaw
{
114018
},
--Subtlety
{
114018
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
			if specialization == 5 then
				specialization = 3
			end
			monitor_spells = monitored_spells[specialization]
			grids_profile = Peachpies.GridsConfig(Peachpies.GetProfile(),grids_meta)
			if grids_profile.Enable then
				yd=coyield(2)
			else
				yd=coyield()
			end
			break
		else
			local player_self = UnitIsUnit("player","target")
			if UnitAffectingCombat("player") or (not player_self and UnitIsVisible("target")) then
				Peachpies_GridCenter(grids_profile,unit_range("target"),10,43,center_text1)
				Peachpies_GridsSpellMinitoring(grids_profile,grids_meta,monitor_spells)
				local gtime = GetTime()
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				local hasteeffect = (1+GetHaste()/100)
				local energy_increase_per_sec = 10 * hasteeffect
				local realgcd_duration = 1.5/hasteeffect
				local energy_increase_per_gcd = energy_increase_per_sec / realgcd_duration
				for isaoe=1,2 do
					local has_combat_effect = false
					local has_sliceanddice = false
					local has_opportunity = false
					local has_stealth_or_vanish = false
					local has_blade_flurry
					for i=1,100 do
						local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
						nameplateShowPersonal, spellId = UnitAura("PLAYER",i,"PLAYER|HELPFUL")
						if name == nil then
							break
						elseif spellId == 1784 or spellId == 11327 then
							has_stealth_or_vanish = true
						elseif spellId == 13877 then
							has_blade_flurry = true
						elseif spellId == 315496 and expirationTime and (12 <= expirationTime - gtime) then
							has_sliceanddice = true
						elseif spellId == 195627 and expirationTime and gtime <= expirationTime then
							has_opportunity = true
						end
					end

					local energy_val = UnitPower("player", 3)
					local energy_max = UnitPowerMax("player", 3)

					local combopoints_val = UnitPower("player", 4)
					local combopoints_max = UnitPowerMax("player", 4)

					local andenaline = is_spell_known_not_cooldown(13750)
					local rollthebones = is_spell_known_not_cooldown(315508)
--					local keepitrolling = is_spell_known_not_cooldown(381989)
					local betweeneyes = is_spell_known_not_cooldown(315341)
					local sliceanddice = is_spell_known_not_cooldown(315496)
					local bladeflurry = is_spell_known_not_cooldown(13877)
					local dispatch = true
					local pistolshot = is_spell_known_not_cooldown(185763)
					local vanish = is_spell_known(1856)
					local vanishcharges = 0
					if vanish then
						vanishcharges = GetSpellCharges(1856)
					end
					local rounds = 5
					local start_grid,end_grid
					if isaoe == 1 then
						rounds = single_target_grids_count
						start_grid = 1
						end_grid = single_target_grids_count - 1
					else
						rounds = aoe_grids_count
						start_grid = single_target_grids_count
						end_grid = single_target_grids_count + rounds - 2
					end
					wipe(spell_queue)
					for i=1,rounds do
						local roundspellid = 6603
						local combatpoints_remain = combopoints_max - combopoints_val
						if has_stealth_or_vanish then
							roundspellid = 8676
							energy_val = energy_val - 50
							has_stealth_or_vanish = false
						elseif andenaline and 50 <= energy_val and 2 <= combopoints_val then
							roundspellid = 13750
							andenaline = false
							energy_val = energy_val - 50
						elseif rollthebones and 25 <= energy_val and not has_combat_effect then
							roundspellid = 315508
							rollthebones = false
							has_combat_effect = true
							energy_val = energy_val - 25
						elseif isaoe == 2 and bladeflurry and has_blade_flurry == nil then
							roundspellid = 13877
							energy_val = energy_val - 15
							bladeflurry = false
							has_blade_flurry = true
						elseif betweeneyes and 25 <= energy_val and combatpoints_remain <=1 then
							betweeneyes = false
							roundspellid = 315341
							energy_val = energy_val - 25
							combopoints_val = 0
						elseif sliceanddice and not has_sliceanddice and 25 <= energy_val and combatpoints_remain <=1 then
							sliceanddice = false
							has_sliceanddice = true
							roundspellid = 315496
							energy_val = energy_val - 25
							combopoints_val = 0
						elseif dispatch and 32 <= energy_val and combatpoints_remain <= 1 then
							dispatch = false
							roundspellid = 2098
							energy_val = energy_val - 32
							combopoints_val = 0
						elseif 0 < vanishcharges and 0 < combatpoints_remain then
							vanishcharges = vanishcharges - 1
							has_stealth_or_vanish = true
							roundspellid = 1856
						elseif pistolshot and has_opportunity and 20 <= energy_val and 0 < combatpoints_remain then
							pistolshot = false
							roundspellid = 185763
							energy_val = energy_val - 40
							combopoints_val = combopoints_val + 1
						elseif 45 <= energy_val and 0 < combatpoints_remain then
							roundspellid = 193315
							energy_val = energy_val - 45
							combopoints_val =combopoints_val + 1
						end
						spell_queue[#spell_queue+1]=roundspellid
						energy_val = energy_val + energy_increase_per_gcd
						if energy_val < 0 then
							energy_val = 0
						elseif energy_max < energy_val then
							energy_val = energy_max
						end
						if energy_max < energy_val then
							energy_val = energy_max
						end
						if combopoints_val < 0 then
							combopoints_val = 0
						elseif combopoints_max < combopoints_val then
							combopoints_val = combopoints_max
						end
					end
					Peachpies_GridCenter(grids_profile,enemies_in_range_count(8),3,10,center_text5,"%d")
					GridsQueueSpells(castspellId,
					castendTimeMS,spell_queue,
					backgrounds,cooldowns,
					start_grid,end_grid)
				end
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
