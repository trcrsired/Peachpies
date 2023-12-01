local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local UnitIsVisible = UnitIsVisible
local InCombatLockdown = InCombatLockdown
local CheckInteractDistance = CheckInteractDistance

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
unit_in_range = function(u)
	local visible = UnitIsVisible(u)
	if not InCombatLockdown() then
		return CheckInteractDistance(u,1),visible
	else
		return UnitInRange(u),visible
	end
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
