-- =============================================================================
-- NERVOUS IMPAIRMENT  (Sea-Infection debuff)
-- sv_nervous_impairment.lua
--
-- "Blue Necrosis" — the Seaborn toxin corrodes the nervous system.
-- Effect functions are called by sv_debuff.lua (modified to include this debuff).
--
-- ON PLAYERS:
--   • Poison DoT: 2% max HP every 0.5 s for 5-11 s (difficulty-scaled duration)
--   • Movement speed reduced by 35%
--   • Blue screen tint (cl_init.lua handles RenderScreenspaceEffects)
--   • On expiry: blue ooze burst applies 15-pt buildup to nearby NPCs
--
-- ON ENEMIES (NPCs):
--   • Poison DoT scaled to health
--   • Animation playback slowed to 50%
--   • Blue virus-mist shimmer every 0.5 s
--   • On expiry: same ooze radius burst
-- =============================================================================

local entmeta = FindMetaTable("Entity")

util.AddNetworkString("Horde_NervousImpairmentFX")

-- ─── Expiry burst ─────────────────────────────────────────────────────────────
local function NI_ExpiryBurst(ent)
    if not IsValid(ent) then return end
    local pos = ent:GetPos() + ent:OBBCenter()
    local e = EffectData()
    e:SetOrigin(pos)
    e:SetScale(40)
    util.Effect("horde_virus_mist", e, true, true)
    HORDE:ApplyDebuffInRadius(HORDE.Status_Nervous_Impairment, pos, 180, 15, ent)
end

-- ─── Particle shimmer ─────────────────────────────────────────────────────────
local function NI_StartParticles(ent, key)
    if not IsValid(ent) then return end
    local bones = ent:GetBoneCount()
    timer.Create("NI_Particles_" .. key, 0.5, 0, function()
        if not IsValid(ent) then timer.Remove("NI_Particles_" .. key) return end
        if not (ent.Horde_Debuff_Active and ent.Horde_Debuff_Active[HORDE.Status_Nervous_Impairment]) then
            timer.Remove("NI_Particles_" .. key) return
        end
        for bone = 1, bones - 1 do
            local pos = ent:GetBonePosition(bone)
            if pos then
                local e = EffectData()
                e:SetOrigin(pos)
                e:SetScale(1)
                util.Effect("horde_virus_mist", e, true, true)
            end
        end
    end)
end

-- ─── Apply ───────────────────────────────────────────────────────────────────
function entmeta:Horde_AddNervousImpairmentEffect(inflictor, duration)
    if self:IsPlayer() then
        local sid     = self:SteamID()
        local dot_dmg = self:GetMaxHealth() * 0.02

        timer.Create("NI_DOT_" .. sid, 0.5, 0, function()
            if not IsValid(self) or not self:Alive() then timer.Remove("NI_DOT_" .. sid) return end
            if not (self.Horde_Debuff_Active and self.Horde_Debuff_Active[HORDE.Status_Nervous_Impairment]) then
                timer.Remove("NI_DOT_" .. sid) return
            end
            local dmg = DamageInfo()
            dmg:SetAttacker(IsValid(inflictor) and inflictor or Entity(0))
            dmg:SetInflictor(Entity(0))
            dmg:SetDamageType(DMG_NERVEGAS)
            dmg:SetDamage(dot_dmg)
            dmg:SetDamageCustom(HORDE.DMG_OVER_TIME)
            self:TakeDamageInfo(dmg)
            if self:Health() <= 0 then
                local k = DamageInfo()
                k:SetAttacker(IsValid(inflictor) and inflictor or Entity(0))
                k:SetInflictor(Entity(0))
                k:SetDamageType(DMG_DIRECT)
                k:SetDamage(100)
                self:TakeDamageInfo(k)
            end
        end)

        net.Start("Horde_NervousImpairmentFX") net.WriteBool(true) net.Send(self)
        NI_StartParticles(self, sid)
    else
        local cid  = self:GetCreationID()
        local base = math.max(5, 15 * (self:GetMaxHealth() / math.max(1, self:Health())) + self:Health() * 0.008)

        timer.Create("NI_DOT_" .. cid, 0.5, 0, function()
            if not IsValid(self) then timer.Remove("NI_DOT_" .. cid) return end
            if not (self.Horde_Debuff_Active and self.Horde_Debuff_Active[HORDE.Status_Nervous_Impairment]) then
                timer.Remove("NI_DOT_" .. cid) return
            end
            local dmg = DamageInfo()
            dmg:SetAttacker(self) dmg:SetInflictor(self)
            dmg:SetDamagePosition(self:GetPos())
            dmg:SetDamageType(DMG_NERVEGAS)
            dmg:SetDamage(base)
            self:TakeDamageInfo(dmg)
        end)

        if self:IsNPC() then
            timer.Simple(0, function()
                if not IsValid(self) or self.NI_StoredPlaybackRate ~= nil then return end
                if self.AnimationPlaybackRate ~= nil then
                    self.NI_StoredPlaybackRate = self.AnimationPlaybackRate
                    self.AnimationPlaybackRate = 0.5
                else
                    self.NI_StoredPlaybackRate = self:GetPlaybackRate()
                    self:SetPlaybackRate(0.5)
                end
            end)
        end

        NI_StartParticles(self, tostring(cid))
    end
end

-- ─── Remove ───────────────────────────────────────────────────────────────────
function entmeta:Horde_RemoveNervousImpairment()
    if not IsValid(self) then return end
    if self:IsPlayer() then
        local sid = self:SteamID()
        timer.Remove("NI_DOT_" .. sid)
        timer.Remove("NI_Particles_" .. sid)
        net.Start("Horde_NervousImpairmentFX") net.WriteBool(false) net.Send(self)
        NI_ExpiryBurst(self)
    else
        local cid = self:GetCreationID()
        timer.Remove("NI_DOT_" .. cid)
        timer.Remove("NI_Particles_" .. cid)
        if self:IsNPC() and self.NI_StoredPlaybackRate ~= nil then
            if self.AnimationPlaybackRate ~= nil then
                self.AnimationPlaybackRate = self.NI_StoredPlaybackRate
            else
                self:SetPlaybackRate(self.NI_StoredPlaybackRate)
            end
            self.NI_StoredPlaybackRate = nil
        end
        NI_ExpiryBurst(self)
    end
end

-- ─── Movement slow ────────────────────────────────────────────────────────────
hook.Add("Horde_PlayerMoveBonus", "Horde_NervousImpairmentSlow", function(ply, bonus_walk, bonus_run)
    if ply.Horde_Debuff_Active and ply.Horde_Debuff_Active[HORDE.Status_Nervous_Impairment] then
        bonus_walk.more = bonus_walk.more * 0.65
        bonus_run.more  = bonus_run.more  * 0.65
    end
end)
