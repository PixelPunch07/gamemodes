ENT.Base			= "npc_vj_creature_base"
ENT.Type			= "ai"
ENT.PrintName		= "Nzr'apl Shambler"
ENT.Author			= "HORDE"
ENT.Contact			= ""
ENT.Purpose			= "Sea-Infection waveset enemy."
ENT.Instructions	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Nzr'apl Shambler"
local LangName = "npc_vj_horde_sb_nzrapl"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(40, 180, 160, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(40, 180, 160, 255))
end
