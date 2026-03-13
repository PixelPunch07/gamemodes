AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/classic.mdl",
}
ENT.StartHealth = 2000
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 100
ENT.TimeUntilMeleeAttackDamage = 1.0
ENT.MeleeAttackDamage = 75
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = true
ENT.MeleeAttackKnockBack_Forward1 = 140
ENT.MeleeAttackKnockBack_Forward2 = 170
ENT.MeleeAttackKnockBack_Up1 = 290
ENT.MeleeAttackKnockBack_Up2 = 320
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 45
ENT.GeneralSoundPitch2 = 50
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav", "npc/zombie_poison/pz_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav", "npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetModelScale(1.6, 0)
    self:SetBodygroup(1,1)
    self:SetCollisionBounds(Vector(24, 24, 110), Vector(-24, -24, 0))
    self.HasWorldShakeOnMove = true
    self.WorldShakeOnMoveAmplitude = 12
    self.WorldShakeOnMoveRadius = 300
    self.WorldShakeOnMoveDuration = 0.5
    self.WorldShakeOnMoveFrequency = 100
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    -- Barnacle shell: highly resistant to all damage types
    if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.5) end
    if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(0.6) end
end

VJ.AddNPC("Barnacle Golem", "npc_vj_horde_sea_barnacle_golem", "Sea-Infection")
