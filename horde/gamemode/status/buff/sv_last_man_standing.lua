-- ============================================================
-- Last Man Standing
-- Triggers when only one player remains alive (multiplayer),
-- or when a solo player takes a killing blow (singleplayer).
-- Each class has unique buffs and a unique activation message.
-- ============================================================

local plymeta = FindMetaTable("Player")

util.AddNetworkString("Horde_LastManStanding")

-- ============================================================
-- Class-specific LMS configuration
-- Keys match what ply:Horde_GetCurrentSubclass() returns.
-- ============================================================
local LMS_DATA = {
    -- ---- Base Classes ----
    ["Survivor"] = {
        message    = function(n) return n .. ", the ordinary mercenary does what they do best. Survive." end,
        color      = Color(220, 200, 60),
        dmg_bonus  = 0.40,   -- +40% damage
        resistance = 0.30,   -- 30% damage reduction
        speed      = 0.20,   -- +20% movement speed
        regen      = 0.04,   -- 4% HP/sec regen
        -- Unique: emergency heal to 50% on trigger
        on_trigger = function(ply)
            local half = math.floor(ply:GetMaxHealth() * 0.5)
            if ply:Health() < half then
                ply:SetHealth(half)
            end
        end,
    },
    ["Assault"] = {
        message    = function(n) return n .. ", the relentless soldier, charges forward — alone — for the fallen." end,
        color      = Color(220, 80, 20),
        dmg_bonus  = 0.60,   -- +60% damage
        resistance = 0.20,
        speed      = 0.35,   -- +35% speed — Assault lives for mobility
        regen      = 0.02,
        -- Unique: max out adrenaline stacks immediately
        on_trigger = function(ply)
            local max = ply:Horde_GetMaxAdrenalineStack()
            if max > 0 then
                for _ = 1, max do ply:Horde_AddAdrenalineStack() end
            end
        end,
    },
    ["Heavy"] = {
        message    = function(n) return n .. ", the immovable wall, plants their feet. No one gets through." end,
        color      = Color(60, 140, 255),
        dmg_bonus  = 0.40,
        resistance = 0.55,   -- +55% — Heavy becomes a juggernaut
        speed      = 0.10,
        regen      = 0.03,
        -- Unique: full health restore
        on_trigger = function(ply)
            ply:SetHealth(ply:GetMaxHealth())
        end,
    },
    ["Medic"] = {
        message    = function(n) return n .. ", the field medic with no one left to save, turns their skills on themselves." end,
        color      = Color(60, 230, 100),
        dmg_bonus  = 0.35,
        resistance = 0.25,
        speed      = 0.15,
        regen      = 0.08,   -- +8% HP/sec — Medic's lifeline is regen
        -- Unique: full health restore
        on_trigger = function(ply)
            ply:SetHealth(ply:GetMaxHealth())
        end,
    },
    ["Demolition"] = {
        message    = function(n) return n .. ", the one-person demolition crew, has one payload left. Themselves." end,
        color      = Color(255, 120, 0),
        dmg_bonus  = 0.80,   -- +80% — explosions scale massively
        resistance = 0.20,
        speed      = 0.10,
        regen      = 0.02,
        on_trigger = function(ply) end,
    },
    ["Ghost"] = {
        message    = function(n) return n .. ", the phantom operative, was always meant to work alone." end,
        color      = Color(120, 120, 240),
        dmg_bonus  = 0.70,   -- +70% — Ghost is a precision killer
        resistance = 0.25,
        speed      = 0.20,
        regen      = 0.02,
        -- Unique: grant optical camouflage (invisibility flag)
        on_trigger = function(ply)
            ply:Horde_AddCamouflage(30)
        end,
    },
    ["Engineer"] = {
        message    = function(n) return n .. ", the battlefield engineer, is the last machine still running." end,
        color      = Color(200, 170, 60),
        dmg_bonus  = 0.40,
        resistance = 0.30,
        speed      = 0.15,
        regen      = 0.03,
        on_trigger = function(ply) end,
    },
    ["Berserker"] = {
        message    = function(n) return n .. ", the berserker with nothing left to lose, lets the rage take over." end,
        color      = Color(220, 20, 20),
        dmg_bonus  = 0.75,   -- +75% — Berserker turns pure aggression
        resistance = 0.35,
        speed      = 0.25,
        regen      = 0.03,
        -- Unique: enter berserk state
        on_trigger = function(ply)
            ply:Horde_AddBerserk(9999)
        end,
    },
    ["Warden"] = {
        message    = function(n) return n .. ", the lone warden, holds the line with iron will and nothing else." end,
        color      = Color(160, 100, 230),
        dmg_bonus  = 0.45,
        resistance = 0.40,   -- Warden is naturally tanky
        speed      = 0.15,
        regen      = 0.04,
        on_trigger = function(ply) end,
    },
    ["Cremator"] = {
        message    = function(n) return n .. ", the last cremator standing, will turn this whole battlefield to ash." end,
        color      = Color(255, 50, 0),
        dmg_bonus  = 0.80,   -- +80% — fire damage goes nuclear
        resistance = 0.20,
        speed      = 0.15,
        regen      = 0.02,
        on_trigger = function(ply) end,
    },

    -- ---- Subclasses ----
    ["Psycho"] = {
        message    = function(n) return n .. ", the unhinged psycho, has lost their last reason to hold back." end,
        color      = Color(210, 0, 60),
        dmg_bonus  = 0.70,
        resistance = 0.30,
        speed      = 0.20,
        regen      = 0.04,   -- Psycho heals through carnage
        -- Unique: berserk
        on_trigger = function(ply)
            ply:Horde_AddBerserk(9999)
        end,
    },
    ["Samurai"] = {
        message    = function(n) return n .. ", the honorbound samurai, draws their blade for the last time. Death before defeat." end,
        color      = Color(220, 190, 100),
        dmg_bonus  = 0.75,
        resistance = 0.30,
        speed      = 0.30,   -- Samurai glides across the battlefield
        regen      = 0.02,
        on_trigger = function(ply) end,
    },
    ["Specops"] = {
        message    = function(n) return n .. ", the lone spec-ops agent, goes completely dark. The mission doesn't end here." end,
        color      = Color(40, 190, 190),
        dmg_bonus  = 0.65,
        resistance = 0.25,
        speed      = 0.35,   -- Specops becomes ultra-mobile
        regen      = 0.03,
        -- Unique: camouflage
        on_trigger = function(ply)
            ply:Horde_AddCamouflage(30)
        end,
    },
    ["Necromancer"] = {
        message    = function(n) return n .. ", the necromancer without allies, calls upon the void itself for power." end,
        color      = Color(80, 20, 160),
        dmg_bonus  = 0.80,
        resistance = 0.30,
        speed      = 0.10,
        regen      = 0.03,
        on_trigger = function(ply) end,
    },
    ["Warlock"] = {
        message    = function(n) return n .. ", the warlock unchained, needs no coven. Pure arcane fury." end,
        color      = Color(100, 60, 210),
        dmg_bonus  = 0.80,
        resistance = 0.25,
        speed      = 0.10,
        regen      = 0.03,
        on_trigger = function(ply) end,
    },
    ["Artificer"] = {
        message    = function(n) return n .. ", the artificer of destruction, forges one last miracle from the sun itself." end,
        color      = Color(255, 210, 0),
        dmg_bonus  = 0.75,
        resistance = 0.25,
        speed      = 0.10,
        regen      = 0.03,
        on_trigger = function(ply) end,
    },
    ["Carcass"] = {
        message    = function(n) return n .. ", the adaptive organism, has one directive left: devour everything." end,
        color      = Color(80, 200, 50),
        dmg_bonus  = 0.50,
        resistance = 0.35,
        speed      = 0.25,
        regen      = 0.05,   -- Bio-regeneration kicks into overdrive
        on_trigger = function(ply) end,
    },
    ["Hatcher"] = {
        message    = function(n) return n .. ", the hatcher with no more brood, rises as the apex predator itself." end,
        color      = Color(80, 170, 40),
        dmg_bonus  = 0.60,
        resistance = 0.30,
        speed      = 0.20,
        regen      = 0.04,
        on_trigger = function(ply) end,
    },
    ["Overlord"] = {
        message    = function(n) return n .. ", the overlord without a throne, reclaims dominion with their own two hands." end,
        color      = Color(60, 0, 140),
        dmg_bonus  = 0.90,   -- Overlord is the most powerful caster
        resistance = 0.20,
        speed      = 0.10,
        regen      = 0.02,
        on_trigger = function(ply) end,
    },
    ["Gunslinger"] = {
        message    = function(n) return n .. ", the last gunslinger in the room, makes every bullet a eulogy." end,
        color      = Color(230, 210, 80),
        dmg_bonus  = 0.65,
        resistance = 0.20,
        speed      = 0.25,
        regen      = 0.02,
        on_trigger = function(ply) end,
    },
}

