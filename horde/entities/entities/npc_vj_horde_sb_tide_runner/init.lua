include("entities/npc_vj_zss_fast/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- TIDE RUNNER | Tier 1 Common Seaborn
-- The most agile of the common Seaborn swarm. Evolved for
-- relentless pursuit across any terrain. Its screech upon
-- leaping shatters the nerves of even hardened operators.
-- - Leap attack applies Nervous Impairment (disrupts aim)
-- - Sprint dash burst when target is far away
-- - Extra melee attacks in rapid succession when close
-- - Bleeds enemies on melee
-- ============================================================
ENT.Model = "models/vj_zombies/fast1.mdl"
ENT.StartHealth = 90
ENT.MeleeAttackDamage = 10
ENT.LeapAttackDamage = 20
ENT.MeleeAttackBleedEnemy = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 95
ENT.GeneralSoundPitch2 = 105
ENT.NextLeapAttackTime = 5
ENT.LeapAttackMaxDistance = 500
ENT.LeapAttackMinDistance = 120
ENT.LeapAttackExtraTimers = {0.3, 0.5, 0.7}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(0, 220, 200))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self:SetCollisionBounds(Vector(13, 13, 50), Vector(-13, -13, 0))
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
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 18, self)
		ene:ViewPunch(Angle(math.random(-6, 6), math.random(-6, 6), math.random(-3, 3)))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if not IsValid(self:GetEnemy()) then return end
	if CurTime() < self.SB_DashCooldown then return end
	local dist = self.EnemyData and self.EnemyData.Distance or 9999
	if dist > 450 then
		self.SB_DashCooldown = CurTime() + 3.5
		local toward = (self:GetEnemy():GetPos() - self:GetPos()):GetNormal()
		self:SetLocalVelocity(toward * 420)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLeapAttack(status, enemy)
	if status == "Jump" then
		return VJ.CalculateTrajectory(self, enemy, "Curve", self:GetPos() + self:OBBCenter(), enemy:GetPos() + enemy:OBBCenter(), 25) + self:GetForward() * 80
	end
end

VJ.AddNPC("Tide Runner", "npc_vj_horde_sb_tide_runner", "Sea-Infection")
