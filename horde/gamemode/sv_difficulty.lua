-- Difficulty settings
-- Rule: scale as difficulty/endless.
-- 0 - normal, 1 - hard, 2 - realism

HORDE.difficulty = GetConVar("horde_difficulty"):GetInt() + 1
HORDE.endless = GetConVar("horde_endless"):GetInt()
HORDE.additional_pack = 0

-- Difficulty Stuff

local difficulty_normal = 0
local difficulty_hard = 1
local difficulty_realism = 2
local difficulty_nightmare = 3
local difficulty_apocalypse = 4
local difficulty_malice = 5

-- Multipliers
local difficulty_damage_multiplier = { 1, 1.25, 1.5, 1.7, 1.9, 2.66 }
local difficulty_enemy_count_multiplier = { 1, 1.3, 1.5, 1.6, 1.7, 2.38 }
HORDE.difficulty_reward_base_multiplier = { 1, 0.8, 0.6, 0.5, 0.4, 0.286 }
HORDE.difficulty_health_multiplier = { 1, 1.25, 1.5, 1.5, 1.5, 2.1 }
local difficulty_start_money_multiplier = { 1, 0.9, 0.8, 0.75, 0.6, 0.429 }
local difficulty_spawn_radiuis_multiplier = { 1, 0.75, 0.5, 0.5, 0.4, 0.286 }
local difficulty_max_enemies_alive_scale_factor = { 1, 1.15, 1.25, 1.25, 1.3, 1.82 }
local difficulty_poison_headcrab_damage = { 50, 60, 75, 75, 75, 105 }
HORDE.difficulty_status_duration_bonus = { 0, 1, 2, 3, 4, 6 }
HORDE.difficulty_break_health_left = { 0.20, 0.15, 0.10, 0.10, 0.05, 0.036 }
HORDE.difficulty_shock_damage_increase = { 0.15, 0.20, 0.25, 0.25, 0.30, 0.42 }
HORDE.difficulty_frostbite_slow = { 0.40, 0.45, 0.50, 0.50, 0.55, 0.77 }

-- Flat modifiers
HORDE.difficulty_elite_health_scale_add = { 0.025, 0.05, 0.075, 0.100, 0.125, 0.175 }
HORDE.difficulty_elite_health_scale_multiplier = { 1, 1, 1, 1.1, 1.2, 1.68 }
HORDE.difficulty_additional_pack = { 0, 1, 2, 2, 3, 4 }
HORDE.difficulty_additional_ammoboxes = { 2, 1, 0, 0, 0, 0 }

-- Endless stuff
HORDE.endless_health_multiplier = 1
HORDE.endless_damage_multiplier = 1

-- Mutation
HORDE.difficulty_mutation_probability = { 0, 0.05, 0.10, 0.20, 0.30, 0.42 }
HORDE.difficulty_elite_mutation_probability = { 0, 0.05, 0.10, 0.30, 0.40, 0.56 }

-- Hook settings
-- Damage scaling/handling
-- Turrets should not be one-shot
function VJ_DestroyCombineTurret() end

hook.Add("EntityTakeDamage", "Horde_EntityTakeDamage", function(target, dmg)
    if not target:IsValid() then return end
    if target:IsPlayer() then
        if dmg:GetAttacker():IsNPC() then
            if dmg:GetAttacker():GetNWEntity("HordeOwner"):IsPlayer() then
                -- Prevent minions from hurting players
                return true
            end
            if dmg:IsDamageType(DMG_CRUSH) then
                -- Cap bullshit physics damage that can sometimes occur
                dmg:SetDamage(math.min(dmg:GetDamage(), 20))
            end

            if HORDE.endless == 1 then
                dmg:ScaleDamage(difficulty_damage_multiplier[HORDE.difficulty] * HORDE.endless_damage_multiplier)
            else
                dmg:ScaleDamage(difficulty_damage_multiplier[HORDE.difficulty])
            end

            if dmg:GetAttacker():GetVar("damage_scale") then
                dmg:ScaleDamage(dmg:GetAttacker():GetVar("damage_scale"))
            end
        elseif dmg:GetAttacker():IsPlayer() and dmg:GetAttacker() ~= target then
            -- Prevent PVP
            return true
        elseif dmg:IsDamageType(DMG_CRUSH) then
            dmg:SetDamage(math.min(dmg:GetDamage(), 20))
        end
    elseif HORDE:IsPlayerMinion(target) then
        if dmg:GetAttacker():IsPlayer() or HORDE:IsPlayerMinion(dmg:GetAttacker()) then
            -- Prevent player / player minions from damaging minions
            return true
        else
            if dmg:GetAttacker():GetClass() == "npc_headcrab_poison" then
                dmg:SetDamage(math.min(dmg:GetDamage(), difficulty_poison_headcrab_damage[HORDE.difficulty]))
            end

            if target:GetClass() == "npc_turret_floor" then
                dmg:SetDamageForce(Vector(0, 0, 0))
                target:SetHealth(target:Health() - dmg:GetDamage())
                if target:Health() <= 0 then
                    target:Fire("selfdestruct")
                end
            end

            if HORDE.endless == 1 then
                dmg:ScaleDamage(difficulty_damage_multiplier[HORDE.difficulty] * HORDE.endless_damage_multiplier)
            else
                dmg:ScaleDamage(difficulty_damage_multiplier[HORDE.difficulty])
            end

            if dmg:GetAttacker():GetVar("damage_scale") then
                dmg:ScaleDamage(dmg:GetAttacker():GetVar("damage_scale"))
            end
        end
    elseif target:IsNPC() then
        if not dmg:GetAttacker():IsNPC() then return end
        if target:GetClass() == dmg:GetAttacker() and dmg:GetAttacker() == dmg:GetInflictor() then return true end
        if dmg:IsDamageType(DMG_POISON) and dmg:GetAttacker():GetClass() == "npc_headcrab_poison" then
            dmg:SetDamage(0)
        elseif dmg:IsDamageType(DMG_SHOCK) or dmg:IsDamageType(DMG_REMOVENORAGDOLL) then
            local c = dmg:GetAttacker():GetClass()
            if c == "npc_vj_horde_screecher" or c == "npc_vj_horde_weeper" then
                dmg:SetDamage(0)
            end
        end
    end
end)

