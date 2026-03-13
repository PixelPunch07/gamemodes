include("entities/npc_vj_zss_stalker/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- INKBLOOD SPECTRE | Tier 4 Elite Ambusher
-- The most terrifying of the Seaborn lurkers. The Inkblood
-- Spectre secretes a pitch-black chromatophore fluid that
-- renders it virtually invisible. It hunts alone, waiting
-- for the perfect moment to deliver a lethal strike.
-- - Nearly invisible at all times (alpha 15)
-- - Only becomes partially visible when attacking (alpha 160)
-- - Devastating ambush burst: deals 3x damage on first hit
-- - Persistent Nervous Impairment on every hit
-- - Returns to near-invisible 4 seconds after attacking
-- - High HP for a stalker unit; hard to track
-- ============================================================
ENT.Model = "models/vj_zombies/stalker.mdl"
ENT.StartHealth = 320
ENT.MeleeAttackDistance = 32
ENT.MeleeAttackDamageDistance = 68
ENT.MeleeAttackDamage = 35
ENT.MeleeAttackPlayerSpeed = false
ENT.MeleeAttackBleedEnemy = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 78
ENT.GeneralSoundPitch2 = 86
ENT.SoundTbl_FootStep = {"npc/stalker/stalker_footstep_left1.wav","npc/stalker/stalker_footstep_left2.wav","npc/stalker/stalker_footstep_right1.wav","npc/stalker/stalker_footstep_right2.wav"}
ENT.SoundTbl_Breath = "npc/stalker/breathing3.wav"
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav","vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Death = {"vj_zombies/special/zmisc_die1.wav","vj_zombies/special/zmisc_die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(9, 9, 65), Vector(-9, -9, 0))
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(20, 0, 80, 15)) -- Nearly invisible
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_AmbushCharged = true -- First strike = ambush bonus
	self.SB_RevealTimer = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.2) end
	-- Flash visible when hit
	self:SetColor(Color(20, 0, 80, 180))
	self.SB_RevealTimer = CurTime() + 3
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	-- Reveal when attacking
	self:SetColor(Color(20, 0, 80, 160))
	self.SB_RevealTimer = CurTime() + 4
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		-- Ambush first strike multiplies damage
		if self.SB_AmbushCharged then
			self.SB_AmbushCharged = false
			local bonus = DamageInfo()
			bonus:SetInflictor(self) bonus:SetAttacker(self)
			bonus:SetDamageType(DMG_SLASH)
			bonus:SetDamage(self.MeleeAttackDamage * 2) -- Additional burst
			ene:TakeDamageInfo(bonus)
		end
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 20, self)
		ene:ViewPunch(Angle(math.random(-8,8), math.random(-8,8), math.random(-5,5)))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	-- Fade back to invisible after reveal timer
	if self.SB_RevealTimer > 0 and CurTime() > self.SB_RevealTimer then
		self.SB_RevealTimer = 0
		self:SetColor(Color(20, 0, 80, 15))
		self.SB_AmbushCharged = true -- Recharge ambush
	end
end

VJ.AddNPC("Inkblood Spectre", "npc_vj_horde_sb_inkblood", "Sea-Infection")
