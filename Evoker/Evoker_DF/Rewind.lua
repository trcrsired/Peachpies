local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local UnitInRange = UnitInRange
local UnitIsVisible = UnitIsVisible

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
nameinfo = {key="monk_mw_revival",spellid=366155},
unit_in_range = function(u)
	return UnitInRange(u),UnitIsVisible(u)
end,
constant = 2,
spells = 366155,
specialization = 2,
secure = 366155,
raidcooldown2x = true
}
)))
