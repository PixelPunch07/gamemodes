include("entities/npc_vj_zss_boss/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- ISHAR'MLA ECHO | Tier 5 BOSS
-- A physical manifestation of a fraction of Ishar'mla's
-- colossal presence. It cannot be fully destroyed — only
-- this echo of its will can be banished.
-- The Echo coordinates the entire Seaborn assault personally.
--
-- Boss Mechanics:
-- - Periodically spawns 2 Ishar'mla Sprouts (cooldown: 25s)
-- - Three-phase progression: Normal / Awakened / Tide Surge
-- - Phase 2 (<65% HP): increased damage, wider aura, spawns faster
-- - Phase 3 (<35% HP): Tide Surge — massive multi-directional
--   AoE attack that radiates outward in a cross pattern
-- - Constant poison aura (radius scales with phase)
-- - All melee hits apply Poison + Nervous Impairment
-- ============================================================
ENT.Model = "models/vj_zombies/gal_boss.mdl"
ENT.StartHealth = 4500
ENT.MeleeAttackDamage = 90
ENT.MeleeAttackDamageDistance = 90
ENT.MeleeAttackBleedEnemy = true
ENT.HasMeleeAttackKnockBack = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 40
ENT.GeneralSoundPitch2 = 48

local sdFootScuff = {"npc/zombie/foot_slide1.wav","npc/zombie/foot_slide2.wav","npc/zombie/foot_slide3.wav"}
ENT.SB_NextSpawnT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then self:PlayFootstepSound()
	elseif key == "scuff" then self:PlayFootstepSound(sdFootScuff)
	elseif key == "melee" then self.MeleeAttackDamage = 90 self:ExecuteMeleeAttack()
	elseif key == "melee_heavy" then self.MeleeAttackDamage = 110 self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(0, 180, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_Phase = 1
	self.SB_NextSpawnT = CurTime() + 15
	self.SB_NextAuraTime = CurTime() + 3
	self.SB_TideSurgeCooldown = 0
	self.SB_TideSurgeDone = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(0) end
	if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.5) end
	if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(0.6) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 18, self)
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 20, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_SpawnSprouts()
	local myPos = self:GetPos()
	local myAng = self:GetAngles()
	self:PlayAnim("vjseq_releasecrab", true, false, false)
	sound.Play("npc/zombie_poison/pz_call1.wav", myPos, 110, 72)
	local spawnCount = self.SB_Phase >= 2 and 3 or 2
	for i = 1, spawnCount do
		local offset = Vector(math.random(-80, 80), math.random(-80, 80), 20)
		local sprout = ents.Create("npc_vj_horde_sb_isharspawn")
		if IsValid(sprout) then
			sprout:SetPos(myPos + offset)
			sprout:SetAngles(myAng)
			sprout:Spawn()
			sprout:Activate()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_TideSurge()
	if self.SB_TideSurgeDone then return end
	self.SB_TideSurgeDone = true
	self:PlayAnim("big_flinch", true, 5, false)
	sound.Play("npc/zombie_poison/pz_alert2.wav", self:GetPos(), 130, 38)
	util.ScreenShake(self:GetPos(), 30, 180, 2.5, 1200)
	-- Cross-pattern radial AoE
	local function RadialBurst(delay, dir, radius)
		timer.Simple(delay, function()
			if not IsValid(self) then return end
			local pos = self:GetPos() + dir
			local e = EffectData()
				e:SetOrigin(pos)
				e:SetScale(1.0)
			util.Effect("HelicopterMegaBomb", e, true, true)
			local dmg = DamageInfo()
			dmg:SetInflictor(self) dmg:SetAttacker(self)
			dmg:SetDamageType(DMG_BLAST) dmg:SetDamage(50)
			util.BlastDamageInfo(dmg, pos, radius)
			for _, ent in pairs(ents.FindInSphere(pos, radius)) do
				if ent:IsPlayer() then
					ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 20, self)
					ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 18, self)
				end
			end
		end)
	end
	for i = 1, 12 do
		RadialBurst(1.5, self:GetForward() * i * 120, 180)
		RadialBurst(1.5, -self:GetForward() * i * 120, 180)
		RadialBurst(1.5, self:GetRight() * i * 120, 180)
		RadialBurst(1.5, -self:GetRight() * i * 120, 180)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local hp = self:Health()
	local maxHp = self:GetMaxHealth()

	-- Phase transitions
	if self.SB_Phase == 1 and hp < maxHp * 0.65 then
		self.SB_Phase = 2
		self:SetColor(Color(0, 140, 255))
		self.SB_NextSpawnT = 0 -- Trigger immediate spawn
		sound.Play("npc/zombie_poison/pz_alert1.wav", self:GetPos(), 120, 45)
		util.ScreenShake(self:GetPos(), 22, 140, 1.8, 900)
	elseif self.SB_Phase == 2 and hp < maxHp * 0.35 then
		self.SB_Phase = 3
		self:SetColor(Color(0, 80, 255))
		self:SB_TideSurge()
	end

	-- Spawn Sprouts
	local spawnCooldown = self.SB_Phase >= 2 and 18 or 25
	if IsValid(self:GetEnemy()) and CurTime() > self.SB_NextSpawnT and
		not IsValid(self.MiniBoss1) and not IsValid(self.MiniBoss2) then
		self:SB_SpawnSprouts()
		self.SB_NextSpawnT = CurTime() + spawnCooldown
	end

	-- Poison aura
	if CurTime() > self.SB_NextAuraTime then
		self.SB_NextAuraTime = CurTime() + 3
		local auraRadius = self.SB_Phase == 3 and 220 or (self.SB_Phase == 2 and 170 or 130)
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), auraRadius)) do
			if ent:IsPlayer() then
				ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 7, self)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	if not self.Dead then
		if IsValid(self.MiniBoss1) then self.MiniBoss1:Remove() end
		if IsValid(self.MiniBoss2) then self.MiniBoss2:Remove() end
	end
end

VJ.AddNPC("Ishar'mla Echo", "npc_vj_horde_sb_ishar", "Sea-Infection")
