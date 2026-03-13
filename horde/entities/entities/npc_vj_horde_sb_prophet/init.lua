include("entities/npc_vj_zss_hulk/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- DEEP PROPHET | Tier 5 Apex Unit
-- An ancient Seaborn entity that has achieved a form of
-- singular intelligence. It directs lesser Seaborn like a
-- conductor, and attacks with terrifying precision.
-- - Ranged: fires a coral spike volley (5 projectiles spread)
-- - Melee: massive damage + knockback + Nervous Impairment
-- - Ground slam at close range (devastating AoE)
-- - On reaching 50% HP: enters Prophecy mode — emits a
--   continuous low-range aura that applies ALL debuffs
-- - Resistant to all damage types; vulnerable only to nothing
-- ============================================================
ENT.Model = "models/vj_zombies/hulk.mdl"
ENT.StartHealth = 1600
ENT.HullType = HULL_MEDIUM_TALL
ENT.MeleeAttackDamage = 80
ENT.MeleeAttackBleedEnemy = true
ENT.HasMeleeAttackKnockBack = true
ENT.PropInteraction_MaxScale = 2
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 42
ENT.GeneralSoundPitch2 = 50
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav","npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav","npc/zombie_poison/pz_die2.wav"}
ENT.FootstepSoundLevel = 85

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1}
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_vomitter_projectile"
ENT.RangeDistance = 1400
ENT.RangeToMeleeDistance = 180
ENT.TimeUntilRangeAttackProjectileRelease = 1.0
ENT.NextRangeAttackTime = 10
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(22, 22, 100), Vector(-22, -22, 0))
	self:SetColor(Color(0, 100, 255))
	self:SetSkin(0)
	self:SetModelScale(1.3, 0)
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")

	self.HasWorldShakeOnMove = true
	self.WorldShakeOnMoveAmplitude = 14
	self.WorldShakeOnMoveRadius = 350
	self.WorldShakeOnMoveDuration = 0.5
	self.WorldShakeOnMoveFrequency = 100

	self.SB_ProphecyMode = false
	self.SB_SlamCooldown = 0
	self.SB_NextAuraTime = CurTime() + 4
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.1) end
	if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.55) end
	if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(0.6) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 12, self)
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 16, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(ent)
	return self:GetForward() * math.random(140, 180) + self:GetUp() * math.random(300, 360)
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- Fire 5-projectile coral spike barrage
function ENT:CustomRangeAttackCode_BeforeProjectileSpawn(projectile)
	for i = 1, 4 do
		local spike = ents.Create(self.RangeAttackEntityToSpawn)
		if not IsValid(spike) then continue end
		local ene = self:GetEnemy()
		if not IsValid(ene) then continue end
		local spread = Vector(math.random(-120,120), math.random(-120,120), math.random(10,70))
		local target = ene:GetPos() + spread
		spike:SetPos(self:GetPos() + self:GetUp() * 70)
		spike:SetAngles((target - spike:GetPos()):Angle())
		spike:SetOwner(self)
		spike:SetPhysicsAttacker(self)
		spike:Spawn() spike:Activate()
		local phys = spike:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity((target - spike:GetPos()) * 1.9)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	-- Enter Prophecy mode at 50% HP
	if not self.SB_ProphecyMode and self:Health() < self:GetMaxHealth() * 0.5 then
		self.SB_ProphecyMode = true
		self:SetColor(Color(0, 60, 255))
		sound.Play("npc/zombie_poison/pz_alert2.wav", self:GetPos(), 120, 42)
		util.ScreenShake(self:GetPos(), 28, 160, 2.0, 800)
	end

	-- Ground slam
	if CurTime() > self.SB_SlamCooldown then
		if IsValid(self:GetEnemy()) and self.EnemyData.Distance < 280 then
			self.SB_SlamCooldown = CurTime() + 10
			sound.Play("physics/concrete/concrete_impact_hard2.wav", self:GetPos(), 100, 48)
			util.ScreenShake(self:GetPos(), 24, 130, 1.2, 500)
			local e = EffectData() e:SetOrigin(self:GetPos()) e:SetScale(1.4)
			util.Effect("HelicopterMegaBomb", e, true, true)
			local dmg = DamageInfo()
			dmg:SetInflictor(self) dmg:SetAttacker(self)
			dmg:SetDamageType(DMG_CLUB) dmg:SetDamage(55)
			for _, ent in pairs(ents.FindInSphere(self:GetPos(), 300)) do
				if ent:IsPlayer() then
					ent:TakeDamageInfo(dmg)
					ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 14, self)
					ent:SetVelocity((ent:GetPos()-self:GetPos()):GetNormal() * 280 + Vector(0,0,220))
				end
			end
		end
	end

	-- Prophecy aura: continuous multi-debuff
	if self.SB_ProphecyMode and CurTime() > self.SB_NextAuraTime then
		self.SB_NextAuraTime = CurTime() + 4
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 180)) do
			if ent:IsPlayer() then
				ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 6, self)
				ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 6, self)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFootstepSound(moveType, sdFile)
	util.ScreenShake(self:GetPos(), 5, 10, 0.5, 320)
end

VJ.AddNPC("Deep Prophet", "npc_vj_horde_sb_prophet", "Sea-Infection")
