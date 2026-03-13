AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/horde/bloodsquid/bloodsquid.mdl",
}
ENT.StartHealth = 130
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 40
ENT.MeleeAttackDamageDistance = 85
ENT.TimeUntilMeleeAttackDamage = 0.8
ENT.MeleeAttackDamage = 28
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = true
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_vomitter_projectile"
ENT.RangeDistance = 900
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 85
ENT.GeneralSoundPitch2 = 90
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"horde/bloodsquid/bc_attackgrowl1.ogg", "horde/bloodsquid/bc_attackgrowl2.ogg"}
ENT.SoundTbl_Alert = {"horde/bloodsquid/bc_attackgrowl1.ogg", "horde/bloodsquid/bc_attackgrowl2.ogg", "horde/bloodsquid/bc_attackgrowl3.ogg"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"horde/bloodsquid/bc_pain1.ogg", "horde/bloodsquid/bc_pain2.ogg", "horde/bloodsquid/bc_pain3.ogg"}
ENT.SoundTbl_Death = {"horde/bloodsquid/bc_die1.ogg", "horde/bloodsquid/bc_die2.ogg"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self.AnimTbl_RangeAttack = {"range"}
    self.RangeUseAttachmentForPos = true
    self.RangeUseAttachmentForPosID = "attach_mouth"
    self.TimeUntilRangeAttackProjectileRelease = 0.5
    self.NextRangeAttackTime = 8
    self.AnimTbl_Walk = {ACT_WALK}
    self.AnimTbl_Run = {ACT_WALK}
end

VJ.AddNPC("Vomit Eel", "npc_vj_horde_sea_vomit_eel", "Sea-Infection")
