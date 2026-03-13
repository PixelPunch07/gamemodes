ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Tide Lurker"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Tide Lurker"
local LangName = "npc_vj_horde_sb_lurker"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(20, 60, 140, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(20, 60, 140, 255))
end
