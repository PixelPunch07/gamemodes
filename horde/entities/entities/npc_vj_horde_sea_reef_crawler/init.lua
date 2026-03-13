AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/headcrabclassic.mdl",
}
ENT.StartHealth = 50
ENT.HullType = HULL_TINY_CENTERED
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Yellow"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 24
ENT.MeleeAttackDamageDistance = 50
ENT.TimeUntilMeleeAttackDamage = 0.3
ENT.MeleeAttackDamage = 10
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 90
ENT.GeneralSoundPitch2 = 100
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/headcrab/headcrab_jump1.wav", "npc/headcrab/headcrab_jump2.wav"}
ENT.SoundTbl_Idle = {"npc/headcrab/idle1.wav", "npc/headcrab/idle2.wav", "npc/headcrab/idle3.wav"}
ENT.SoundTbl_Alert = {"npc/headcrab/alert1.wav", "npc/headcrab/alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/headcrab/headcrab_attack1.wav", "npc/headcrab/headcrab_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/headcrab/headcrab_jump1.wav"}
ENT.SoundTbl_Pain = {"npc/headcrab/pain1.wav", "npc/headcrab/pain2.wav", "npc/headcrab/pain3.wav"}
ENT.SoundTbl_Death = {"npc/headcrab/die1.wav", "npc/headcrab/die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetModelScale(1.2, 0)
    self:SetCollisionBounds(Vector(12, 12, 24), Vector(-12, -12, 0))
end

VJ.AddNPC("Reef Crawler", "npc_vj_horde_sea_reef_crawler", "Sea-Infection")
