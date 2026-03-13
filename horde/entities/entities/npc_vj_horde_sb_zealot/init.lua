include("entities/npc_vj_zss_crabless_zombine/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- TIDE ZEALOT | Tier 2 Suicide Bomber
-- A fanatically loyal Seaborn host that has been surgically
-- packed with a pressurized biomass charge. It will detonate
-- this charge when sufficiently close to a target, or when
-- its body is critically damaged.
-- - Carries a visible seaborn biomass bomb (prop attached)
-- - Runs toward target and detonates when health < 35% or within 150 units
-- - Explosion: large poison AoE + nervous impairment
-- - Bleed on melee contact
-- ============================================================
ENT.Model = "models/vj_zombies/zombine.mdl"
ENT.StartHealth = 190
ENT.MeleeAttackDamage = 28
ENT.MeleeAttackBleedEnemy = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 75
ENT.GeneralSoundPitch2 = 82
ENT.SoundTbl_FootStep = {"vj_zombies/zombine/gear1.wav","vj_zombies/zombine/gear2.wav","vj_zombies/zombine/gear3.wav"}
ENT.SoundTbl_Idle = {"vj_zombies/zombine/idle1.wav","vj_zombies/zombine/idle2.wav","vj_zombies/zombine/idle3.wav"}
ENT.SoundTbl_Alert = {"vj_zombies/zombine/alert1.wav","vj_zombies/zombine/alert2.wav","vj_zombies/zombine/alert3.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_zombies/zombine/attack1.wav","vj_zombies/zombine/attack2.wav","vj_zombies/zombine/attack3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav","vj_zombies/slow/miss2.wav","vj_zombies/slow/miss3.wav"}
ENT.SoundTbl_Pain = {"vj_zombies/zombine/pain1.wav","vj_zombies/zombine/pain2.wav","vj_zombies/zombine/pain3.wav"}
ENT.SoundTbl_Death = {"vj_zombies/zombine/die1.wav","vj_zombies/zombine/die2.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(13, 13, 60), Vector(-13, -13, 0))
	self:SetColor(Color(60, 0, 180))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_Detonated = false
	self.SB_NextDetonateCheck = CurTime() + 1
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.2) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SB_Detonate()
	if self.SB_Detonated then return end
	self.SB_Detonated = true
	sound.Play("npc/zombie_poison/pz_die1.wav", self:GetPos(), 100, 70)
	util.ScreenShake(self:GetPos(), 20, 100, 1.2, 600)
	local e = EffectData() e:SetOrigin(self:GetPos()) e:SetScale(1.3)
	util.Effect("HelicopterMegaBomb", e, true, true)
	local dmg = DamageInfo()
	dmg:SetInflictor(self) dmg:SetAttacker(self)
	dmg:SetDamageType(DMG_BLAST) dmg:SetDamage(75)
	util.BlastDamageInfo(dmg, self:GetPos(), 320)
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 320)) do
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 20, self)
			ent:Horde_AddDebuffBuildup(HORDE.Status_Nervous, 15, self)
		end
	end
	self:TakeDamage(9999, self, self)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if self.SB_Detonated then return end
	if CurTime() < self.SB_NextDetonateCheck then return end
	self.SB_NextDetonateCheck = CurTime() + 0.5
	-- Detonate if critically wounded
	if self:Health() < self:GetMaxHealth() * 0.35 then
		self:SB_Detonate()
		return
	end
	-- Detonate if very close to an enemy
	if IsValid(self:GetEnemy()) and self.EnemyData.Distance < 150 then
		self:SB_Detonate()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	if not self.SB_Detonated then
		self:SB_Detonate()
	end
end

VJ.AddNPC("Tide Zealot", "npc_vj_horde_sb_zealot", "Sea-Infection")
