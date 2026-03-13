include("entities/npc_vj_zss_draggy/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- NESSUNO THRALL | Tier 3 Corrupted Human
-- Once a soldier of Nessuno, a coastal nation swallowed by
-- the tide. Now a thrall utterly subsumed by the Seaborn.
-- Retains enough muscle memory to fight with lethal speed.
-- - Extremely fast melee: multi-hit rapid claw strikes
-- - Periodically spews a short-range poison mist (mini-cone)
-- - Bleeds target on each hit
-- - Resists all debuffs (Seaborn nervous system is alien)
-- ============================================================
ENT.Model = "models/vj_zombies/draggy.mdl"
ENT.StartHealth = 175
ENT.MeleeAttackDistance = 22
ENT.MeleeAttackDamageDistance = 68
ENT.TimeUntilMeleeAttackDamage = 0.18
ENT.NextAnyAttackTime_Melee = 0.18
ENT.MeleeAttackDamage = 16
ENT.MeleeAttackBleedEnemy = true
ENT.PropInteraction = "OnlyDamage"
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 95
ENT.GeneralSoundPitch2 = 105
ENT.SoundTbl_Idle = {"vj_zombies/special/zmisc_idle1.wav","vj_zombies/special/zmisc_idle2.wav","vj_zombies/special/zmisc_idle3.wav"}
ENT.SoundTbl_Alert = {"vj_zombies/special/zmisc_alert1.wav","vj_zombies/special/zmisc_alert2.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"vj_zombies/special/bite1.wav","vj_zombies/special/bite2.wav","vj_zombies/special/bite3.wav","vj_zombies/special/bite4.wav"}
ENT.SoundTbl_Pain = {"vj_zombies/special/zmisc_pain1.wav","vj_zombies/special/zmisc_pain2.wav","vj_zombies/special/zmisc_pain3.wav"}
ENT.SoundTbl_Death = {"vj_zombies/special/zmisc_die1.wav","vj_zombies/special/zmisc_die2.wav","vj_zombies/special/zmisc_die3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(12, 12, 60), Vector(-12, -12, 0))
	self:SetColor(Color(0, 120, 180))
	self:SetSkin(math.random(0, 3))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_NextSprayTime = CurTime() + 8
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.25) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 5, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- Periodic short-range poison spray attack
function ENT:CustomOnThink()
	if CurTime() < self.SB_NextSprayTime then return end
	if not IsValid(self:GetEnemy()) then return end
	if self.EnemyData.Distance > 180 then return end
	self.SB_NextSprayTime = CurTime() + 7
	sound.Play("npc/zombie_poison/pz_warn1.wav", self:GetPos(), 70, 85)
	-- Cone spray: hit players in forward arc
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 160)) do
		if ent:IsPlayer() then
			local dot = self:GetForward():Dot((ent:GetPos() - self:GetPos()):GetNormal())
			if dot > 0.5 then -- ~60 degree cone
				ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 14, self)
			end
		end
	end
end

VJ.AddNPC("Nessuno Thrall", "npc_vj_horde_sb_nessuno", "Sea-Infection")
