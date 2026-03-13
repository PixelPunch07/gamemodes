include("entities/npc_vj_zss_burnzie/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- BIOLUMINESCENT BURNER | Tier 3 Fire/Acid Hybrid
-- A Seaborn variant whose internal acid chambers have become
-- volatile. When agitated it spontaneously ignites, coating
-- itself in bioluminescent corrosive fire.
-- - Ignites when alerted/combat, extinguishes when passive
-- - Sets targets on fire when struck while burning
-- - Ignition simultaneously applies Poison buildup (acid fire)
-- - Death: erupts in a bioluminescent fire + acid splash
-- - Immune to fire; extra vulnerability to cold/ice
-- ============================================================
ENT.Model = "models/vj_zombies/burnzie.mdl"
ENT.StartHealth = 210
ENT.MeleeAttackDamage = 22
ENT.Immune_Fire = true
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.SoundTbl_Idle = {"vj_zombies/special/zmisc_idle1.wav","vj_zombies/special/zmisc_idle2.wav","vj_zombies/special/zmisc_idle3.wav"}
ENT.SoundTbl_Alert = {"vj_zombies/special/zmisc_alert1.wav","vj_zombies/special/zmisc_alert2.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_Pain = {"vj_zombies/special/zmisc_pain1.wav","vj_zombies/special/zmisc_pain2.wav","vj_zombies/special/zmisc_pain3.wav"}
ENT.SoundTbl_Death = {"vj_zombies/special/zmisc_die1.wav","vj_zombies/special/zmisc_die2.wav"}
ENT.GeneralSoundPitch1 = 80
ENT.GeneralSoundPitch2 = 88
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(13, 13, 60), Vector(-13, -13, 0))
	self:SetColor(Color(0, 255, 180))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	if HORDE:IsFireDamage(dmginfo) then dmginfo:SetDamage(0) end -- Full fire immune
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(dmginfo:GetDamage() * 0.2) end
	-- Extra vulnerability to cold/ice
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnStateChange(oldState, newState)
	if not self.VJ_IsBeingControlled then
		if newState == NPC_STATE_ALERT or newState == NPC_STATE_COMBAT then
			self:Ignite(99999)
			-- Bioluminescent tint when on fire
			self:SetColor(Color(0, 255, 100))
		else
			self:Extinguish()
			self:SetColor(Color(0, 255, 180))
		end
	end
	self.BaseClass.OnStateChange(self, oldState, newState)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMeleeAttackExecute(status, ent, isProp)
	if status == "PreDamage" and self:IsOnFire() and IsValid(ent) then
		ent:Ignite(math.Rand(3, 5))
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 10, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	local dmg = DamageInfo()
	dmg:SetInflictor(self) dmg:SetAttacker(self)
	dmg:SetDamageType(DMG_BURN) dmg:SetDamage(55)
	util.BlastDamageInfo(dmg, self:GetPos(), 260)
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 260)) do
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 18, self)
		end
	end
	local e = EffectData() e:SetOrigin(self:GetPos()) e:SetScale(1.0)
	util.Effect("HelicopterMegaBomb", e, true, true)
end

VJ.AddNPC("Bioluminescent Burner", "npc_vj_horde_sb_burner", "Sea-Infection")
