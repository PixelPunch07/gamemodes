AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- ABYSSAL CHOIR | Tier 3 Ranged Attacker
-- Named for the eerie harmonic resonance they produce.
-- Abyssal Choirs are purpose-built biological artillery:
-- their swollen abdomens contain pressurized acid sacs
-- that launch volleys of corrosive seaborn bile at range.
-- - Ranged attack: launches 3 acid projectiles in spread
-- - Each projectile applies Poison buildup on impact
-- - Melee applies Poison when backed into close range
-- - Aura: nearby players receive small continuous poison tick
-- ============================================================
ENT.Model = "models/zombie/poison.mdl"
ENT.StartHealth = 200
ENT.HullType = HULL_HUMAN
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = {"vjseq_melee_01","vjseq_melee_03"}
ENT.MeleeAttackDistance = 34
ENT.MeleeAttackDamageDistance = 88
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 22
ENT.MeleeAttackBleedEnemy = false
ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1}
ENT.RangeAttackEntityToSpawn = "obj_vj_horde_vomitter_projectile"
ENT.RangeDistance = 950
ENT.RangeToMeleeDistance = 180
ENT.RangeUseAttachmentForPos = false
ENT.TimeUntilRangeAttackProjectileRelease = 0.6
ENT.NextRangeAttackTime = 9

ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav","npc/zombie/foot2.wav","npc/zombie/foot3.wav"}
ENT.SoundTbl_Breath = "npc/zombie_poison/pz_breathe_loop1.wav"
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav","npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"npc/zombie_poison/pz_warn1.wav","npc/zombie_poison/pz_warn2.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_zombies/slow/miss1.wav","vj_zombies/slow/miss2.wav","vj_zombies/slow/miss3.wav"}
ENT.SoundTbl_RangeAttack = {"npc/zombie_poison/pz_warn1.wav","npc/zombie_poison/pz_warn2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav","npc/zombie_poison/pz_die2.wav"}
ENT.GeneralSoundPitch1 = 68
ENT.GeneralSoundPitch2 = 75

ENT.Zombie_ActFireWalk = -1
---------------------------------------------------------------------------------------------------------------------------------------------
local getEventName = util.GetAnimEventNameByID
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local eventName = getEventName(ev)
	if eventName == "AE_ZOMBIE_STEP_LEFT" or eventName == "AE_ZOMBIE_STEP_RIGHT" then
		self:PlayFootstepSound()
	elseif eventName == "AE_ZOMBIE_ATTACK_RIGHT" or eventName == "AE_ZOMBIE_ATTACK_LEFT" or eventName == "AE_ZOMBIE_ATTACK_BOTH" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(15, 15, 50), Vector(-15, -15, 0))
	self:SetColor(Color(100, 0, 200))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.Zombie_ActFireWalk = self:GetSequenceActivity(self:LookupSequence("FireWalk"))
	self.SB_NextAuraTime = CurTime() + 6
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.2) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 10, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- Fire three spread projectiles on range attack
function ENT:CustomRangeAttackCode_BeforeProjectileSpawn(projectile)
	for i = 1, 2 do
		local extra = ents.Create(self.RangeAttackEntityToSpawn)
		if not IsValid(extra) then continue end
		local ene = self:GetEnemy()
		if not IsValid(ene) then continue end
		local spread = Vector(math.random(-90, 90), math.random(-90, 90), math.random(20, 60))
		local target = ene:GetPos() + spread
		extra:SetPos(self:GetPos() + self:GetUp() * 55)
		extra:SetAngles((target - extra:GetPos()):Angle())
		extra:SetOwner(self)
		extra:SetPhysicsAttacker(self)
		extra:Spawn()
		extra:Activate()
		local phys = extra:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity((target - extra:GetPos()) * 1.6)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() < self.SB_NextAuraTime then return end
	self.SB_NextAuraTime = CurTime() + 6
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 120)) do
		if ent:IsPlayer() then ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 4, self) end
	end
end

VJ.AddNPC("Abyssal Choir", "npc_vj_horde_sb_choir", "Sea-Infection")
