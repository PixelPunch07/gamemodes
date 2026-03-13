include("entities/npc_vj_zss_slow/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- CORRUPTED AEGIRIAN | Tier 2 Aegirian Infected
-- Once a proud fisherman of Iberia's coastal villages.
-- The Seaborn found them first. Now fully converted, the
-- Aegirian hosts retain a ghost of their former strength
-- while serving as walking bioreactors for the tide.
-- - Periodic wide-range poison aura every 8 seconds
-- - Large death explosion: toxic ichor bursts from the body
-- - Resistant to poison; extra HP from the Aegirian host body
-- - Melee applies stacking Poison buildup
-- ============================================================
ENT.Model = {"models/vj_zombies/slow2.mdl","models/vj_zombies/slow4.mdl","models/vj_zombies/slow6.mdl"}
ENT.StartHealth = 180
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackBleedEnemy = false
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 65
ENT.GeneralSoundPitch2 = 72
ENT.FootStepTimeRun = 0.55
ENT.FootStepTimeWalk = 0.8
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav","npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav","npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(0, 160, 220))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_NextAuraTime = CurTime() + 8
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.2) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 12, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() < self.SB_NextAuraTime then return end
	self.SB_NextAuraTime = CurTime() + 8
	sound.Play("npc/zombie_poison/pz_idle2.wav", self:GetPos(), 65, 58)
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 160)) do
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 8, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	local dmg = DamageInfo()
	dmg:SetInflictor(self) dmg:SetAttacker(self)
	dmg:SetDamageType(DMG_POISON) dmg:SetDamage(45)
	util.BlastDamageInfo(dmg, self:GetPos(), 280)
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 280)) do
		if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 20, self) end
	end
	sound.Play("npc/zombie_poison/pz_die1.wav", self:GetPos(), 85, 70)
	local e = EffectData() e:SetOrigin(self:GetPos()) e:SetScale(1.1)
	util.Effect("HelicopterMegaBomb", e, true, true)
end

VJ.AddNPC("Corrupted Aegirian", "npc_vj_horde_sb_aegirian", "Sea-Infection")
