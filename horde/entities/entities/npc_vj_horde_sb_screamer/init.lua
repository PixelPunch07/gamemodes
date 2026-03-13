include("entities/npc_vj_zss_panic/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- VOID SCREAMER | Tier 2 Debuffer
-- A Seaborn-corrupted civilian whose vocal cords have been
-- replaced with resonant coral chambers. Its screech vibrates
-- at a frequency that disrupts human nervous systems.
-- - Periodic psychic screech: ALL nearby players get Nervous
--   Impairment applied simultaneously (AoE)
-- - Screech has a visible windup (plays audio cue first)
-- - Melee applies a weaker Nervous Impairment as well
-- - Flees when below 25% HP (panicked behavior)
-- ============================================================
ENT.Model = {"models/vj_zombies/panic_carrier.mdl","models/vj_zombies/panic_eugene.mdl","models/vj_zombies/panic_marcus.mdl"}
ENT.StartHealth = 140
ENT.MeleeAttackDamage = 14
ENT.MeleeAttackBleedEnemy = false
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 82
ENT.GeneralSoundPitch2 = 90
ENT.SoundTbl_MeleeAttackExtra = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/panic/z-swipe-1.wav","vj_zombies/panic/z-swipe-2.wav","vj_zombies/panic/z-swipe-3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(160, 0, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_NextScreechTime = CurTime() + 10
	self.SB_IsScreeching = false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.3) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 8, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() < self.SB_NextScreechTime then return end
	if self.SB_IsScreeching then return end
	self.SB_IsScreeching = true
	-- Windup sound
	sound.Play("npc/zombie_poison/pz_warn1.wav", self:GetPos(), 100, 65)
	-- Delay the actual damage/debuff so players can potentially react
	timer.Simple(1.2, function()
		if not IsValid(self) or self.Dead then return end
		self.SB_IsScreeching = false
		self.SB_NextScreechTime = CurTime() + 12
		sound.Play("npc/zombie_poison/pz_alert2.wav", self:GetPos(), 120, 55)
		util.ScreenShake(self:GetPos(), 8, 60, 0.6, 450)
		-- Damage + nervous impairment all players in range
		local dmg = DamageInfo()
		dmg:SetInflictor(self) dmg:SetAttacker(self)
		dmg:SetDamageType(DMG_SONIC) dmg:SetDamage(15)
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 420)) do
			if ent:IsPlayer() then
				ent:TakeDamageInfo(dmg)
				ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 20, self)
				ent:ViewPunch(Angle(math.random(-10,10), math.random(-10,10), math.random(-5,5)))
			end
		end
	end)
end

VJ.AddNPC("Void Screamer", "npc_vj_horde_sb_screamer", "Sea-Infection")
