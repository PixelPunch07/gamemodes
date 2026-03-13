AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/fast.mdl",
}
ENT.StartHealth = 140
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 32
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = 0.3
ENT.MeleeAttackDamage = 35
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 0
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 110
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/fastzombie/foot1.wav", "npc/fastzombie/foot2.wav"}
ENT.SoundTbl_Idle = {"npc/fastzombie/idle1.wav", "npc/fastzombie/idle2.wav", "npc/fastzombie/idle3.wav"}
ENT.SoundTbl_Alert = {"npc/fastzombie/alert1.wav", "npc/fastzombie/alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/fastzombie/claw_strike1.wav", "npc/fastzombie/claw_strike2.wav", "npc/fastzombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/fastzombie/claw_strike1.wav"}
ENT.SoundTbl_Pain = {"npc/fastzombie/pain1.wav", "npc/fastzombie/pain2.wav"}
ENT.SoundTbl_Death = {"npc/fastzombie/die1.wav", "npc/fastzombie/die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self.Sea_StealthCooldown = 0
    self.Sea_IsStealthed = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    local hasEnemy = IsValid(self:GetEnemy())
    if not hasEnemy and not self.Sea_IsStealthed and CurTime() > self.Sea_StealthCooldown then
        self.Sea_IsStealthed = true
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetColor(Color(30, 140, 255, 60))
    elseif hasEnemy and self.Sea_IsStealthed then
        self.Sea_IsStealthed = false
        self.Sea_StealthCooldown = CurTime() + 8
        self:SetRenderMode(RENDERMODE_NORMAL)
        self:SetColor(Color(30, 140, 255))
    end
end

VJ.AddNPC("Abyssal Shade", "npc_vj_horde_sea_abyssal_shade", "Sea-Infection")
