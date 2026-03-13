include("entities/npc_vj_zss_stalker/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- ABYSSAL HERALD | Tier 5 Apex Multi-Mechanic
-- A direct herald of Ishar'mla. The Abyssal Herald combines
-- the stealth of the Inkblood Spectre with the power of an
-- Abyssal Warden. It moves unseen, strikes with catastrophic
-- force, then retreats back into the dark.
-- Phases:
--   Phase 1 (stealth): Alpha 25, stalks target, no aggression
--   Phase 2 (assault): Fully visible, devastating combo attacks
--     - Melee: 3x strikes in rapid succession
--     - Ground slam on first close approach
--     - All debuffs applied simultaneously
--   Phase 3 (<40% HP): Berserk — permanently visible, immune to
--     slow, charge-dashes every 3 seconds
-- ============================================================
ENT.Model = "models/vj_zombies/stalker.mdl"
ENT.StartHealth = 700
ENT.MeleeAttackDistance = 38
ENT.MeleeAttackDamageDistance = 80
ENT.MeleeAttackDamage = 55
ENT.MeleeAttackPlayerSpeed = false
ENT.MeleeAttackBleedEnemy = true
ENT.HasMeleeAttackKnockBack = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 72
ENT.GeneralSoundPitch2 = 80
ENT.SoundTbl_FootStep = {"npc/stalker/stalker_footstep_left1.wav","npc/stalker/stalker_footstep_left2.wav","npc/stalker/stalker_footstep_right1.wav","npc/stalker/stalker_footstep_right2.wav"}
ENT.SoundTbl_Breath = "npc/stalker/breathing3.wav"
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav","vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav","npc/zombie_poison/pz_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(9, 9, 65), Vector(-9, -9, 0))
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(0, 60, 200, 25)) -- Stealth phase
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_Phase = 1
	self.SB_FirstStrike = true
	self.SB_ChargeCooldown = 0
	self.SB_SlamDone = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.15) end
	if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.6) end
	-- Transition to assault phase when first hit
	if self.SB_Phase == 1 then
		self:SB_EnterAssault()
	end
	-- Phase 3 transition
	if self.SB_Phase == 2 and self:Health() < self:GetMaxHealth() * 0.4 then
		self:SB_EnterBerserk()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_EnterAssault()
	if self.SB_Phase >= 2 then return end
	self.SB_Phase = 2
	self:SetColor(Color(0, 60, 200, 220))
	sound.Play("npc/zombie_poison/pz_alert1.wav", self:GetPos(), 100, 65)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_EnterBerserk()
	if self.SB_Phase >= 3 then return end
	self.SB_Phase = 3
	self.MeleeAttackDamage = self.MeleeAttackDamage * 1.5
	self:SetColor(Color(0, 20, 255, 255))
	sound.Play("npc/zombie_poison/pz_alert2.wav", self:GetPos(), 120, 50)
	util.ScreenShake(self:GetPos(), 18, 100, 1.0, 500)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	-- Reveal on attack
	if self.SB_Phase == 1 then self:SB_EnterAssault() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 12, self)
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 18, self)
		-- First strike bonus: slam
		if self.SB_FirstStrike then
			self.SB_FirstStrike = false
			ene:ViewPunch(Angle(math.random(-12,12), math.random(-12,12), math.random(-8,8)))
		end
	end
	-- Ground slam on first close approach
	if not self.SB_SlamDone and IsValid(self:GetEnemy()) and self.EnemyData.Distance < 200 then
		self.SB_SlamDone = true
		timer.Simple(0.3, function()
			if not IsValid(self) or self.Dead then return end
			sound.Play("physics/concrete/concrete_impact_hard1.wav", self:GetPos(), 90, 55)
			util.ScreenShake(self:GetPos(), 16, 90, 0.8, 400)
			local dmg = DamageInfo()
			dmg:SetInflictor(self) dmg:SetAttacker(self)
			dmg:SetDamageType(DMG_CLUB) dmg:SetDamage(40)
			for _, ent in pairs(ents.FindInSphere(self:GetPos(), 240)) do
				if ent:IsPlayer() then
					ent:TakeDamageInfo(dmg)
					ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 15, self)
				end
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if self.SB_Phase < 3 then return end
	if not IsValid(self:GetEnemy()) then return end
	if CurTime() < self.SB_ChargeCooldown then return end
	self.SB_ChargeCooldown = CurTime() + 3
	self:SetLocalVelocity((self:GetEnemy():GetPos() - self:GetPos()):GetNormal() * 480)
end

VJ.AddNPC("Abyssal Herald", "npc_vj_horde_sb_herald", "Sea-Infection")
