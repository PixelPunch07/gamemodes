include("entities/npc_vj_zss_boss/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- SKADI THE CORRUPTED | SUPREME BOSS - Tier 6
-- "The water doesn't drown you. It loves you too much to let go."
--
-- In the world of Terra, Skadi was once an operator of Rhodes
-- Island. But the Seaborn that had long dwelt within her have
-- finally consumed what remained. This is not Skadi anymore.
-- This is the Corrupting Heart given a champion's body.
--
-- FOUR PHASES:
-- Phase 1 (100-75%): "Awakening" — standard combat, aura, summons
-- Phase 2 (75-50%): "Tide Rising" — enraged, wider AoE, faster summons
-- Phase 3 (50-25%): "The Deep Calls" — adds ranged spike barrages +
--   a massive cross-pattern Tide Surge attack every 30 seconds
-- Phase 4 (<25%): "Convergence" — near-invincible, all abilities
--   simultaneously active, screen shakes constantly, applies
--   every debuff simultaneously on every hit, spawns continuously
--
-- SUMMONS: Ishar'mla Sprouts + Abyssal Heralds
-- DEBUFFS: ALL (Poison, Nervous, Slow simultaneously)
-- AURA: Permanent — radius scales with phase
-- ============================================================
ENT.Model = "models/vj_zombies/gal_boss.mdl"
ENT.StartHealth = 10000
ENT.MeleeAttackDamage = 110
ENT.MeleeAttackDamageDistance = 100
ENT.MeleeAttackBleedEnemy = true
ENT.HasMeleeAttackKnockBack = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 38
ENT.GeneralSoundPitch2 = 45

local sdFootScuff = {"npc/zombie/foot_slide1.wav","npc/zombie/foot_slide2.wav","npc/zombie/foot_slide3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then self:PlayFootstepSound()
	elseif key == "scuff" then self:PlayFootstepSound(sdFootScuff)
	elseif key == "melee" then self.MeleeAttackDamage = 110 self:ExecuteMeleeAttack()
	elseif key == "melee_heavy" then self.MeleeAttackDamage = 135 self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(20, 0, 120, 240))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self:SetModelScale(1.2, 0)

	self.SB_Phase = 1
	self.SB_SpawnCooldown = CurTime() + 20
	self.SB_NextAuraTime = CurTime() + 2
	self.SB_SurgeCooldown = 0
	self.SB_RangeCooldown = 0
	self.SB_ShakeCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(0) end
	if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.45) end
	if HORDE:IsFireDamage(dmginfo) then dmginfo:ScaleDamage(0.5) end
	-- Phase 4 damage reduction
	if self.SB_Phase >= 4 then dmginfo:ScaleDamage(0.5) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 20, self)
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 22, self)
		ene:ViewPunch(Angle(math.random(-12,12), math.random(-12,12), math.random(-8,8)))
		util.ScreenShake(self:GetPos(), 12, 80, 0.6, 400)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_DoRangeBarrage()
	if not IsValid(self:GetEnemy()) then return end
	local ene = self:GetEnemy()
	sound.Play("npc/zombie_poison/pz_warn2.wav", self:GetPos(), 100, 58)
	for i = 1, 6 do
		timer.Simple(i * 0.12, function()
			if not IsValid(self) or not IsValid(ene) then return end
			local proj = ents.Create("obj_vj_horde_vomitter_projectile")
			if not IsValid(proj) then return end
			local spread = Vector(math.random(-150,150), math.random(-150,150), math.random(20,80))
			local target = ene:GetPos() + spread
			proj:SetPos(self:GetPos() + self:GetUp() * 80)
			proj:SetAngles((target - proj:GetPos()):Angle())
			proj:SetOwner(self)
			proj:SetPhysicsAttacker(self)
			proj:Spawn() proj:Activate()
			local phys = proj:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:SetVelocity((target - proj:GetPos()) * 2.0)
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_TideSurge()
	self:PlayAnim("big_flinch", true, 6, false)
	sound.Play("npc/zombie_poison/pz_alert2.wav", self:GetPos(), 140, 35)
	util.ScreenShake(self:GetPos(), 35, 200, 3.0, 1500)
	local function Burst(delay, dir)
		timer.Simple(delay, function()
			if not IsValid(self) then return end
			local pos = self:GetPos() + dir
			local e = EffectData() e:SetOrigin(pos) e:SetScale(1.0)
			util.Effect("HelicopterMegaBomb", e, true, true)
			local dmg = DamageInfo()
			dmg:SetInflictor(self) dmg:SetAttacker(self)
			dmg:SetDamageType(DMG_BLAST) dmg:SetDamage(60)
			util.BlastDamageInfo(dmg, pos, 200)
			for _, ent in pairs(ents.FindInSphere(pos, 200)) do
				if ent:IsPlayer() then
					ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 22, self)
					ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 20, self)
				end
			end
		end)
	end
	-- 8-directional expanding surge
	local dirs = {
		self:GetForward(), -self:GetForward(),
		self:GetRight(), -self:GetRight(),
		(self:GetForward()+self:GetRight()):GetNormal(),
		(self:GetForward()-self:GetRight()):GetNormal(),
		(-self:GetForward()+self:GetRight()):GetNormal(),
		(-self:GetForward()-self:GetRight()):GetNormal(),
	}
	for _, dir in ipairs(dirs) do
		for i = 1, 14 do
			Burst(2.0, dir * i * 130)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_SpawnAllies()
	local myPos = self:GetPos()
	sound.Play("npc/zombie_poison/pz_call1.wav", myPos, 120, 68)
	-- Sprouts
	local sproutCount = self.SB_Phase >= 4 and 3 or 2
	for i = 1, sproutCount do
		local offset = Vector(math.random(-100, 100), math.random(-100, 100), 20)
		local s = ents.Create("npc_vj_horde_sb_isharspawn")
		if IsValid(s) then s:SetPos(myPos + offset) s:Spawn() s:Activate() end
	end
	-- Heralds on phase 3+
	if self.SB_Phase >= 3 then
		for i = 1, 2 do
			local offset = Vector(math.random(-150, 150), math.random(-150, 150), 20)
			local h = ents.Create("npc_vj_horde_sb_herald")
			if IsValid(h) then h:SetPos(myPos + offset) h:Spawn() h:Activate() end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local hp = self:Health()
	local maxHp = self:GetMaxHealth()

	-- Phase transitions
	if self.SB_Phase == 1 and hp < maxHp * 0.75 then
		self.SB_Phase = 2
		self:SetColor(Color(0, 0, 200, 240))
		self.SB_SpawnCooldown = 0
		sound.Play("npc/zombie_poison/pz_alert1.wav", self:GetPos(), 130, 42)
		util.ScreenShake(self:GetPos(), 25, 160, 2.0, 1000)
	elseif self.SB_Phase == 2 and hp < maxHp * 0.50 then
		self.SB_Phase = 3
		self:SetColor(Color(0, 0, 255, 230))
		self.SB_SpawnCooldown = 0
		sound.Play("npc/zombie_poison/pz_alert2.wav", self:GetPos(), 140, 38)
		util.ScreenShake(self:GetPos(), 30, 180, 2.5, 1200)
		self:SB_TideSurge()
	elseif self.SB_Phase == 3 and hp < maxHp * 0.25 then
		self.SB_Phase = 4
		self.MeleeAttackDamage = self.MeleeAttackDamage * 1.5
		self:SetColor(Color(40, 0, 160, 200))
		self.SB_SpawnCooldown = 0
		sound.Play("npc/zombie_poison/pz_call1.wav", self:GetPos(), 150, 32)
		util.ScreenShake(self:GetPos(), 40, 220, 3.5, 1600)
		self:SB_TideSurge()
	end

	-- Summons
	local spawnCooldown = self.SB_Phase == 4 and 12 or (self.SB_Phase == 3 and 18 or (self.SB_Phase == 2 and 22 or 28))
	if IsValid(self:GetEnemy()) and CurTime() > self.SB_SpawnCooldown then
		self:SB_SpawnAllies()
		self.SB_SpawnCooldown = CurTime() + spawnCooldown
	end

	-- Tide Surge (Phase 3+)
	if self.SB_Phase >= 3 and CurTime() > self.SB_SurgeCooldown then
		self.SB_SurgeCooldown = CurTime() + 30
		self:SB_TideSurge()
	end

	-- Ranged barrage (Phase 3+)
	if self.SB_Phase >= 3 and CurTime() > self.SB_RangeCooldown then
		if IsValid(self:GetEnemy()) and self.EnemyData.Distance > 250 then
			self.SB_RangeCooldown = CurTime() + 8
			self:SB_DoRangeBarrage()
		end
	end

	-- Continuous screen shake in Phase 4
	if self.SB_Phase >= 4 and CurTime() > self.SB_ShakeCooldown then
		self.SB_ShakeCooldown = CurTime() + 2
		util.ScreenShake(self:GetPos(), 6, 40, 0.5, 600)
	end

	-- Aura
	if CurTime() > self.SB_NextAuraTime then
		self.SB_NextAuraTime = CurTime() + 2
		local auraR = self.SB_Phase == 4 and 280 or (self.SB_Phase == 3 and 220 or (self.SB_Phase == 2 and 170 or 130))
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), auraR)) do
			if ent:IsPlayer() then
				ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 8, self)
				if self.SB_Phase >= 3 then
					ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 6, self)
				end
			end
		end
	end
end

VJ.AddNPC("Skadi the Corrupted", "npc_vj_horde_sb_abyssal_king", "Sea-Infection")
