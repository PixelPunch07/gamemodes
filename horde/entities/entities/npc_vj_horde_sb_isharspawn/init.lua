include("entities/npc_vj_zss_boss_mini/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- ISHAR'MLA SPROUT | Tier 5 Mini-Boss Spawn
-- A semi-autonomous fragment of Ishar'mla's will given a
-- temporary physical body. Spawned by the Ishar'mla Echo
-- during combat. Though smaller than the parent entity,
-- Sprouts are still devastatingly powerful.
-- - Same power tier as npc_vj_zss_boss_mini but Seaborn-themed
-- - Heavy poison aura at all times
-- - Ground slam on close approach
-- - Bleeds and poisons every melee strike
-- - Applies Nervous Impairment on heavy hits
-- - Immune to poison; resistant to explosions
-- ============================================================
ENT.Model = "models/vj_zombies/gal_boss_mini.mdl"
ENT.StartHealth = 600
ENT.MeleeAttackDamage = 55
ENT.MeleeAttackBleedEnemy = true
ENT.HasMeleeAttackKnockBack = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 50
ENT.GeneralSoundPitch2 = 58

local sdFootScuff = {"npc/zombie/foot_slide1.wav","npc/zombie/foot_slide2.wav","npc/zombie/foot_slide3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then self:PlayFootstepSound()
	elseif key == "scuff" then self:PlayFootstepSound(sdFootScuff)
	elseif key == "melee" then self.MeleeAttackDamage = 55 self:ExecuteMeleeAttack()
	elseif key == "melee_heavy" then self.MeleeAttackDamage = 65 self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(0, 255, 200))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_NextAuraTime = CurTime() + 4
	self.SB_SlamCooldown = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(0) end
	if HORDE:IsBlastDamage(dmginfo) then dmginfo:ScaleDamage(0.55) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 14, self)
		ene:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 12, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() > self.SB_NextAuraTime then
		self.SB_NextAuraTime = CurTime() + 4
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 150)) do
			if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 8, self) end
		end
	end
	if CurTime() > self.SB_SlamCooldown and IsValid(self:GetEnemy()) and self.EnemyData.Distance < 220 then
		self.SB_SlamCooldown = CurTime() + 10
		sound.Play("physics/concrete/concrete_impact_hard1.wav", self:GetPos(), 90, 58)
		util.ScreenShake(self:GetPos(), 14, 80, 0.8, 380)
		local dmg = DamageInfo()
		dmg:SetInflictor(self) dmg:SetAttacker(self)
		dmg:SetDamageType(DMG_CLUB) dmg:SetDamage(40)
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 240)) do
			if ent:IsPlayer() then
				ent:TakeDamageInfo(dmg)
				ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 10, self)
				ent:SetVelocity((ent:GetPos()-self:GetPos()):GetNormal() * 230 + Vector(0,0,180))
			end
		end
	end
end

VJ.AddNPC("Ishar'mla Sprout", "npc_vj_horde_sb_isharspawn", "Sea-Infection")
