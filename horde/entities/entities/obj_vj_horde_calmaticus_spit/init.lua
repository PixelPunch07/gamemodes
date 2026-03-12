AddCSLuaFile("shared.lua")
include("shared.lua")

-- Standard ranged spit for Calmaticus — applies BLEED on hit, green visuals
ENT.Model = {"models/vj_base/projectiles/spit_acid_medium.mdl"}

ENT.ShakeWorldOnDeath           = true
ENT.ShakeWorldOnDeathAmplitude  = 5
ENT.ShakeWorldOnDeathRadius     = 400
ENT.ShakeWorldOnDeathDuration   = 0.8
ENT.ShakeWorldOnDeathFrequency  = 200

ENT.DoesRadiusDamage            = false
ENT.RadiusDamageRadius          = 200
ENT.RadiusDamage                = 40
ENT.RadiusDamageType            = DMG_REMOVENORAGDOLL
ENT.RadiusDamageForce           = 150

ENT.DecalTbl_DeathDecals        = {"VJ_AcidSlime1"}
ENT.SoundTbl_Idle               = {"vj_base/ambience/acid_idle.wav"}
ENT.SoundTbl_OnCollide          = {"horde/gonome/gonome_melee1.ogg"}

---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomPhysicsObjectOnInitialize(phys)
    phys:Wake()
    phys:SetBuoyancyRatio(0)
    phys:EnableDrag(false)
    phys:EnableGravity(true)   -- arc downward under gravity
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
    self:SetColor(Color(0, 180, 40, 255))
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ParticleEffectAttach("vj_acid_idle", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data, phys)
    local effectdata = EffectData()
    effectdata:SetOrigin(data.HitPos)
    effectdata:SetScale(1)
    util.Effect("calmaticus_blast", effectdata, true, true)
    sound.Play("horde/gonome/gonome_jumpattack.ogg", data.HitPos, 75, math.random(85, 100))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPhysicsCollide(data, phys)
    if self.Dead then return end
    self.Dead = true

    local pos = self:GetPos()
    local attacker = IsValid(self.Owner) and self.Owner or self

    -- Radius damage
    local dmg = DamageInfo()
    dmg:SetAttacker(attacker)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_REMOVENORAGDOLL)
    dmg:SetDamage(self.RadiusDamage)
    util.BlastDamageInfo(dmg, pos, self.RadiusDamageRadius)

    -- Apply BLEED to all players in radius
    for _, ent in pairs(ents.FindInSphere(pos, self.RadiusDamageRadius)) do
        if ent:IsPlayer() then
            ent:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 5, attacker)
        end
    end

    self:Remove()
end
