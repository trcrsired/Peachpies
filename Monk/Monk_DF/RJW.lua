local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

local CheckInteractDistance = CheckInteractDistance
local UnitInRange = UnitInRange

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
nameinfo = {key="monk_mw_rjw",spellid=196725},
caps = 6,
ticks = 22.5,
nameplates = true,
constant = 2.777,
manacost = 5,
with_buff = 389684,
pbuff = true,
specialization = 2,
nameplate = true,
spells = 196725
}
)))
