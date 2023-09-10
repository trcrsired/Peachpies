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
local UnitCanAttack = UnitCanAttack
local GetSpellCharges = GetSpellCharges
local UnitLevel = UnitLevel
local Peachpies_AurasList = Peachpies.AurasList
local enemies_in_range_count = Peachpies.enemies_in_range_count
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local monitored_spells =
{
{
271486
},
{
10060,19236,47788,64901,64843
},
{
391109,10060,200174
}
}

local buffauralist = {[21562]=true}

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
	local buff_list,debuff_list = {},{}
	local applied_buff_list,applied_debuff_list = {},{}
	while true do
		repeat
		if yd == 0 then
			specialization = GetSpecialization()
			monitor_spells = monitored_spells[specialization]
			if monitor_spells == nil then
				monitor_spells = {}
			end
			grids_profile = Peachpies.GridsConfig(Peachpies.GetProfile(),grids_meta)
			if grids_profile.Enable then
				yd=coyield(2)
			else
				yd=coyield()
			end
			break
		else
			local player_self = UnitIsUnit("player","target")
			Peachpies_AurasList(buff_list,buffauralist,"player","HELPFUL")
			local powerwordfortitude = 6 <= UnitLevel("player")
			local incombat = UnitAffectingCombat("player") or (not player_self and UnitIsVisible("target"))
			local notpowerwordfortitude = not buff_list[21562]
			print(buff_list[21562])
			if incombat or (powerwordfortitude and notpowerwordfortitude) then
				Peachpies_GridCenter(grids_profile,unit_range("target"),10,43,center_text1)
				Peachpies_GridsSpellMinitoring(grids_profile,grids_meta,monitor_spells)
				Peachpies_AurasList(buff_list,nil,"player","PLAYER|HELPFUL")
				Peachpies_AurasList(debuff_list,nil,"target","PLAYER|HARMFUL")
				local gtime = GetTime()
				for isaoe=1,2 do
					wipe(spell_queue)
					wipe(applied_buff_list)
					wipe(applied_debuff_list)
					local insanity = UnitPower("player",13)
					local insanitymax = UnitPowerMax("player",13)
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
					local shadowcrash = is_spell_known_not_cooldown(205385)
					local vampirictouch = is_spell_known_not_cooldown(34914)
					local shadowwordpain = is_spell_known_not_cooldown(589)
					local halo = is_spell_known_not_cooldown(120644)
					local divinestar = is_spell_known_not_cooldown(122121)
					local mindgames = is_spell_known_not_cooldown(375901)
					local devouringplague = is_spell_known(335467)
					local voidtorrent = is_spell_known_not_cooldown(263165)
					local mindblastacharges = 0
					if is_spell_known(8092) then
						mindblastacharges = GetSpellCharges(8092)
					end
					local shadowworddeathcharges = 0
					if is_spell_known(32379) then
						shadowworddeathcharges = GetSpellCharges(32379)
						if shadowworddeathcharges then
							local health = UnitHealth("target")
							local healthmax = UnitHealthMax("target")
							if health > healthmax * 0.2 then
								shadowworddeathcharges = 0
							end
						end
					end
					for k,v in pairs(buff_list) do
						applied_buff_list[k] = v
						--[[print(k,UnitAura("target",v,"PLAYER|HARMFUL"))]]
					end
					for k,v in pairs(debuff_list) do
						applied_debuff_list[k] = v
						--[[print(k,UnitAura("target",v,"PLAYER|HARMFUL"))]]
					end
					local roundnotpowerwordfortitude = powerwordfortitude and notpowerwordfortitude
					for i=1,rounds do
						local roundspellid = 585
						if roundnotpowerwordfortitude then
							roundspellid = 21562
							if incombat then
								roundnotpowerwordfortitude = false
							end
						end
						if incombat and roundspellid == 585 then
							if specialization == 3  then
								if not applied_buff_list[232698] then
									roundspellid = 232698
									applied_buff_list[232698] = true
								elseif shadowcrash then
									roundspellid = 205385
									shadowcrash = false
									applied_debuff_list[34914] = true
									applied_debuff_list[589] = true
								elseif vampirictouch and (not applied_debuff_list[34914] or not applied_debuff_list[589]) then
									roundspellid = 34914
									vampirictouch = false
									applied_debuff_list[34914] = true
									applied_debuff_list[589] = true
								end
							end
							if isaoe == 2 and roundspellid == 585 then
								if halo then
									roundspellid = 120644
									halo = false
								elseif divinestar then
									roundspellid = 122121
									divinestar = false
								end
							end
							if roundspellid == 585 and shadowwordpain and not applied_debuff_list[589] then
								roundspellid = 589
								applied_debuff_list[589] = true
							end
							if applied_buff_list[375981] then
								applied_buff_list[375981] = true
								mindblastacharges = 0
								roundspellid = 8092
							end
							if 45 <= insanity and devouringplague then
								roundspellid = 335467
								devouringplague = false
							end
							if roundspellid == 585 and voidtorrent then
								roundspellid = 263165
								voidtorrent = false
							end
							if roundspellid == 585 and 0 < shadowworddeathcharges then
								shadowworddeathcharges = shadowworddeathcharges - 1
								roundspellid = 32379
							end
							if roundspellid == 585 and 0 < mindblastacharges then
								mindblastacharges = mindblastacharges - 1
								roundspellid = 8092
							end
							if roundspellid == 585 and mindgames then
								roundspellid = 375901
								mindgames = false
							end
						end
						spell_queue[#spell_queue+1]=roundspellid
						if insanity > insanitymax then
							insanity = insanitymax
						end
						if insanity < 0 then
							insanity = 0
						end
					end
					Peachpies_GridCenter(grids_profile,enemies_in_range_count(30),3,10,center_text5,"%d")
					local castname, casttext, casttexture, caststartTimeMS, castendTimeMS, castisTradeSkill, castcastID, castnotInterruptible, castspellId = UnitCastingInfo("player")
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
