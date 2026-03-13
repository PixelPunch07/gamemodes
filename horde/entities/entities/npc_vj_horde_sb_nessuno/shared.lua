ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Nessuno Thrall"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Nessuno Thrall"
local LangName = "npc_vj_horde_sb_nessuno"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(0, 120, 180, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(0, 120, 180, 255))
end
