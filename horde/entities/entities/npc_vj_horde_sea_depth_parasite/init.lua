AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/fast.mdl",
}
ENT.StartHealth = 60
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 30
ENT.MeleeAttackDamageDistance = 70
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 20
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 110
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/fastzombie/foot1.wav", "npc/fastzombie/foot2.wav", "npc/fastzombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/fastzombie/idle1.wav", "npc/fastzombie/idle2.wav", "npc/fastzombie/idle3.wav"}
ENT.SoundTbl_Alert = {"npc/fastzombie/alert1.wav", "npc/fastzombie/alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/fastzombie/claw_strike1.wav", "npc/fastzombie/claw_strike2.wav", "npc/fastzombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/fastzombie/claw_strike1.wav", "npc/fastzombie/claw_strike2.wav"}
ENT.SoundTbl_Pain = {"npc/fastzombie/pain1.wav", "npc/fastzombie/pain2.wav"}
ENT.SoundTbl_Death = {"npc/fastzombie/die1.wav", "npc/fastzombie/die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    -- Depth Parasite applies poison buildup on hit
    if hitgroup ~= HITGROUP_HEAD then
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 80)) do
            if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 6, self) end
        end
    end
end

VJ.AddNPC("Depth Parasite", "npc_vj_horde_sea_depth_parasite", "Sea-Infection")
