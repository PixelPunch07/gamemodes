AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/gonome.mdl",
}
ENT.StartHealth = 700
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Yellow"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 38
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = 0.5
ENT.MeleeAttackDamage = 40
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = true
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_vomitter_projectile"
ENT.RangeDistance = 750
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 80
ENT.GeneralSoundPitch2 = 85
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
    self.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1}
    self.RangeUseAttachmentForPos = true
    self.RangeUseAttachmentForPosID = "mouth"
    self.TimeUntilRangeAttackProjectileRelease = 0.6
    self.NextRangeAttackTime = 10
    self.RangeToMeleeDistance = 220
end

VJ.AddNPC("Sea Alpha Gonome", "npc_vj_horde_sea_alpha_gonome", "Sea-Infection")
