AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/horde/hulk/hulk.mdl",
}
ENT.StartHealth = 1400
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 95
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 60
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = true
ENT.MeleeAttackKnockBack_Forward1 = 110
ENT.MeleeAttackKnockBack_Forward2 = 140
ENT.MeleeAttackKnockBack_Up1 = 260
ENT.MeleeAttackKnockBack_Up2 = 280
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 55
ENT.GeneralSoundPitch2 = 60
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav", "npc/zombie_poison/pz_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav", "npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav", "vj_zombies/slow/miss3.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav", "npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetCollisionBounds(Vector(18, 18, 90), Vector(-18, -18, 0))
    self:SetSkin(math.random(0,3))
    self.HasWorldShakeOnMove = true
    self.WorldShakeOnMoveAmplitude = 8
    self.WorldShakeOnMoveRadius = 200
    self.WorldShakeOnMoveDuration = 0.4
    self.WorldShakeOnMoveFrequency = 100
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if self.Critical and self:IsOnGround() then
        self:SetLocalVelocity(self:GetMoveVelocity() * 1.4)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if not self.Critical and self:Health() < self:GetMaxHealth() / 2 then
        self.Critical = true
    end
end

VJ.AddNPC("Deep Hulk", "npc_vj_horde_sea_deep_hulk", "Sea-Infection")
