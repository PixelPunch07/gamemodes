ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Aegirian Skimmer"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Aegirian Skimmer"
local LangName = "npc_vj_horde_sb_skimmer"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(0, 200, 255, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(0, 200, 255, 255))
end
