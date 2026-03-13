include("entities/npc_vj_zss_slow/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- NZR'APL SHAMBLER | Tier 1 Common Seaborn
-- Slow shambling tide-creature. One of the most numerous forms
-- of the Seaborn horde. Bloated with bioluminescent fluid.
-- - Passive poison aura damages nearby players
-- - Death explosion releases a cloud of corrosive ichor
-- - Resistant to poison; vulnerable to fire
-- ============================================================
ENT.Model = {"models/vj_zombies/slow1.mdl","models/vj_zombies/slow3.mdl","models/vj_zombies/slow5.mdl","models/vj_zombies/slow7.mdl"}
ENT.StartHealth = 130
ENT.MeleeAttackDamage = 16
ENT.MeleeAttackBleedEnemy = false
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 70
ENT.GeneralSoundPitch2 = 78
ENT.FootStepTimeRun = 0.6
ENT.FootStepTimeWalk = 0.85
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(40, 180, 160))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_NextAuraTime = CurTime() + 5
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.25) end
	if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(1.4) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 8, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() < self.SB_NextAuraTime then return end
	self.SB_NextAuraTime = CurTime() + 7
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 110)) do
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 5, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	local dmg = DamageInfo()
	dmg:SetInflictor(self) dmg:SetAttacker(self)
	dmg:SetDamageType(DMG_POISON) dmg:SetDamage(30)
	util.BlastDamageInfo(dmg, self:GetPos(), 220)
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 220)) do
		if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 15, self) end
	end
	local e = EffectData() e:SetOrigin(self:GetPos()) e:SetScale(0.8)
	util.Effect("HelicopterMegaBomb", e, true, true)
end

VJ.AddNPC("Nzr'apl Shambler", "npc_vj_horde_sb_nzrapl", "Sea-Infection")
