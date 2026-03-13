ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Seaborn Revenant"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Seaborn Revenant"
local LangName = "npc_vj_horde_sb_revenant"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(180, 0, 255, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(180, 0, 255, 255))
end
