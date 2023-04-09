local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")
--[[
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
local UnitAura = UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe
local math_floor = math.floor
local enemies_in_range_count = Peachpies.enemies_in_range_count
local GetSpellCharges = GetSpellCharges

local monitored_spells =
{
{
191427
},
{
187827
},
}

local to_monitored_buffs = Peachpies.monitor_spells_maximum(monitored_spells)

local is_spell_known_not_cooldown = Peachpies.is_spell_known_not_cooldown

local function cofunc(yd)
	local monitor_spells
	local single_target_grids_count = 5
	local aoe_grids_count = 0
	local grids_meta = Peachpies.CreateGrids(nil,single_target_grids_count,aoe_grids_count,to_monitored_buffs)
	local globalframe = grids_meta.globalframe
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
--	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local grids_profile
	local center_text1 = center_texts[1]
--	local bottom_text1 = bottom_texts[1]
--	local center_text5 = center_texts[5]
	local specialization
	local spell_queue = {}
	while true do
		repeat
		if yd == 0 then
			specialization = GetSpecialization()
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
				local t = unit_range("target")
				if t then
					Peachpies_GridCenter(grids_profile,t,10,43,center_text1,"%d")
				end
				Peachpies_GridsSpellMinitoring(grids_profile,grids_meta,monitor_spells)
				local fury_val = UnitPower("player", 17)
				local max_fury = UnitPowerMax("player", 17)
				local has_essense_break = false
				local has_unbound_chaos = false
				local has_momentum = false
				local has_chaos_theory = false
				local soul_fragments_count = 0
				for i=1,100 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("PLAYER",i,"PLAYER|HELPFUL")
					if name == nil then
						break
					elseif spellId == 258860 then
						has_essense_break = true
					elseif spellId == 347461 then
						has_unbound_chaos = true
					elseif spellId == 206476 then
						has_momentum = true
					elseif spellId == 390195 then
						has_chaos_theory = true
					elseif spellId == 203981 then
						soul_fragments_count = count
					end
				end
				local felrush_usable = is_spell_known(195072)
				local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")

					wipe(spell_queue)
					local fury = fury_val
					local the_hunt_usable = is_spell_known_not_cooldown(370965)
					local death_sweep_usable = is_spell_known_not_cooldown(210152)
					local blade_dance_usable = is_spell_known_not_cooldown(188499)
					local eye_beam_usable = is_spell_known_not_cooldown(198013)
					local vengeful_retreat_usable = is_spell_known_not_cooldown(198793)
					local essence_break_usable = is_spell_known_not_cooldown(258860)
					local metamorphosis_id = 191427
					if specialization == 2 then
						metamorphosis_id = 187827
					end
					local metamorphosis_usable = is_spell_known_not_cooldown(metamorphosis_id)
					local annihilation_usable = is_spell_known_not_cooldown(201427)
					local immolation_aura_usable = is_spell_known_not_cooldown(258920)
					local felblade_usable = is_spell_known_not_cooldown(232893)
					local sigilofflame_usable = is_spell_known_not_cooldown(204596)
					local throwglaives_usable = is_spell_known_not_cooldown(185123)
					local soul_carver_usable = is_spell_known_not_cooldown(207407)
					local felrush_charges = 0
					local fraility_stacks = 0

					if felrush_usable then
						felrush_charges = GetSpellCharges(195072)
						if felrush_charges == nil then
							felrush_charges = 0
						end
					end

					local fiery_brand_usable = is_spell_known_not_cooldown(204021)


					local fiery_brand_charges = 0
					if fiery_brand_usable then
						fiery_brand_usable = GetSpellCharges(204021)
						if fiery_brand_usable == nil then
							fiery_brand_usable = 0
						end
					end
					local rounds = 5
					local start_grid,end_grid
						rounds = single_target_grids_count
						start_grid = 1
						end_grid = single_target_grids_count - 1

					for i=1,rounds do
						local single_spell = 203555
						if the_hunt_usable then
							single_spell = 370965
							the_hunt_usable = false
						elseif 4 <= soul_fragments_count and 0 < fiery_brand_charges then
							single_spell = 204021
							fiery_brand_charges = fiery_brand_charges - 1
						elseif 6 <= fraility_stacks and soul_carver_usable then
							single_spell = 207407
							soul_carver_usable = false
						elseif death_sweep_usable and fury >= 35 then
							single_spell = 210152
							fury = fury - 35
							death_sweep_usable = false
						elseif blade_dance_usable and fury >= 35 then
							single_spell = 188499
							fury = fury - 35
							blade_dance_usable = false
						elseif eye_beam_usable and fury >= 30 then
							single_spell = 198013
							fury = fury - 30
							eye_beam_usable = false
						elseif vengeful_retreat_usable then
							single_spell = 198793
							vengeful_retreat_usable = false
						elseif essence_break_usable then
							single_spell = 258860
							essence_break_usable = false
						elseif metamorphosis_usable then
							single_spell = metamorphosis_id
							metamorphosis_usable = false
						elseif annihilation_usable and (has_essense_break or fury >= 40) then
							single_spell = 201427
							if has_essense_break then
								has_essense_break = false
							else
								fury = fury - 40
							end
							annihilation_usable = false
						elseif immolation_aura_usable then
							single_spell = 258920
							fury = fury + 20
							immolation_aura_usable = false
						elseif 0 < felrush_charges and has_unbound_chaos then
							single_spell = 195072
							felrush_charges = felrush_charges - 1
						elseif felblade_usable and fury < 80 then
							single_spell = 232893
							fury = fury + 40
							felblade_usable = false
						elseif has_chaos_theory or 40 <= fury then
							single_spell = 162794
							if has_chaos_theory then
								has_chaos_theory = false
							else
								fury = fury - 40
							end
						elseif 0 < felrush_charges and not has_momentum then
							single_spell = 195072
							felrush_charges = felrush_charges - 1
						elseif sigilofflame_usable then
							single_spell = 204596
							sigilofflame_usable = false
							fury = fury + 30
						elseif throwglaives_usable then
							single_spell = 185123
							throwglaives_usable = false
						else
							fury = fury + 10
						end
						if max_fury < fury then
							fury = max_fury
						end
						spell_queue[i] = single_spell
					end
					GridsQueueSpells(castspellId,
						castendTimeMS,spell_queue,
						backgrounds,cooldowns,
						start_grid,end_grid)
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
]]