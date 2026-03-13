AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/vj_zombies/panic_carrier.mdl",
	"models/vj_zombies/panic_eugene.mdl",
	"models/vj_zombies/panic_jessica.mdl",
	"models/vj_zombies/panic_marcus.mdl",
}
ENT.StartHealth = 75
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 32
ENT.MeleeAttackDamageDistance = 85
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 18
ENT.SlowPlayerOnMeleeAttack = true
ENT.SlowPlayerOnMeleeAttack_WalkSpeed = 100
ENT.SlowPlayerOnMeleeAttack_RunSpeed = 100
ENT.SlowPlayerOnMeleeAttackTime = 3
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 60
ENT.GeneralSoundPitch2 = 65
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"vj_zombies/panic/carrier/Zcarrier_Taunt-01.wav", "vj_zombies/panic/carrier/Zcarrier_Taunt-02.wav", "vj_zombies/panic/carrier/Zcarrier_Taunt-03.wav"}
ENT.SoundTbl_Alert = {"vj_zombies/panic/carrier/Carrier_Berserk-01.wav", "vj_zombies/panic/carrier/Carrier_Berserk-02.wav", "vj_zombies/panic/carrier/Carrier_Berserk-03.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_zombies/panic/Z_Hit-01.wav", "vj_zombies/panic/Z_Hit-02.wav", "vj_zombies/panic/Z_Hit-03.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/panic/z-swipe-1.wav", "vj_zombies/panic/z-swipe-2.wav", "vj_zombies/panic/z-swipe-3.wav"}
ENT.SoundTbl_Pain = {"vj_zombies/panic/carrier/Zcarrier_Pain-01.wav", "vj_zombies/panic/carrier/Zcarrier_Pain-02.wav", "vj_zombies/panic/carrier/Zcarrier_Pain-03.wav"}
ENT.SoundTbl_Death = {"vj_zombies/panic/carrier/Zcarrier_Death-01.wav", "vj_zombies/panic/carrier/Zcarrier_Death-02.wav", "vj_zombies/panic/carrier/Zcarrier_Death-03.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end

VJ.AddNPC("Sea Skimmer", "npc_vj_horde_sea_skimmer", "Sea-Infection")
