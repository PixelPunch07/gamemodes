include("entities/npc_vj_zss_slow/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- ============================================================
-- TIDE ASSIMILATOR | Tier 4 Split Enemy
-- One of the most feared Seaborn types. The Assimilator is
-- a colony organism: it appears as a single body, but its
-- interior is packed with semi-autonomous bio-fragments.
-- When destroyed, these fragments burst free and continue
-- fighting independently.
-- - On death: spawns 3 Ishar Fragments at its position
-- - Passive: absorbs partial damage from non-explosive sources
-- - Aura: corrosive secretion slows nearby players
-- - Immune to poison; absorbs it as nutrition
-- ============================================================
ENT.Model = {"models/vj_zombies/slow8.mdl","models/vj_zombies/slow9.mdl","models/vj_zombies/slow10.mdl"}
ENT.StartHealth = 260
ENT.MeleeAttackDamage = 24
ENT.MeleeAttackBleedEnemy = false
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE","CLASS_XEN"}
ENT.BloodColor = "Green"
ENT.GeneralSoundPitch1 = 62
ENT.GeneralSoundPitch2 = 70
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav","npc/zombie_poison/pz_idle3.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav","npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav","npc/zombie_poison/pz_pain2.wav","npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_Death = {"npc/zombie_poison/pz_die1.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetColor(Color(0, 200, 140))
	self:AddRelationship("npc_headcrab_poison D_LI 99")
	self:AddRelationship("npc_headcrab_fast D_LI 99")
	self.SB_NextAuraTime = CurTime() + 6
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
	-- Immune to poison entirely
	if HORDE:IsPoisonDamage(dmginfo) then dmginfo:SetDamage(0) return end
	-- Partial damage absorption for non-explosive damage
	if not HORDE:IsBlastDamage(dmginfo) then
		dmginfo:ScaleDamage(0.75)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterDamage(dmginfo, hitgroup)
	local ene = self:GetEnemy()
	if IsValid(ene) and ene:IsPlayer() then
		ene:Horde_AddDebuffBuildup(HORDE.Status_Poison, 8, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() < self.SB_NextAuraTime then return end
	self.SB_NextAuraTime = CurTime() + 6
	-- Slow/corrode nearby players
	for _, ent in pairs(ents.FindInSphere(self:GetPos(), 130)) do
		if ent:IsPlayer() then
			ent:Horde_AddDebuffBuildup(HORDE.Status_Poison, 5, self)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	local pos = self:GetPos()
	local ang = self:GetAngles()
	sound.Play("npc/zombie_poison/pz_die2.wav", pos, 90, 70)
	-- Spawn 3 Ishar Fragments
	for i = 1, 3 do
		local offset = Vector(math.random(-60, 60), math.random(-60, 60), 20)
		local frag = ents.Create("npc_vj_horde_sb_fragment")
		if IsValid(frag) then
			frag:SetPos(pos + offset)
			frag:SetAngles(ang)
			frag:Spawn()
			frag:Activate()
			-- Give brief launch velocity outward
			timer.Simple(0.1, function()
				if IsValid(frag) then
					frag:SetLocalVelocity(offset:GetNormal() * 120 + Vector(0,0,80))
				end
			end)
		end
	end
end

VJ.AddNPC("Tide Assimilator", "npc_vj_horde_sb_assimilator", "Sea-Infection")
