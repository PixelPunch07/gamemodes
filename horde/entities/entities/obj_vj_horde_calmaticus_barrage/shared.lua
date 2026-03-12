ENT.Base            = "obj_vj_projectile_base"
ENT.Type            = "anim"
ENT.PrintName       = "Calmaticus Barrage Shot"
ENT.Author          = ""
ENT.Contact         = ""
ENT.Information     = "Calmaticus 25% Phase Barrage Projectile"
ENT.Category        = "Projectiles"

if CLIENT then
    local Name     = "Calmaticus Barrage Shot"
    local LangName = "obj_vj_horde_calmaticus_barrage"
    language.Add(LangName, Name)
    killicon.Add(LangName, "HUD/killicons/default", Color(0, 220, 40, 255))
    language.Add("#" .. LangName, Name)
    killicon.Add("#" .. LangName, "HUD/killicons/default", Color(0, 220, 40, 255))
end