-- Fallback for any class/subclass not explicitly listed
local LMS_DEFAULT = {
    message    = function(n) return n .. " is the last one standing. Make it count." end,
    color      = Color(255, 255, 255),
    dmg_bonus  = 0.40,
    resistance = 0.25,
    speed      = 0.15,
    regen      = 0.02,
    on_trigger = function(ply) end,
}

-- ============================================================
-- Core LMS functions
-- ============================================================

-- Returns the LMS data table for this player's current subclass
local function GetLMSData(ply)
    local subclass = ply:Horde_GetCurrentSubclass()
    return LMS_DATA[subclass] or LMS_DEFAULT
end

-- Count alive human players
local function GetAliveCount()
    local count = 0
    for _, ply in pairs(player.GetHumans()) do
        if ply:IsValid() and ply:Alive() then
            count = count + 1
        end
    end
    return count
end

-- Activate Last Man Standing for a player
local function TriggerLMS(ply)
    if not ply:IsValid() or not ply:Alive() then return end
    if ply.Horde_LastManStanding then return end -- already triggered this wave

    ply.Horde_LastManStanding = true

    local data = GetLMSData(ply)

    -- Apply health regen boost (stacks additively with existing regen)
    local current_regen = ply:Horde_GetHealthRegenPercentage()
    ply:Horde_SetHealthRegenPercentage(current_regen + data.regen)
    ply.Horde_LMS_RegenAdded = data.regen

    -- Store bonuses for hooks to read
    ply.Horde_LMS_DamageBonus  = data.dmg_bonus
    ply.Horde_LMS_Resistance   = data.resistance
    ply.Horde_LMS_SpeedBonus   = data.speed

    -- Run any class-specific on_trigger effect
    if data.on_trigger then
        data.on_trigger(ply)
    end

    local name = ply:GetName()
    local msg  = data.message(name)

    -- Broadcast message to all players + personal notification
    HORDE:SendNotification(name .. " is the last one standing!", 0)
    HORDE:SendNotification("⚡ " .. msg, 1, ply)

    -- Net message to the player for a special HUD flash if desired
    net.Start("Horde_LastManStanding")
        net.WriteBool(true)
        net.WriteString(msg)
        net.WriteUInt(data.color.r, 8)
        net.WriteUInt(data.color.g, 8)
        net.WriteUInt(data.color.b, 8)
    net.Send(ply)
