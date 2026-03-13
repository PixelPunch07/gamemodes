AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/gonome.mdl",
}
ENT.StartHealth = 1200
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Yellow"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 42
ENT.MeleeAttackDamageDistance = 85
ENT.TimeUntilMeleeAttackDamage = 0.5
ENT.MeleeAttackDamage = 55
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = true
ENT.MeleeAttackKnockBack_Forward1 = 100
ENT.MeleeAttackKnockBack_Forward2 = 130
ENT.MeleeAttackKnockBack_Up1 = 220
ENT.MeleeAttackKnockBack_Up2 = 250
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = true
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_vomitter_projectile"
ENT.RangeDistance = 850
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 65
ENT.GeneralSoundPitch2 = 70
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/gonome/gonome_idle1.wav", "npc/gonome/gonome_idle2.wav", "npc/gonome/gonome_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/gonome/gonome_alert1.wav", "npc/gonome/gonome_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/gonome/gonome_melee1.wav", "npc/gonome/gonome_melee2.wav", "npc/gonome/gonome_melee3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/gonome/gonome_pain1.wav", "npc/gonome/gonome_pain2.wav", "npc/gonome/gonome_pain3.wav"}
ENT.SoundTbl_Death = {"npc/gonome/gonome_die1.wav", "npc/gonome/gonome_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetModelScale(1.3, 0)
    self.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1}
    self.RangeUseAttachmentForPos = true
    self.RangeUseAttachmentForPosID = "mouth"
    self.TimeUntilRangeAttackProjectileRelease = 0.6
    self.NextRangeAttackTime = 9
    self.RangeToMeleeDistance = 240
    self:SetCollisionBounds(Vector(20, 20, 95), Vector(-20, -20, 0))
end

VJ.AddNPC("Sea Gamma Gonome", "npc_vj_horde_sea_gamma_gonome", "Sea-Infection")
