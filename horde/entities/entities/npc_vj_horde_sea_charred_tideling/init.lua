AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = {
	"models/zombie/zombie_soldier.mdl",
}
ENT.StartHealth = 160
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.BloodColor = "Red"
ENT.HasMeleeAttack = true
ENT.MeleeAttackDistance = 32
ENT.MeleeAttackDamageDistance = 65
ENT.TimeUntilMeleeAttackDamage = 0.7
ENT.MeleeAttackDamage = 20
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
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav", "vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetColor(Color(30, 140, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
    self.HasGibOnDeath = false
    self.HasDeathRagdoll = true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(0.4) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
    local e = EffectData()
    e:SetOrigin(self:GetPos())
    util.Effect("horde_blaster_flame_explosion", e, true, true)
    local dmg = DamageInfo()
    dmg:SetInflictor(self) dmg:SetAttacker(self)
    dmg:SetDamageType(DMG_BURN) dmg:SetDamage(40)
    util.BlastDamageInfo(dmg, self:GetPos(), 200)
    sound.Play("ambient/fire/fire_small_01.wav", self:GetPos())
end

VJ.AddNPC("Charred Tideling", "npc_vj_horde_sea_charred_tideling", "Sea-Infection")
