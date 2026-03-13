AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/combine_super_soldier.mdl",
}
ENT.StartHealth = 600
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 36
ENT.MeleeAttackDamageDistance = 80
ENT.TimeUntilMeleeAttackDamage = 0.4
ENT.MeleeAttackDamage = 45
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 90
ENT.GeneralSoundPitch2 = 95
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/combine_soldier/gear1.wav", "npc/combine_soldier/gear2.wav", "npc/combine_soldier/gear3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if HORDE:IsPoisonDamage(dmginfo) then
        dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)
    end
    if HORDE:IsBlastDamage(dmginfo) then
        dmginfo:ScaleDamage(0.8)
    end
end

VJ.AddNPC("Elite Predator", "npc_vj_horde_sea_elite_predator", "Sea-Infection")