end

-- Remove LMS buffs (called on wave start / player death / reset)
local function RemoveLMS(ply)
    if not ply:IsValid() then return end
    if not ply.Horde_LastManStanding then return end

    ply.Horde_LastManStanding = false

    -- Remove the regen we added
    if ply.Horde_LMS_RegenAdded then
        local regen = ply:Horde_GetHealthRegenPercentage()
        ply:Horde_SetHealthRegenPercentage(math.max(0, regen - ply.Horde_LMS_RegenAdded))
        ply.Horde_LMS_RegenAdded = nil
    end

    ply.Horde_LMS_DamageBonus = nil
    ply.Horde_LMS_Resistance  = nil
    ply.Horde_LMS_SpeedBonus  = nil

    -- Remove berserk if it was given by LMS (we used 9999 duration as a marker)
    -- We don't forcibly remove it — the wave ending handles that naturally.

    net.Start("Horde_LastManStanding")
        net.WriteBool(false)
        net.WriteString("")
        net.WriteUInt(0, 8)
        net.WriteUInt(0, 8)
        net.WriteUInt(0, 8)
    net.Send(ply)
end

-- ============================================================
-- Hooks: apply buffs while LMS is active
-- ============================================================

-- Damage output bonus
hook.Add("Horde_OnPlayerDamage", "Horde_LMS_DamageBonus", function(ply, npc, bonus, hitgroup, dmginfo)
    if not ply.Horde_LastManStanding then return end
    bonus.increase = bonus.increase + (ply.Horde_LMS_DamageBonus or 0)
end)

