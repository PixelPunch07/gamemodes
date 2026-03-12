AddCSLuaFile("shared.lua")
include("shared.lua")

-- Heavy barrage projectile for Calmaticus 25% phase — applies ACID damage + BLEED buildup
ENT.Model = {"models/vj_base/projectiles/spit_acid_medium.mdl"}

ENT.ShakeWorldOnDeath           = true
ENT.ShakeWorldOnDeathAmplitude  = 6
ENT.ShakeWorldOnDeathRadius     = 500
ENT.ShakeWorldOnDeathDuration   = 0.7
ENT.ShakeWorldOnDeathFrequency  = 200

ENT.DoesRadiusDamage            = false
ENT.RadiusDamageRadius          = 220
ENT.RadiusDamage                = 65
ENT.RadiusDamageType            = DMG_ACID
ENT.RadiusDamageForce           = 200

ENT.DecalTbl_DeathDecals        = {"VJ_AcidSlime1"}
ENT.SoundTbl_Idle               = {"vj_base/ambience/acid_idle.wav"}
ENT.SoundTbl_OnCollide          = {"horde/gonome/gonome_melee2.ogg"}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomPhysicsObjectOnInitialize(phys)
    phys:Wake()
    phys:SetBuoyancyRatio(0)
    phys:EnableDrag(false)
    phys:EnableGravity(true)   -- arc downward under gravity
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
    self:SetColor(Color(0, 230, 30, 220))
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ParticleEffectAttach("vj_acid_idle", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data, phys)
    local effectdata = EffectData()
    effectdata:SetOrigin(data.HitPos)
    effectdata:SetScale(1.3)
    util.Effect("calmaticus_blast", effectdata, true, true)
    sound.Play("horde/gonome/gonome_pain1.ogg", data.HitPos, 80, math.random(80, 100))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPhysicsCollide(data, phys)
    if self.Dead then return end
    self.Dead = true

    local pos = self:GetPos()
    local attacker = IsValid(self.Owner) and self.Owner or self

    -- Acid radius damage
    local dmg = DamageInfo()
    dmg:SetAttacker(attacker)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_ACID)
    dmg:SetDamage(self.RadiusDamage)
    util.BlastDamageInfo(dmg, pos, self.RadiusDamageRadius)

    -- Apply heavy BLEED buildup to all players in blast radius
    for _, ent in pairs(ents.FindInSphere(pos, self.RadiusDamageRadius)) do
        if ent:IsPlayer() then
            ent:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 8, attacker)
        end
    end

    self:Remove()
end
