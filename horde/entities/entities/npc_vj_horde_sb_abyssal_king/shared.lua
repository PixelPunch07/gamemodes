ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Skadi the Corrupted"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Skadi the Corrupted"
local LangName = "npc_vj_horde_sb_abyssal_king"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(20, 0, 120, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(20, 0, 120, 255))
end
