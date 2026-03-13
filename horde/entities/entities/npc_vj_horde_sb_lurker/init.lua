include("entities/npc_vj_zss_stalker/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- TIDE LURKER | Tier 1 Ambush Unit
-- A patient deep-sea predator that stalks its prey unseen.
-- Coats itself in a mucous refractive layer that bends light,
-- rendering it nearly invisible until it strikes.
-- - Invisible (alpha 30) when out of combat
-- - Becomes visible on alert or attack
-- - Returns to near-invisible after 6 seconds without hitting
-- - Slow on melee hit: corrosive mucous coats the target's legs
-- - Nervous Impairment on first strike (ambush disorientation)
-- ============================================================
ENT.Model = "models/vj_zombies/stalker.mdl"
ENT.StartHealth = 220
ENT.MeleeAttackDamage = 25
ENT.MeleeAttackPlayerSpeed = true
ENT.MeleeAttackBleedEnemy = false
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 80
ENT.GeneralSoundPitch2 = 90
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(9, 9, 65), Vector(-9, -9, 0))
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetColor(Color(20, 60, 140, 30)) -- Nearly invisible at rest
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_Lurker_Ambush = true -- First strike bonus
	self.SB_RevealTimer = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.VJ_IsBeingControlled then return end
	-- Briefly flash visible on alert
	self:SetColor(Color(20, 60, 140, 180))
	timer.Simple(1.5, function()
		if IsValid(self) and not self.Dead then
			self:SetColor(Color(20, 60, 140, 30))
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	-- Fully reveal on attack
	self:SetColor(Color(20, 60, 140, 200))
	self.SB_RevealTimer = CurTime() + 6
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		-- Slow from mucous
		if self.SB_Lurker_Ambush then
			-- Ambush first strike: extra nervous impairment
			self.SB_Lurker_Ambush = false
			ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 22, self)
		end
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 6, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	-- Fade back to invisible after reveal timer expires
	if self.SB_RevealTimer > 0 and CurTime() > self.SB_RevealTimer then
		self.SB_RevealTimer = 0
		self:SetColor(Color(20, 60, 140, 30))
		self.SB_Lurker_Ambush = true -- Reset ambush bonus
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.3) end
	-- Flash visible when hit
	self:SetColor(Color(20, 60, 140, 220))
	self.SB_RevealTimer = CurTime() + 4
end

VJ.AddNPC("Tide Lurker", "npc_vj_horde_sb_lurker", "Sea-Infection")
