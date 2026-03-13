AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/headcrab_poison.mdl",
}
ENT.StartHealth = 80
ENT.HullType = HULL_TINY_CENTERED
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Yellow"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 28
ENT.MeleeAttackDamageDistance = 55
ENT.TimeUntilMeleeAttackDamage = 0.4
ENT.MeleeAttackDamage = 8
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 120
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav"}
ENT.SoundTbl_Idle = {"npc/headcrab_poison/phc_idle1.wav", "npc/headcrab_poison/phc_idle2.wav", "npc/headcrab_poison/phc_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/headcrab_poison/phc_alert1.wav", "npc/headcrab_poison/phc_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/headcrab/headcrab_attack1.wav", "npc/headcrab/headcrab_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/headcrab/headcrab_jump1.wav"}
ENT.SoundTbl_Pain = {"npc/headcrab_poison/phc_pain1.wav", "npc/headcrab_poison/phc_pain2.wav", "npc/headcrab_poison/phc_pain3.wav"}
ENT.SoundTbl_Death = {"npc/headcrab_poison/phc_die1.wav", "npc/headcrab_poison/phc_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self:SetModelScale(1.3, 0)
    self:SetCollisionBounds(Vector(12, 12, 24), Vector(-12, -12, 0))
    self.Sea_PoisonCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if CurTime() > self.Sea_PoisonCooldown then
        self.Sea_PoisonCooldown = CurTime() + 3
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 140)) do
            if ent:IsPlayer() then
                ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 4, self)
            end
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
    local dmg = DamageInfo()
    dmg:SetInflictor(self) dmg:SetAttacker(self)
    dmg:SetDamageType(DMG_POISON) dmg:SetDamage(30)
    util.BlastDamageInfo(dmg, self:GetPos(), 220)
end

VJ.AddNPC("Spore Drifter", "npc_vj_horde_sea_spore_drifter", "Sea-Infection")
