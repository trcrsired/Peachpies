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
local GetSpellCharges = Peachpies.GetSpellCharges
local UnitAura = Peachpies.UnitAura
local GridsQueueSpells = Peachpies.GridsQueueSpells
local wipe = wipe
local IsUsableSpell = Peachpies.IsUsableSpell
local enemies_in_range_count = Peachpies.enemies_in_range_count

local monitored_spells =
{
--
{
5394
},
--
{
5394
},
--
{
5394
}
}

local to_monitored_buffs = Peachpies.monitor_spells_maximum(monitored_spells)

local is_spell_known_not_cooldown = Peachpies.is_spell_known_not_cooldown
local is_spell_not_cooldown = Peachpies.is_spell_not_cooldown

local function cofunc(yd)
	local monitor_spells
	local single_target_grids_count = 6
	local aoe_grids_count = 5
	local grids_meta = Peachpies.CreateGrids(nil,single_target_grids_count,aoe_grids_count,to_monitored_buffs)
	local globalframe = grids_meta.globalframe
	local backgrounds = grids_meta.backgrounds
	local center_texts = grids_meta.center_texts
--	local bottom_texts = grids_meta.bottom_texts
	local cooldowns = grids_meta.cooldowns
	local grids_profile
	local center_text1 = center_texts[1]
	local center_text5 = center_texts[single_target_grids_count]
	local specialization
	local spell_queue = {}
	local playerisbloodelf = select(3,UnitRace("player")) == 10
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
				local focus_increase_per_sec = 10 * hasteeffect
				local realgcd_duration = 1.5/hasteeffect
				local focus_increase_per_gcd = focus_increase_per_sec / realgcd_duration
				for isaoe=1,2 do
					local beastcleaveremained = 0
					local frenzyremained = 0
					for i=1,100 do
						local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
						nameplateShowPersonal, spellId = UnitAura("PET",i,"PLAYER|HELPFUL")
						if name == nil then
							break
						end
						if gtime < expirationTime then
							local remainedtime = expirationTime - gtime
							if spellId == 118455 then -- beast cleave
								beastcleaveremained = remainedtime
							elseif spellId == 272790 then -- Frenzy
								frenzyremained = remainedtime
							end
						end
					end
					local focus_val = UnitPower("player", 2)
					local focus_max = UnitPowerMax("player", 2)
					local bestialwrath = is_spell_known_not_cooldown(19574)

					local barbedshot,barbedshotmax = 0,2
					if is_spell_known(34026) then
						barbedshot,barbedshotmax = GetSpellCharges(217200)
					end
					local killcommand_charges = 0
					if is_spell_known(34026) then
						killcommand_charges = GetSpellCharges(34026)
					end
					local killshot_charges = 0
					if is_spell_known(54351) then
						killshot_charges = GetSpellCharges(54351)
					end
					if not IsUsableSpell(54351) then
						killshot_charges = 0
					end
					local cobrashot = IsUsableSpell(193455)
					local arcanetorrent = false
					if playerisbloodelf and is_spell_not_cooldown(80483) then
						arcanetorrent = true
					end
					local rounds = 5
					local start_grid,end_grid
					if isaoe == 1 then
						rounds = single_target_grids_count - 1
						start_grid = 1
						end_grid = single_target_grids_count - 2
					else
						rounds = aoe_grids_count
						start_grid = single_target_grids_count
						end_grid = single_target_grids_count + rounds - 2
					end
					wipe(spell_queue)
					for i=1,rounds do
						local roundspellid = 6603
						local focus_remain = focus_max - focus_val
						local usebarbedshot = 0 < barbedshot
						local usemultishot = 40 < focus_val and beastcleaveremained <= 1.5
						if isaoe == 2 and usemultishot then
							usebarbedshot = false
						end
						if usebarbedshot then
							barbedshot = barbedshot - 1
							roundspellid = 217200
							frenzyremained = 8
						elseif usemultishot then
							roundspellid = 2643
							focus_val = focus_val - 40
							beastcleaveremained = 8
						end
						if roundspellid == 6603 then
							if bestialwrath then
								roundspellid = 19574
								bestialwrath = false
							elseif 0 < killcommand_charges and 30 <= focus_val then
								roundspellid = 34026
								killcommand_charges = killcommand_charges - 1
								focus_val = focus_val - 30
							elseif 10 <= focus_val and 0 < killshot_charges then
								killshot_charges = killshot_charges - 1
								focus_val = focus_val - 10
								roundspellid = 53351
							elseif 35 <= focus_val and cobrashot then
								killshot_charges = killshot_charges - 1
								focus_val = focus_val - 35
								roundspellid = 193455
							elseif 20 < focus_remain and arcanetorrent then
								arcanetorrent = false
								roundspellid = 80483 -- arcane torrent
								focus_val = focus_val + 15
							end
						end
						spell_queue[#spell_queue+1]=roundspellid
						focus_val = focus_val + focus_increase_per_gcd
						if focus_val < 0 then
							focus_val = 0
						elseif focus_max < focus_val then
							focus_val = focus_max
						end
						if focus_max < focus_val then
							focus_val = focus_max
						end
					end
					Peachpies_GridCenter(grids_profile,enemies_in_range_count(40),3,10,center_text5,"%d")
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
