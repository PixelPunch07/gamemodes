include("entities/npc_vj_zss_hulk/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- ABYSSAL WARDEN | Tier 4 Elite Heavy
-- The armored guardians of the deep. Wardens are enormous
-- Seaborn-assimilated husks encased in layers of living coral
-- and barnacle-plate. They are near-immovable.
-- - Three-phase rage system (75% / 40% HP thresholds)
-- - Ground shockwave AoE when enemy is close
-- - Poison Aura passively ticks damage around it
-- - Heavily resistant to explosion and fire
-- - Phase 3: Nervous Impairment on every melee hit
-- ============================================================
ENT.Model = "models/vj_zombies/hulk.mdl"
ENT.StartHealth = 900
ENT.HullType = HULL_MEDIUM_TALL
ENT.MeleeAttackDamage = 70
ENT.MeleeAttackBleedEnemy = true
ENT.HasMeleeAttackKnockBack = true
ENT.MeleeAttackPlayerSpeed = false
ENT.PropInteraction_MaxScale = 2
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 48
ENT.GeneralSoundPitch2 = 55
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav","npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav","npc/zombie_poison/pz_die2.wav"}
ENT.FootstepSoundLevel = 80
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(20, 20, 95), Vector(-20, -20, 0))
	self:SetColor(Color(20, 80, 180))
	self:SetSkin(math.random(0, 3))
	self:SetModelScale(1.2, 0)
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")

	self.HasWorldShakeOnMove = true
	self.WorldShakeOnMoveAmplitude = 12
	self.WorldShakeOnMoveRadius = 300
	self.WorldShakeOnMoveDuration = 0.4
	self.WorldShakeOnMoveFrequency = 100

	self.SB_Phase = 1
	self.SB_SlamCooldown = 0
	self.SB_NextAuraTime = CurTime() + 5
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.15) end
	if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.4) end
	if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(0.5) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 8, self)
		if self.SB_Phase >= 3 then
			ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 15, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFootstepSound(moveType, sdFile)
	util.ScreenShake(self:GetPos(), 4, 8, 0.5, 300)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(ent)
	return self:GetForward() * math.random(110, 150) + self:GetUp() * math.random(280, 320)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_DoSlam(radius, damage)
	sound.Play("physics/concrete/concrete_impact_hard2.wav", self:GetPos(), 95, 52)
	util.ScreenShake(self:GetPos(), 20, 110, 1.0, radius + 150)
	local e = EffectData() e:SetOrigin(self:GetPos()) e:SetScale(1.2)
	util.Effect("HelicopterMegaBomb", e, true, true)
	local dmg = DamageInfo()
	dmg:SetInflictor(self) dmg:SetAttacker(self)
	dmg:SetDamageType(DMG_CLUB) dmg:SetDamage(damage)
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), radius)) do
		if ent:IsPlayer() then
			ent:TakeDamageInfo(dmg)
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 10, self)
			ent:SetVelocity((ent:GetPos()-self:GetPos()):GetNormal() * 250 + Vector(0,0,200))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	local hp = self:Health()
	local maxHp = self:GetMaxHealth()

	if self.SB_Phase == 1 and hp < maxHp * 0.75 then
		self.SB_Phase = 2
		self:SetColor(Color(0, 60, 220))
		self:EmitSound("npc/zombie_poison/pz_alert1.wav", 500, 55, 1, CHAN_STATIC)
		self:SB_DoSlam(200, 35)
	elseif self.SB_Phase == 2 and hp < maxHp * 0.40 then
		self.SB_Phase = 3
		self:SetColor(Color(0, 30, 255))
		self:EmitSound("npc/zombie_poison/pz_alert2.wav", 500, 48, 1, CHAN_STATIC)
		util.ScreenShake(self:GetPos(), 25, 140, 1.8, 700)
		self:SB_DoSlam(300, 55)
	end

	if self.SB_Phase >= 2 and CurTime() > self.SB_SlamCooldown then
		if IsValid(self:GetEnemy()) and self.EnemyData.Distance < 250 then
			self.SB_SlamCooldown = CurTime() + (self.SB_Phase == 3 and 8 or 14)
			self:SB_DoSlam(220, 40)
		end
	end

	if CurTime() > self.SB_NextAuraTime then
		self.SB_NextAuraTime = CurTime() + 5
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 140)) do
			if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 5, self) end
		end
	end
end

VJ.AddNPC("Abyssal Warden", "npc_vj_horde_sb_warden", "Sea-Infection")
