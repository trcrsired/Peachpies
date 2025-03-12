local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local UnitInRange = UnitInRange
local UnitIsVisible = UnitIsVisible

local GetSpellInfo = GetSpellInfo
local revival_name, restoral_name
if GetSpellInfo then
	revival_name = GetSpellInfo(115310)
	restoral_name = GetSpellInfo(388615)
else
	local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
	revival_name = C_Spell_GetSpellInfo(115310).name
	restoral_name = C_Spell_GetSpellInfo(388615).name
end

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
nameinfo = {key="monk_mw_revival",spellid=115310},
unit_in_range = function(u)
	return UnitInRange(u),UnitIsVisible(u)
end,
constant = 3.2545*1.08,
spells = {115310,388615},
specialization = 2,
raidcooldown2x = true,
hide_on_cooldown = 8,
secure = table.concat({
	"/use [known:115310] ",
	GetSpellInfo(115310),
	";[known:388615] ",
	GetSpellInfo(388615),nil}),
}
)))