-- Fall damage handling
hook.Add("GetFallDamage", "RealisticDamage", function(ply, speed)
    local bonus = { less = 1 }
    local dmg = 0
    if HORDE.difficulty == difficulty_normal then
        dmg = 10
    elseif HORDE.difficulty == difficulty_hard then
        dmg = math.max(0, math.ceil(0.2418 * speed - 141.75)) / 2
    else
        -- css fall damage
        dmg = math.max(0, math.ceil(0.2418 * speed - 141.75))
    end

    hook.Run("Horde_GetFallDamage", ply, speed, bonus)
    return dmg * bonus.less
end)

-- Non-hook settings - store base values so they can be rescaled when difficulty changes at runtime
HORDE._base_total_enemies = {}
for i, v in ipairs(HORDE.total_enemies_per_wave) do HORDE._base_total_enemies[i] = v end
HORDE._base_kill_reward   = HORDE.kill_reward_base
HORDE._base_round_bonus   = HORDE.round_bonus_base
HORDE._base_start_money   = HORDE.start_money
HORDE._base_spawn_radius  = HORDE.spawn_radius

function HORDE:ApplyDifficultyScaling()
    local diff = HORDE.difficulty
    -- Wave count scaling
    for i, v in ipairs(HORDE._base_total_enemies) do
        HORDE.total_enemies_per_wave[i] = math.floor(v * difficulty_enemy_count_multiplier[diff])
    end
    -- Kill reward scaling
    HORDE.kill_reward_base = math.floor(HORDE._base_kill_reward * HORDE.difficulty_reward_base_multiplier[diff])
    HORDE.round_bonus_base = math.floor(HORDE._base_round_bonus * HORDE.difficulty_reward_base_multiplier[diff])
    -- Start money scaling
    HORDE.start_money = math.floor(HORDE._base_start_money * difficulty_start_money_multiplier[diff])
    -- Spawn density scaling
    HORDE.spawn_radius = math.floor(HORDE._base_spawn_radius * difficulty_spawn_radiuis_multiplier[diff])
    -- Maximum enemies alive scaling
    HORDE.difficulty_max_enemies_alive_scale_factor = difficulty_max_enemies_alive_scale_factor[diff]
end

HORDE:ApplyDifficultyScaling()

-- Server: receive a difficulty change request from any player
util.AddNetworkString("Horde_RequestDifficulty")

-- Difficulty index of MALICE (1-indexed, matches HORDE.difficulty_text)
local DIFFICULTY_MALICE = 6

net.Receive("Horde_RequestDifficulty", function(len, ply)
    local new_diff = net.ReadUInt(4)
    if new_diff < 1 or new_diff > #HORDE.difficulty_text then return end

    -- MALICE requires at least Skilled rank on any class/subclass.
    if new_diff == DIFFICULTY_MALICE then
        if not HORDE:PlayerMeetsRank(ply, HORDE.Rank_Skilled) then
            HORDE:SendNotification(
                "MALICE difficulty requires at least Skilled rank on any class or subclass.",
                1, ply)
            return
        end
    end

    HORDE.difficulty = new_diff
    GetConVar("horde_difficulty"):SetInt(new_diff - 1)
    HORDE:ApplyDifficultyScaling()
    -- Broadcast new difficulty to all players
    net.Start("Horde_SyncDifficulty")
        net.WriteUInt(HORDE.difficulty, 4)
    net.Broadcast()
    print("[Horde] Difficulty changed to " .. HORDE.difficulty_text[HORDE.difficulty] .. " by " .. ply:Name())
end)
