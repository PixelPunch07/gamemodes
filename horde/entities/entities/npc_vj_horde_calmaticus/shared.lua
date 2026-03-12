ENT.Base            = "npc_vj_creature_base"
ENT.Type            = "ai"
ENT.PrintName       = "Calmaticus"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Purpose         = "Horde Boss"
ENT.Instructions    = "Don't change anything."
ENT.Category        = "Zombies"

if CLIENT then
    local Name    = "Calmaticus"
    local LangName = "npc_vj_horde_calmaticus"
    language.Add(LangName, Name)
    killicon.Add(LangName,  "HUD/killicons/default", Color(0, 200, 40, 255))
    language.Add("#" .. LangName, Name)
    killicon.Add("#" .. LangName, "HUD/killicons/default", Color(0, 200, 40, 255))
end
