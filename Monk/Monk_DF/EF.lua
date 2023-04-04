local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local CheckInteractDistance = CheckInteractDistance
local UnitIsVisible = UnitIsVisible

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
unit_in_range = function(u)
	return CheckInteractDistance(u,1),UnitIsVisible(u)
end,
nameinfo = {key="monk_mw_ef",spellid=191837},
caps = 6,
nameplates = true,
constant = 0.5548,
manacost = 7.2,
specialization = 2,
spells = 191837
}
)))
