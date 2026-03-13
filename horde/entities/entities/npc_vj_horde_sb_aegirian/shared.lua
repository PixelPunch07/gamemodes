ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Corrupted Aegirian"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Corrupted Aegirian"
local LangName = "npc_vj_horde_sb_aegirian"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(0, 160, 220, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(0, 160, 220, 255))
end
