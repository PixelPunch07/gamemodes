include("entities/npc_vj_zss_slow/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- SEABORN REVENANT | Tier 4 Revival Enemy
-- An ancient Seaborn entity whose bio-core is so saturated
-- with tidal energy that death itself cannot end it — at least
-- not immediately. Its first death triggers a violent rebirth.
-- - Revives ONCE with 60% HP restored on first death
-- - Post-revival: empowered form — increased speed, damage
--   and bleeds enemies on every melee hit
-- - Post-revival: bioluminescent purple glow, clearly distinct
-- - Post-revival: charges toward target when far away
-- - Death scream on revival that applies Nervous Impairment
-- ============================================================
ENT.Model = {"models/vj_zombies/slow11.mdl","models/vj_zombies/slow12.mdl"}
ENT.StartHealth = 200
ENT.MeleeAttackDamage = 18
ENT.MeleeAttackBleedEnemy = false
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 72
ENT.GeneralSoundPitch2 = 80
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav","npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav","npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(180, 0, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_Revived = false
	self.SB_ChargeCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.25) end

	-- First "death" interception: revive instead of dying
	if not self.SB_Revived and (self:Health() - dmginfo:GetDamage()) <= 0 then
		dmginfo:SetDamage(self:Health() - 1) -- Reduce to 1 HP instead of killing
		self.SB_Revived = true
		self:SB_DoRevive()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_DoRevive()
	-- Restore HP
	local newHP = math.floor(self:GetMaxHealth() * 0.60)
	self:SetHealth(newHP)
	-- Empower the form
	self.MeleeAttackDamage = self.MeleeAttackDamage * 1.6
	self.MeleeAttackBleedEnemy = true
	-- Visually transform
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(220, 0, 255, 200))
	-- Revival scream effect
	sound.Play("npc/zombie_poison/pz_alert1.wav", self:GetPos(), 110, 55)
	util.ScreenShake(self:GetPos(), 14, 80, 0.8, 450)
	local e = EffectData()
		e:SetOrigin(self:GetPos())
		e:SetScale(0.9)
	util.Effect("HelicopterMegaBomb", e, true, true)
	-- Screech: nervous impairment on all nearby players
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 380)) do
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 18, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		if self.SB_Revived then
			ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 10, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if not self.SB_Revived then return end
	if not IsValid(self:GetEnemy()) then return end
	if CurTime() < self.SB_ChargeCooldown then return end
	local dist = self.EnemyData and self.EnemyData.Distance or 9999
	if dist > 400 then
		self.SB_ChargeCooldown = CurTime() + 4
		self:SetLocalVelocity((self:GetEnemy():GetPos() - self:GetPos()):GetNormal() * 360)
	end
end

VJ.AddNPC("Seaborn Revenant", "npc_vj_horde_sb_revenant", "Sea-Infection")
