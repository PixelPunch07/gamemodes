-- =============================================================================
-- XENO ADAPTATION SYSTEM  (server-side)
-- During the Xeno waveset, every enemy kill accrues passive elemental resistance
-- for all future enemies. The resistance is tracked per HORDE damage type.
--
-- Per-kill gain : 0.0009 (0.09%)
-- Cap per type  : 0.36   (36%)
--
-- HOW IT WORKS
-- 1. Horde_OnPlayerDamage tags each NPC with the last HORDE damage type it took
--    from a player, stored in npc.xeno_last_dmgtype.
-- 2. Horde_OnEnemyKilled reads that tag and increments HORDE.xeno_adaptation.
-- 3. Horde_OnPlayerDamagePre applies the accumulated resistance as a damage
--    multiplier before the rest of the damage pipeline runs.
-- 4. Whenever the table changes the server broadcasts it to all clients so the
--    HUD can display current adaptation values.
-- =============================================================================

HORDE.xeno_adaptation = {}      -- [dmg_type_id] = 0..0.36
local ADAPT_PER_KILL  = 0.0009  -- 0.09%
local ADAPT_CAP       = 0.36    -- 36%

-- Elemental types that can be adapted to (physical types are excluded by design).
local ADAPTABLE_TYPES = {
    HORDE.DMG_FIRE,
    HORDE.DMG_COLD,
    HORDE.DMG_LIGHTNING,
    HORDE.DMG_POISON,
    HORDE.DMG_BLAST,
}
local is_adaptable = {}
for _, t in ipairs(ADAPTABLE_TYPES) do is_adaptable[t] = true end

-- Broadcast the current adaptation table to all clients.
local function SyncAdaptation()
    net.Start("Horde_XenoAdaptationSync")
        net.WriteTable(HORDE.xeno_adaptation)
    net.Broadcast()
end

-- Sync to a single newly connected player.
function HORDE:SyncXenoAdaptationTo(ply)
    if table.IsEmpty(HORDE.xeno_adaptation) then return end
    net.Start("Horde_XenoAdaptationSync")
        net.WriteTable(HORDE.xeno_adaptation)
    net.Send(ply)
end

-- ----------------------------------------------------------------
-- 1. Tag NPCs with the last HORDE elemental damage type they take.
-- ----------------------------------------------------------------
hook.Add("Horde_OnPlayerDamage", "XenoAdaptation_TagNPC", function(ply, npc, bonus, hitgroup, dmginfo)
    if not IsValid(npc) then return end
    local dmg_type = HORDE:GetDamageType(dmginfo)
    if is_adaptable[dmg_type] then
        npc.xeno_last_dmgtype = dmg_type
    end
end)

-- ----------------------------------------------------------------
-- 2. On kill, accrue resistance for the damage type that finished the enemy.
-- ----------------------------------------------------------------
hook.Add("Horde_OnEnemyKilled", "XenoAdaptation_OnKill", function(victim, killer, weapon)
    if HORDE.waveset ~= "xeno" then return end
    if not IsValid(victim) then return end

    local dmg_type = victim.xeno_last_dmgtype
    if not dmg_type or not is_adaptable[dmg_type] then return end

    local current = HORDE.xeno_adaptation[dmg_type] or 0
    local new_val  = math.min(current + ADAPT_PER_KILL, ADAPT_CAP)

    -- Only sync when the value actually changes (it will always change here,
    -- but guard against floating-point collapsing to cap).
    if new_val ~= current then
        HORDE.xeno_adaptation[dmg_type] = new_val
        SyncAdaptation()
    end
end)

-- ----------------------------------------------------------------
-- 3. Apply resistance before damage is calculated.
--    Hooks into Horde_OnPlayerDamagePre — returning true here skips
--    the rest of the pre hook and applies damage immediately, so we
--    use Horde_OnPlayerDamage instead to modify bonus.more (safer).
-- ----------------------------------------------------------------
hook.Add("Horde_OnPlayerDamage", "XenoAdaptation_ApplyResistance", function(ply, npc, bonus, hitgroup, dmginfo)
    if HORDE.waveset ~= "xeno" then return end

    local dmg_type = HORDE:GetDamageType(dmginfo)
    local resistance = HORDE.xeno_adaptation[dmg_type]
    if not resistance or resistance <= 0 then return end

    -- Reduce outgoing damage by the adaptation resistance.
    -- bonus.more stacks multiplicatively with other more modifiers.
    bonus.more = bonus.more * (1 - resistance)
end)

-- ----------------------------------------------------------------
-- 4. Sync adaptation to players who connect mid-session.
-- ----------------------------------------------------------------
hook.Add("HordeWaveStart", "XenoAdaptation_SyncOnWaveStart", function()
    if HORDE.waveset ~= "xeno" then return end
    SyncAdaptation()
end)
