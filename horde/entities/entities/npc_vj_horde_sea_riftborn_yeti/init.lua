AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/horde/hulk/hulk.mdl",
}
ENT.StartHealth = 1100
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 38
ENT.MeleeAttackDamageDistance = 90
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 50
ENT.SlowPlayerOnMeleeAttack = true
ENT.SlowPlayerOnMeleeAttack_WalkSpeed = 80
ENT.SlowPlayerOnMeleeAttack_RunSpeed = 80
ENT.SlowPlayerOnMeleeAttackTime = 5
ENT.HasMeleeAttackKnockBack = true
ENT.MeleeAttackKnockBack_Forward1 = 90
ENT.MeleeAttackKnockBack_Forward2 = 120
ENT.MeleeAttackKnockBack_Up1 = 200
ENT.MeleeAttackKnockBack_Up2 = 230
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 50
ENT.GeneralSoundPitch2 = 55
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav", "npc/zombie_poison/pz_idle3.wav", "npc/zombie_poison/pz_idle4.wav"}
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
    self.HasWorldShakeOnMove = true
    self.WorldShakeOnMoveAmplitude = 6
    self.WorldShakeOnMoveRadius = 180
    self.WorldShakeOnMoveDuration = 0.4
    self.WorldShakeOnMoveFrequency = 100
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    -- Apply frostbite on melee hit
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), 100)) do
        if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Frostbite, 12, self) end
    end
end

VJ.AddNPC("Riftborn Yeti", "npc_vj_horde_sea_riftborn_yeti", "Sea-Infection")
