local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
nameinfo = {key="monk_mw_rem",spellid=115151},
nameinfobar = {key="monk_mw_rem",spellid=116670},
nameplates = true,
constant = 1.241968,
spells = 115151,
with_buff = 119611,
specialization = 2,
effective_duration = 30,
effective_green_number = 12,
effective_blue_number = 15,
}
)))
