local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local unit_range = Peachpies.unit_range
local Peachpies_GridSpellMinitoring = Peachpies.GridSpellMinitoring
local coyield = coroutine.yield
local GetSpellTexture = GetSpellTexture
local GetTime = GetTime
local GetHaste = GetHaste
local Peachpies_GridCenter = Peachpies.GridCenter
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsVisible = UnitIsVisible
local math_floor = math.floor

local function cofunc(yd)
	local m = 5
	--Deathborne, icy veins, rune of power, mirror image, time wrap, summon water elemental
	local monitor_spells = {324220,12472,116011,55342,80353}
	local n = #monitor_spells + m

	local specid,specname = GetSpecializationInfoByID(64)

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

				local realgcd_duration = 1.5/(1+GetHaste()/100)
				local target_winterschillcharges_expiration_time
				local gtime = GetTime()
				for i=1,100 do
					local name, icon, count, debuffType, duration, expirationTime, source, isStealable, 
					nameplateShowPersonal, spellId = UnitAura("TARGET",i,"PLAYER")
					if name == nil then
						break
					end
					if spellId == 228358 and gtime <= expirationTime then
						target_winterschillcharges_expiration_time = expirationTime
					end
				end
				local has_brain_freeze
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
				local i = 1
				if has_brain_freeze then
					backgrounds[i]:SetTexture(GetSpellTexture(44614))
					cooldowns[i]:SetCooldown(gcd_start, gcd_duration, gcd_enabled, gcd_modRate)
					i = i + 1
				end
				if target_winterschillcharges_expiration_time then
					local wc = math_floor((target_winterschillcharges_expiration_time - gtime)/realgcd_duration)
					if not fof_count or fof_count < wc then
						fof_count = wc
					end
				end
				if fof_count then
					while i<=4 and fof_count ~= 0 do
						backgrounds[i]:SetTexture(GetSpellTexture(30455))
						cooldowns[i]:SetCooldown(gcd_start, gcd_duration, gcd_enabled, gcd_modRate)
						i = i + 1
						fof_count = fof_count - 1
					end
				end
				local frostbolt_texture = GetSpellTexture(116)
				while i <= 4 do
					backgrounds[i]:SetTexture(frostbolt_texture)
					cooldowns[i]:SetCooldown(gcd_start, gcd_duration, gcd_enabled, gcd_modRate)
					i = i + 1
				end
				for j = 1,#monitor_spells do
					local jmm1 = j+m-1
					Peachpies_GridSpellMinitoring(grid_profile,
					monitor_spells[j],backgrounds[jmm1],center_texts[jmm1],bottom_texts[jmm1],cooldowns[jmm1])
				end
				local t = unit_range("target")
				if t then
					Peachpies_GridCenter(grid_profile,t,10,43,center_text1,"%.0f")
				end
				globalframe:Show()
			else
				globalframe:Hide()
			end
		elseif yd == 0 then
			if GetSpecialization() == 3 then
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
