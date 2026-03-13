AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/classic.mdl",
}
ENT.StartHealth = 950
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 70
ENT.TimeUntilMeleeAttackDamage = 0.6
ENT.MeleeAttackDamage = 38
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
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
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav", "npc/zombie_poison/pz_idle3.wav", "npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav", "npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetModelScale(1.2, 0)
    self:SetBodygroup(1,1)
    self.Sea_CallCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if CurTime() > self.Sea_CallCooldown and IsValid(self:GetEnemy()) then
        self.Sea_CallCooldown = CurTime() + 18
        self:EmitSound("npc/zombie_poison/pz_call1.wav", 500, 75, 1, CHAN_STATIC)
        -- Heal nearby sea allies slightly
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 400)) do
            if IsValid(ent) and ent:IsNPC() and ent:Health() > 0 and ent:Health() < ent:GetMaxHealth() then
                local npcClass = ent.VJ_NPC_Class
                if npcClass and table.HasValue(npcClass, "CLASS_ZOMBIE") then
                    ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 80))
                end
            end
        end
    end
end

VJ.AddNPC("Sea Herald", "npc_vj_horde_sea_herald", "Sea-Infection")
