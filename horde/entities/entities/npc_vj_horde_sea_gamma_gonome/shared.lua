ENT.Base 			= "npc_vj_creature_base"
ENT.Type 			= "ai"
ENT.PrintName 		= "Sea Gamma Gonome"
ENT.Author 			= "HORDE"
ENT.Contact 		= ""
ENT.Purpose 		= "Sea-Infection waveset enemy."
ENT.Instructions 	= "Spawns automatically in Sea-Infection waveset."
ENT.Category		= "Sea-Infection"

if (CLIENT) then
local Name = "Sea Gamma Gonome"
local LangName = "npc_vj_horde_sea_gamma_gonome"
language.Add(LangName, Name)
killicon.Add(LangName, "HUD/killicons/default", Color(30, 140, 255, 255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName, "HUD/killicons/default", Color(30, 140, 255, 255))
end
