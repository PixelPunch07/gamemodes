ENT.Base            = "obj_vj_projectile_base"
ENT.Type            = "anim"
ENT.PrintName       = "Calmaticus Spit"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Information     = "Calmaticus Boss Projectile"
ENT.Category        = "Projectiles"

if CLIENT then
    local Name     = "Calmaticus Spit"
    local LangName = "obj_vj_horde_calmaticus_spit"
    language.Add(LangName, Name)
    killicon.Add(LangName, "HUD/killicons/default", Color(0, 200, 40, 255))
    language.Add("#" .. LangName, Name)
    killicon.Add("#" .. LangName, "HUD/killicons/default", Color(0, 200, 40, 255))
end
