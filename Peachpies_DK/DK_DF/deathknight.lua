local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridsSpellMinitoring = Peachpies.GridsSpellMonitoring
local coyield = coroutine.yield
local is_spell_known = Peachpies.is_spell_known
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitCastingInfo = UnitCastingInfo
local Peachpies_GridCenter = Peachpies.GridCenter
local UnitIsUnit = UnitIsUnit
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsVisible = UnitIsVisible
local UnitAura = UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe
local is_spell_not_cooldown = Peachpies.is_spell_not_cooldown
local GetTime = GetTime
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates
local UnitCanAttack = UnitCanAttack
local GetSpellCharges = GetSpellCharges

local monitored_spells =
{
{

},
{

},
{
47568,51052,42650,207289
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
--	local bottom_text1 = bottom_texts[1]
	local center_text5 = center_texts[single_target_grids_count]
	local bottom_text5 = bottom_texts[single_target_grids_count]
	local specialization
	local spell_queue = {}
	local aoe_spell_queue = {}
	while true do
		repeat
		if yd == 0 then
			specialization = GetSpecialization()
			monitor_spells = monitored_spells[specialization]
			grids_profile = Peachpies.GridsConfig(Peachpies.GetProfile(),grids_meta)
			if grids_profile.Enable and specialization == 3 then
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
				local runes = UnitPower("player", 5)
				local max_runes = UnitPowerMax("player", 5)

				local runicpower = UnitPower("player", 6)
				local max_runicpower = UnitPowerMax("player", 6)
				local gtime = GetTime()
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
				local has_virulent_plague = false
				local festering_wounds_stacks = 0
				local sudden_doom_stacks = 0
				for i=1,100 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
					nameplateShowPersonal, spellId = UnitAura("TARGET",i,"PLAYER|HARMFUL")
					if name == nil then
						break
					end
					if spellId == 191587 then
						if gtime + 4 < expirationTime then
							has_virulent_plague = true
						end
					elseif spellId == 194310 then
						festering_wounds_stacks = count
					elseif spellId == 81340 then
						sudden_doom_stacks = count
					end
				end
				local nameplates = C_NamePlate_GetNamePlates()
				local virulent_count = 0
				local visible_count = 0
				if nameplates then
					for i = 1, #nameplates do
						local utoken = nameplates[i].namePlateUnitToken
						if utoken and UnitCanAttack(utoken,"player") then
							if UnitIsVisible(utoken) then
								visible_count = visible_count + 1
							end
							for j=1,100 do
								local name, icon, count, debuffType, duration, expirationTime, source, isStealable,
								nameplateShowPersonal, spellId = UnitAura(utoken,j,"PLAYER|HARMFUL")
								if name == nil then
									break
								end
								if spellId == 191587 then
									virulent_count = virulent_count + 1
									break
								end
							end
						end
					end
				end
				local effective_count = 3
				if visible_count < effective_count then
					effective_count = visible_count
				end
				local max_effective_count = effective_count * 2
				Peachpies_GridCenter(grids_profile,virulent_count,effective_count,max_effective_count,center_text5)
				bottom_text5:SetText(visible_count)
				local outbreak_usable = is_spell_known_not_cooldown(77575)
				local unholy_blight_usable = is_spell_known_not_cooldown(115989)
				
				local scourge_strike_usable = is_spell_known_not_cooldown(55090)
				local festering_strike_usable = is_spell_not_cooldown(85948)
				local death_and_decay_charges = 0
				if is_spell_known(43265) then
					death_and_decay_charges = GetSpellCharges(43265)
				end
				for roundpos = 1,2 do
					local rounds = 5
					local start_grid,end_grid
					if roundpos == 1 then
						rounds = single_target_grids_count
						start_grid = 1
						end_grid = single_target_grids_count - 1
					elseif roundpos == 2 then
						rounds = aoe_grids_count
						start_grid = single_target_grids_count
						end_grid = single_target_grids_count + aoe_grids_count - 2
					end

					wipe(spell_queue)
					local runes_rounds = runes
					local runicpower_rounds = runicpower
					local outbreak_usable_rounds = outbreak_usable
					local unholy_blight_usable_rounds = unholy_blight_usable

					local death_coil_id = 47541
					if roundpos == 2 and 3 < virulent_count then
						death_coil_id = 207317
					end
					local death_coil_usable = is_spell_known_not_cooldown(death_coil_id)
					local sudden_doom_stacks_rounds = sudden_doom_stacks
					local death_and_deacy_charges_round = death_and_decay_charges
					for i=1,rounds do
						local single_spell = 6603
						if not has_virulent_plague and unholy_blight_usable_rounds and 0 < runes_rounds then
							single_spell = 115989
							unholy_blight_usable_rounds = false
							runes_rounds = runes_rounds - 1
						elseif not has_virulent_plague and outbreak_usable_rounds and 0 < runes_rounds then
							single_spell = 77575
							outbreak_usable_rounds = false
							runes_rounds = runes_rounds - 1
						elseif roundpos == 2 and 0 < death_and_deacy_charges_round then
							single_spell = 43265
							death_and_deacy_charges_round = death_and_deacy_charges_round - 1
						elseif death_coil_usable and 75 <= runicpower_rounds then
							single_spell = death_coil_id
							runicpower_rounds = runicpower_rounds - 30
						elseif festering_strike_usable and 1 < runes_rounds and festering_wounds_stacks <= 2 then
							single_spell = 85948
							runes_rounds = runes_rounds - 2
							runicpower_rounds = runicpower_rounds + 20
						elseif scourge_strike_usable and 0 < runes_rounds and 2 < festering_wounds_stacks then
							single_spell = 55090
							runes_rounds = runes_rounds - 1
							runicpower_rounds = runicpower_rounds + 15
						elseif death_coil_usable and 0 < sudden_doom_stacks_rounds then
							single_spell = death_coil_id
							sudden_doom_stacks_rounds = sudden_doom_stacks_rounds - 1
						elseif death_coil_usable and 30 <= runicpower_rounds then
							single_spell = death_coil_id
							runicpower_rounds = runicpower_rounds - 30
						end
						if max_runes < runes_rounds then
							runes_rounds = max_runes
						end
						if max_runicpower < runicpower_rounds then
							runicpower_rounds = max_runicpower
						end
						spell_queue[i] = single_spell
					end
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
