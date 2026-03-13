ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Abyssal Warden"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Abyssal Warden"
local LangName = "npc_vj_horde_sb_warden"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(20, 80, 180, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(20, 80, 180, 255))
end
