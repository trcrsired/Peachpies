local Peachpies = LibStub("AceAddon-3.0"):GetAddon("Peachpies")

Peachpies.AddCoroutine(coroutine.create(Peachpies.create_range_healing_spell_coroutine(
{
nameinfo = {key="priest_disc_atonement",spellid=194509},
auraonly = true,
nameplates = true,
spells = 194509,
with_buff = 194384,
specialization = 1,
effective_duration = 30,
effective_green_number = 12,
effective_blue_number = 15,
}
)))
