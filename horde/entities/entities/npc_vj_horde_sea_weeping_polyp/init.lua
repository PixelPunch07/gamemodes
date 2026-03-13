AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/classic.mdl",
}
ENT.StartHealth = 400
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 65
ENT.TimeUntilMeleeAttackDamage = 0.8
ENT.MeleeAttackDamage = 22
ENT.SlowPlayerOnMeleeAttack = false
ENT.HasMeleeAttackKnockBack = false
ENT.MeleeAttackBleedEnemy = false
ENT.FootStepTimeRun = 0.5
ENT.FootStepTimeWalk = 0.7
ENT.HasRangeAttack = false
ENT.CanFlinch = 1
ENT.AnimTbl_Flinch = {ACT_FLINCH_PHYSICS}
ENT.GeneralSoundPitch1 = 70
ENT.GeneralSoundPitch2 = 80
-- ====== Sound File Paths ======
ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav", "npc/zombie/zombie_voice_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav", "npc/zombie/zombie_alert3.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self.Sea_ToxicCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    if CurTime() > self.Sea_ToxicCooldown then
        self.Sea_ToxicCooldown = CurTime() + 6
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 220)) do
            if ent:IsPlayer() then
                ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 5, self)
            end
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
    local dmg = DamageInfo()
    dmg:SetInflictor(self) dmg:SetAttacker(self)
    dmg:SetDamageType(DMG_POISON) dmg:SetDamage(25)
    util.BlastDamageInfo(dmg, self:GetPos(), 300)
end

VJ.AddNPC("Weeping Polyp", "npc_vj_horde_sea_weeping_polyp", "Sea-Infection")
