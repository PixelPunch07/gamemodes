AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/classic.mdl",
}
ENT.StartHealth = 110
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 32
ENT.MeleeAttackDamageDistance = 65
ENT.TimeUntilMeleeAttackDamage = 0.7
ENT.MeleeAttackDamage = 15
ENT.SlowPlayerOnMeleeAttack = false
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
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav", "npc/zombie_poison/pz_idle3.wav", "npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav", "npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav", "vj_zombies/slow/miss3.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav", "npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self.Sea_ScreamCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if CurTime() > self.Sea_ScreamCooldown and IsValid(self:GetEnemy()) and self:GetEnemy():IsPlayer() then
        self.Sea_ScreamCooldown = CurTime() + 12
        self:EmitSound("npc/zombie_poison/pz_alert1.wav", 400, 80, 1, CHAN_STATIC)
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 350)) do
            if ent:IsPlayer() then
                ent:Horde_AddDebuffBuildup(HORDE.Status_Hinder, 10, self)
            end
        end
    end
end

VJ.AddNPC("Pressure Screamer", "npc_vj_horde_sea_pressure_screamer", "Sea-Infection")
