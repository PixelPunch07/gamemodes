AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- ISHAR FRAGMENT | Tier 1 Swarm Unit
-- A severed biomass fragment of Ishar'mla's body. Tiny, fast,
-- and surprisingly durable for its size. Moves in packs.
-- These pieces of living coral will pursue a target endlessly.
-- - Extremely fast movement for its hull size
-- - Nervous Impairment on melee (disorienting bile spray)
-- - Three spawn on death of ANY Seaborn boss-tier enemy
-- - Immune to all debuffs (no nervous system to impair)
-- ============================================================
ENT.Model = "models/zombie/classic_torso.mdl"
ENT.StartHealth = 55
ENT.HullType = HULL_TINY
ENT.SightAngle = 200
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 38
ENT.MeleeAttackDamageDistance = 52
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 12
ENT.MeleeAttackBleedEnemy = false
ENT.HasExtraMeleeAttackSounds = true
ENT.DisableFootStepSoundTimer = true

ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav","vj_zombies/slow/miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav","npc/zombie/zombie_pain2.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav"}

ENT.GeneralSoundPitch1 = 110
ENT.GeneralSoundPitch2 = 125
---------------------------------------------------------------------------------------------------------------------------------------------
local getEventName = util.GetAnimEventNameByID
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local eventName = getEventName(ev)
	if eventName == "AE_ZOMBIE_STEP_LEFT" or eventName == "AE_ZOMBIE_STEP_RIGHT" then
		self:PlayFootstepSound()
	elseif eventName == "AE_ZOMBIE_ATTACK_LEFT" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(18, 18, 22), Vector(-18, -18, 0))
	self:SetColor(Color(80, 0, 200))
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	-- Slightly translucent: unsettling, barely visible skitter
	self:SetColor(Color(80, 0, 200, 210))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 10, self)
	end
end

VJ.AddNPC("Ishar Fragment", "npc_vj_horde_sb_fragment", "Sea-Infection")
