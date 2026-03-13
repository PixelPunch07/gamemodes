AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/torso.mdl",
}
ENT.StartHealth = 55
ENT.HullType = HULL_SMALL_CENTERED
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 28
ENT.MeleeAttackDamageDistance = 55
ENT.TimeUntilMeleeAttackDamage = 0.5
ENT.MeleeAttackDamage = 12
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 80
ENT.GeneralSoundPitch2 = 90
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav"}
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav", "npc/zombie/zombie_voice_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(1.5) end
end

VJ.AddNPC("Sea Torso Crawler", "npc_vj_horde_sea_torso_crawler", "Sea-Infection")
