local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local CheckInteractDistance = CheckInteractDistance
local UnitInRange = UnitInRange

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
unit_in_range = function(u)
	return CheckInteractDistance(u,3) and UnitInRange(u)
end,
nameinfo = {key="monk_mw_rjw",spellid=196725},
caps = 6,
ticks = 22.5,
nameplates = true,
constant = 2.777,
manacost = 5,
specialization = 2,
spells = 196725
}
)))
