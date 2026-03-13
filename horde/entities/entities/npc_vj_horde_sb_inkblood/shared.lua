ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Inkblood Spectre"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Inkblood Spectre"
local LangName = "npc_vj_horde_sb_inkblood"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(20, 0, 80, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(20, 0, 80, 255))
end
