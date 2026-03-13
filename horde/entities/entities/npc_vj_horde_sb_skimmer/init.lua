include("entities/npc_vj_zss_crabless_fast/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- AEGIRIAN SKIMMER | Tier 2 Aegirian Elite
-- The faster-mutated Aegirian variant. Elongated limbs and
-- hollow bones allow it to skim across any surface at speed.
-- It carries a weaponized nervous toxin in its claws that
-- scrambles an Operator's fine motor control.
-- - Leap attack applies Nervous Impairment + Bleed
-- - Higher base speed than standard Aegirian
-- - Corrosive claw strikes bleed on every melee hit
-- - Sprint dash when target is beyond 350 units
-- ============================================================
ENT.Model = "models/vj_zombies/fast_main.mdl"
ENT.StartHealth = 110
ENT.MeleeAttackDamage = 14
ENT.LeapAttackDamage = 22
ENT.MeleeAttackBleedEnemy = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 90
ENT.GeneralSoundPitch2 = 100
ENT.NextLeapAttackTime = 6
ENT.LeapAttackMaxDistance = 450
ENT.LeapAttackMinDistance = 100
ENT.MainSoundPitch = 100
ENT.SoundTbl_FootStep = {"npc/fast_zombie/foot1.wav","npc/fast_zombie/foot2.wav","npc/fast_zombie/foot3.wav","npc/fast_zombie/foot4.wav"}
ENT.SoundTbl_Alert = {"npc/fast_zombie/fz_alert_close1.wav","npc/fast_zombie/fz_alert_far1.wav"}
ENT.SoundTbl_LeapAttackJump = "npc/fast_zombie/fz_scream1.wav"
ENT.SoundTbl_Pain = {"npc/fast_zombie/idle1.wav","npc/fast_zombie/idle2.wav","npc/fast_zombie/idle3.wav"}
ENT.SoundTbl_Death = "npc/fast_zombie/wake1.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(0, 200, 255))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_DashCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.3) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnLeapAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 16, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if not IsValid(self:GetEnemy()) then return end
	if CurTime() < self.SB_DashCooldown then return end
	local dist = self.EnemyData and self.EnemyData.Distance or 9999
	if dist > 350 then
		self.SB_DashCooldown = CurTime() + 3
		self:SetLocalVelocity((self:GetEnemy():GetPos() - self:GetPos()):GetNormal() * 380)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLeapAttack(status, enemy)
	if status == "Jump" then
		return VJ.CalculateTrajectory(self, enemy, "Curve", self:GetPos() + self:OBBCenter(), enemy:GetPos() + enemy:OBBCenter(), 25) + self:GetForward() * 80
	end
end

VJ.AddNPC("Aegirian Skimmer", "npc_vj_horde_sb_skimmer", "Sea-Infection")
