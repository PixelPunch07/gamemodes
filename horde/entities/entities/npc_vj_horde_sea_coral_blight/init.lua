AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/classic.mdl",
}
ENT.StartHealth = 650
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 45
ENT.MeleeAttackDamageDistance = 65
ENT.TimeUntilMeleeAttackDamage = 0.8
ENT.MeleeAttackDamage = 32
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 65
ENT.GeneralSoundPitch2 = 70
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav", "npc/zombie/zombie_voice_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav", "npc/zombie/zombie_alert3.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetModelScale(1.4, 0)
    self:SetBodygroup(1,1)
    self.HasGibOnDeath = true
    self.HasDeathRagdoll = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if not (hitgroup == HITGROUP_HEAD or (dmginfo:GetInflictor() and dmginfo:GetInflictor().WasHeadshot)) then
        local e = EffectData()
        e:SetOrigin(self:GetPos())
        util.Effect("blight_mini_explosion", e, true, true)
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 180)) do
            if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Necrosis, 8, self) end
        end
        if HORDE:IsBlastDamage(dmginfo) or HORDE:IsFireDamage(dmginfo) then
            dmginfo:ScaleDamage(1.5)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
    local HordeMelee_HeadshotCheck = dmginfo:GetInflictor().WasHeadshot
    if hitgroup ~= HITGROUP_HEAD and not HordeMelee_HeadshotCheck then
        local e = EffectData()
        e:SetOrigin(self:GetPos())
        util.Effect("blight_explosion", e, true, true)
        local dmg = DamageInfo()
        dmg:SetInflictor(self) dmg:SetAttacker(self)
        dmg:SetDamageType(DMG_DISSOLVE) dmg:SetDamage(55)
        util.BlastDamageInfo(dmg, self:GetPos(), 320)
        sound.Play("vj_base/ambience/acid_splat.wav", self:GetPos())
    end
end

VJ.AddNPC("Coral Blight", "npc_vj_horde_sea_coral_blight", "Sea-Infection")
