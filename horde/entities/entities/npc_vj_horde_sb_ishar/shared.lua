ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Ishar'mla Echo"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Ishar'mla Echo"
local LangName = "npc_vj_horde_sb_ishar"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(0, 180, 255, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(0, 180, 255, 255))
end