-- Damage resistance
hook.Add("Horde_OnPlayerDamageTaken", "Horde_LMS_Resistance", function(ply, dmg, bonus)
    if not ply.Horde_LastManStanding then return end
    bonus.resistance = (bonus.resistance or 0) + (ply.Horde_LMS_Resistance or 0)
end)

-- Movement speed bonus
hook.Add("Horde_PlayerMoveBonus", "Horde_LMS_SpeedBonus", function(ply, bonus_walk, bonus_run)
    if not ply.Horde_LastManStanding then return end
    local spd = ply.Horde_LMS_SpeedBonus or 0
    bonus_walk.increase = bonus_walk.increase + spd
    bonus_run.increase  = bonus_run.increase  + spd
end)

-- ============================================================
-- Trigger: Multiplayer — last player alive after a teammate dies
-- ============================================================

hook.Add("PlayerDeath", "Horde_LMS_CheckLastMan", function(victim, inflictor, attacker)
    if not HORDE.start_game then return end
    if HORDE.current_break_time and HORDE.current_break_time > 0 then return end

    -- Defer by one frame so the victim is marked as dead first
    timer.Simple(0.05, function()
        if GetAliveCount() == 1 then
            for _, ply in pairs(player.GetHumans()) do
                if ply:IsValid() and ply:Alive() then
                    TriggerLMS(ply)
                    break
                end
            end
        end
    end)
end)

hook.Add("PlayerSilentDeath", "Horde_LMS_CheckLastManSilent", function(victim)
    if not HORDE.start_game then return end
    if HORDE.current_break_time and HORDE.current_break_time > 0 then return end

    timer.Simple(0.05, function()
        if GetAliveCount() == 1 then
            for _, ply in pairs(player.GetHumans()) do
                if ply:IsValid() and ply:Alive() then
                    TriggerLMS(ply)
                    break
                end
            end
        end
    end)
end)

-- ============================================================
-- Trigger: Solo — cheat death when the single player would die
-- Hooks DoPlayerDeath directly; returning true aborts the kill.
-- ============================================================

hook.Add("DoPlayerDeath", "Horde_LMS_SoloCheatDeath", function(ply, attacker, dmginfo)
    if not HORDE.start_game then return end
    if HORDE.current_break_time and HORDE.current_break_time > 0 then return end

    -- Only applies when playing solo (one human total)
    if #player.GetHumans() ~= 1 then return end

    -- Already triggered this wave — don't cheat death twice
    if ply.Horde_LastManStanding then return end

    -- Survive at 1 HP and trigger LMS
    ply:SetHealth(1)
    TriggerLMS(ply)

    return true -- returning true prevents GMod from killing the player
end)

-- ============================================================
-- Reset: clear LMS state at wave start and on Horde_ResetStatus
-- ============================================================

hook.Add("HordeWaveStart", "Horde_LMS_WaveReset", function(wave)
    for _, ply in pairs(player.GetHumans()) do
        if ply:IsValid() then
            RemoveLMS(ply)
            ply.Horde_LastManStanding = false
        end
    end
end)

hook.Add("Horde_ResetStatus", "Horde_LMS_StatusReset", function(ply)
    ply.Horde_LastManStanding   = false
    ply.Horde_LMS_DamageBonus  = nil
    ply.Horde_LMS_Resistance   = nil
    ply.Horde_LMS_SpeedBonus   = nil
    ply.Horde_LMS_RegenAdded   = nil
end)
