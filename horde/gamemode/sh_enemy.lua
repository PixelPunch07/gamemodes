-- Enemies
HORDE.enemies = {}
HORDE.bosses = {}
HORDE.enemies_normalized = {}
HORDE.bosses_normalized = {}

-- Active waveset: "default" or "xeno". Synced to clients via Horde_WavesetChanged.
HORDE.waveset = "default"

-- Creates a Horde enemy.
function HORDE:CreateEnemy(name, class, weight, wave, is_elite, health_scale, damage_scale, reward_scale, model_scale, color, weapon, spawn_limit, boss_properties, mutation, skin, model, spawn_min, gadget_drop)
    if name == nil or class == nil or wave == nil or wave <= 0 or name == "" or class == "" then return end
    local enemy = {}
    enemy.name = name
    enemy.class = class
    enemy.weight = math.max(0,weight)
    enemy.wave = math.max(1,wave)
    enemy.health_scale = health_scale and health_scale or 1
    enemy.damage_scale = damage_scale and damage_scale or 1
    enemy.reward_scale = reward_scale and reward_scale or 1
    enemy.model_scale = model_scale and model_scale or 1
    enemy.color = color
    enemy.weapon = weapon
    enemy.spawn_limit = spawn_limit or 0
    enemy.is_elite = is_elite and is_elite or 0
    enemy.boss_properties = boss_properties and boss_properties or {}
    enemy.spawn_min = spawn_min or 0
    -- Prevent infinite rounds
    if enemy.boss_properties then
        if enemy.boss_properties.unlimited_enemies_spawn and (not enemy.boss_properties.end_wave) then
            enemy.boss_properties.end_wave = true
        end
    end
    enemy.mutation = mutation or nil
    if skin and skin ~= "" then
        enemy.skin = skin
    end
    enemy.gadget_drop = gadget_drop or nil
    if model and model ~= "" then enemy.model = model end

    HORDE.enemies[name .. tostring(enemy.wave)] = enemy
end

function HORDE:NormalizeEnemiesWeightOnWave(enemies)
    local total_weight = 0
    for name, weight in pairs(enemies) do
        total_weight = total_weight + weight
    end
    for name, weight in pairs(enemies) do
        enemies[name] = weight / total_weight
    end
end

function HORDE:GetForcedEnemiesOnWave(enemies, enemy_wave, total_enemies)
    local forced = {}
    for name, _ in pairs(enemies) do
        local enemy = HORDE.enemies[name .. tostring(enemy_wave)]
        if enemy.spawn_min and enemy.spawn_min > 0 then
            forced[name] = {}
            for i = 1, enemy.spawn_min do
                table.insert(forced[name], math.random(1, total_enemies))
            end
        end
    end
    return forced
end

function HORDE:NormalizeEnemiesWeight()
    if table.IsEmpty(HORDE.enemies) then return end

    for _, enemy in pairs(HORDE.enemies) do
        if enemy.boss_properties and enemy.boss_properties.is_boss and enemy.boss_properties.is_boss == true then
            if not HORDE.bosses[enemy.wave] then HORDE.bosses[enemy.wave] = {} end
            HORDE.bosses[enemy.name .. enemy.wave] = enemy
        end
    end

    for wave = 1, HORDE.max_max_waves do
        HORDE.enemies_normalized[wave] = {}
        local total_weight = 0
        for _, enemy in pairs(HORDE.enemies) do
            if enemy.boss_properties and enemy.boss_properties.is_boss and enemy.boss_properties.is_boss == true then
                goto cont
            end
            if enemy.wave == wave then
                total_weight = total_weight + enemy.weight
            end
            ::cont::
        end
        for _, enemy in pairs(HORDE.enemies) do
            if enemy.boss_properties and enemy.boss_properties.is_boss and enemy.boss_properties.is_boss == true then
                goto cont
            end
            if enemy.wave == wave then
                -- For some reason lua table key does not support nested tables lmao
                HORDE.enemies_normalized[wave][enemy.name] = enemy.weight / total_weight
            end
            ::cont::
        end
    end

    for wave = 1, HORDE.max_max_waves do
        HORDE.bosses_normalized[wave] = {}
        local total_weight = 0
        for _, enemy in pairs(HORDE.bosses) do
            if enemy.wave == wave then
                total_weight = total_weight + enemy.weight
            end
        end
        for _, enemy in pairs(HORDE.bosses) do
            if enemy.wave == wave then
                HORDE.bosses_normalized[wave][enemy.name] = enemy.weight / total_weight
            end
        end
    end

end

HORDE.InvalidateHordeEnemyCache = 1
HORDE.CachedHordeEnemies = nil
HORDE.GetCachedHordeEnemies = function()
    if HORDE.InvalidateHordeEnemyCache == 1 then
        local tab = util.TableToJSON(HORDE.enemies)
        local str = util.Compress(tab)
        HORDE.CachedHordeEnemies = str
        HORDE.InvalidateHordeEnemyCache = 0
    end
    return HORDE.CachedHordeEnemies
end

function HORDE:SyncEnemiesTo(ply)
    local str = HORDE.GetCachedHordeEnemies()
    net.Start("Horde_SyncEnemies")
        net.WriteUInt(string.len(str), 32)
        net.WriteData(str, string.len(str))
    net.Send(ply)
end

function HORDE:SyncMutationsTo(ply)
    net.Start("Horde_SyncMutations")
        -- Send the client simplified mutations
        local muts = {}
        for mut_name, mut in pairs(HORDE.mutations) do
            muts[mut_name] = mut.Description
        end
        net.WriteTable(muts)
    net.Send(ply)
end

function HORDE:SetEnemiesData()
    if SERVER then
        HORDE:NormalizeEnemiesWeight()

        if GetConVarNumber("horde_default_enemy_config") == 1 then return end
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
        end

        file.Write("horde/enemies.txt", util.TableToJSON(HORDE.enemies))
    end
end

local function GetEnemiesData()
    if SERVER then
        if not file.IsDir("horde", "DATA") then
            file.CreateDir("horde")
            return
        end

        if file.Read("horde/enemies.txt", "DATA") then
            local t = util.JSONToTable(file.Read("horde/enemies.txt", "DATA"))
            -- Integrity
            for _, enemy in pairs(t) do
                if enemy.name == nil or enemy.name == "" or enemy.class == nil or enemy.class == "" or enemy.weight == nil or enemy.wave == nil then
                    HORDE:SendNotification("Enemy config file validation failed! Please update your file or delete it.", 0)
                    return
                else
                    if not enemy.weapon then
                        enemy.weapon = ""
                    end
                end
            end

            -- Be careful of backwards compataiblity
            HORDE.enemies = t
            HORDE:NormalizeEnemiesWeight()

            print("[HORDE] - Loaded custom enemy config.")
        end
    end
end

function HORDE:GetDefaultEnemiesData ()
    -- name, class, weight, wave, elite, health_scale, damage_scale, reward_scale, model_scale, color
    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  1, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.85,  1, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Headcrab Zombie Torso", "npc_zombie_torso",          0.30,  1, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Zombie Torso", "npc_vj_zss_crabless_torso",             0.30,  1, false, 0.5, 1, 1, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.25,  1, true, 1, 1, 1.25, 1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  2, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  2, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  2, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  2, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.20,  2, true, 1, 1, 1.25, 1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  3, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  3, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  3, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  3, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.20,  3, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.20,  3, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.15,  3, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  4, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  4, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  4, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  4, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.20,  4, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.20,  4, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.15,  4, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.15,  4, true, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  5, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  5, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  5, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  5, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.20,  5, false, 1, 1.1, 1, 1)
    HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.15,  5, false, 1, 1.1, 1, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.20,  5, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.15,  5, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.15,  5, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Mutated Hulk",  "npc_vj_mutated_hulk",       1, 5, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=1.0, music="music/hl2_song20_submix0.mp3", music_duration=104}, nil, nil, nil, nil, {gadget="gadget_unstable_injection", drop_rate=0.5})
    HORDE:CreateEnemy("Plague Berserker","npc_vj_horde_platoon_berserker",    0.35, 5, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.75, music="music/hl2_song19.mp3", music_duration=115})
    HORDE:CreateEnemy("Plague Heavy","npc_vj_horde_platoon_heavy",    0.35, 5, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.75, music="music/hl2_song3.mp3", music_duration=91})
    HORDE:CreateEnemy("Plague Demolition","npc_vj_horde_platoon_demolitionist",    0.35, 5, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.75, music="music/hl2_song19.mp3", music_duration=115})
    HORDE:CreateEnemy("Hell Knight",  "npc_vj_horde_hellknight",    1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.5, music="music/hl2_song3.mp3", music_duration=91}, "none", nil, nil, nil, {gadget="gadget_hellfire_tincture", drop_rate=0.5})
    HORDE:CreateEnemy("Xen Host Unit","npc_vj_horde_xen_host_unit", 1, 5, true, 1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.5, music="music/hl2_song20_submix0.mp3", music_duration=104}, "none", nil, nil, nil, {gadget="gadget_matriarch_womb", drop_rate=0.5})

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  6, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  6, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  6, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  6, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.20,  6, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.10,  6, false, 1, 1, 1.1, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.05,  6, false, 1, 1, 1.1, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.20,  6, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.10,  6, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.05,  6, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.15,  6, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.05,  6, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  7, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  7, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  7, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  7, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.15,  7, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.08,  7, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.06,  7, false, 1, 1, 1.1, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Plague Soldier", "npc_vj_horde_plague_soldier",      0.05,  7, false, 1, 1, 1.25, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.15,  7, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Blight", "npc_vj_horde_blight",                      0.05,  7, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.10,  7, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.05,  7, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.15,  7, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.04,  7, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Lesion", "npc_vj_horde_lesion",                      0.03,  7, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  8, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  8, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  8, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  8, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.15,  8, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.08,  8, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.06,  8, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Plague Soldier", "npc_vj_horde_plague_soldier",      0.05,  8, false, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.15,  8, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Blight", "npc_vj_horde_blight",                      0.05,  8, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.10,  8, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.05,  8, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.10,  8, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Weeper","npc_vj_horde_weeper",                       0.05,  8, true, 1, 1, 1.5, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.04,  8, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Yeti",   "npc_vj_horde_yeti",                        0.02,  8, true, 1, 1, 3, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Lesion", "npc_vj_horde_lesion",                      0.03,  8, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)

    HORDE:CreateEnemy("Walker", "npc_vj_horde_walker",                      1.00,  9, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Sprinter", "npc_vj_horde_sprinter",                  0.80,  9, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Crawler",    "npc_vj_horde_crawler",                 0.40,  9, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Fast Zombie",      "npc_fastzombie",                 0.20,  9, false, 0.75, 1, 1, 1)
    HORDE:CreateEnemy("Poison Zombie",  "npc_poisonzombie",                 0.15,  9, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Zombine", "npc_vj_horde_zombine",                    0.08,  9, false, 1, 1, 1, 1)
    HORDE:CreateEnemy("Charred Zombine", "npc_vj_horde_charred_zombine",    0.06,  9, false, 1, 1, 1.1, 1)
    HORDE:CreateEnemy("Plague Soldier", "npc_vj_horde_plague_soldier",      0.05,  9, false, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Exploder", "npc_vj_horde_exploder",                  0.15,  9, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Blight", "npc_vj_horde_blight",                      0.05,  9, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Vomitter", "npc_vj_horde_vomitter",                  0.10,  9, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Scorcher", "npc_vj_horde_scorcher",                  0.05,  9, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Screecher","npc_vj_horde_screecher",                 0.10,  9, true, 1, 1, 1.25, 1)
    HORDE:CreateEnemy("Weeper","npc_vj_horde_weeper",                       0.05,  9, true, 1, 1, 1.5, 1)
    HORDE:CreateEnemy("Hulk",   "npc_vj_horde_hulk",                        0.03,  9, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Yeti",   "npc_vj_horde_yeti",                        0.02,  9, true, 1, 1, 3, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Lesion", "npc_vj_horde_lesion",                      0.02,  9, true, 1, 1, 2, 1, nil,nil,nil,nil,nil,nil,nil,1)
    HORDE:CreateEnemy("Plague Elite", "npc_vj_horde_plague_elite",          0.015,  9, true, 1, 1, 3, 1, nil,nil,nil,nil,nil,nil,nil,1)

    HORDE:CreateEnemy("zombie vj",        "npc_vj_zss_crabless_slow",1,    10, false, 1, 1, 1, 1, nil)
    HORDE:CreateEnemy("zombie fast",      "npc_fastzombie",          1,    10, false, 1, 1, 1, 1, nil)
    HORDE:CreateEnemy("zombie poison",    "npc_poisonzombie",        0.5,  10, false, 1, 1, 1, 1, nil)
    HORDE:CreateEnemy("Alpha Gonome",     "npc_vj_alpha_gonome",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song24.mp3", music_duration=77}, "fume")
    HORDE:CreateEnemy("Gamma Gonome",     "npc_vj_horde_gamma_gonome",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song15.mp3", music_duration=120}, "none")
    HORDE:CreateEnemy("Subject: Wallace Breen",    "npc_vj_horde_breen",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song21.mp3", music_duration=84}, "decay")
    HORDE:CreateEnemy("Xen Destroyer Unit","npc_vj_horde_xen_destroyer_unit",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song15.mp3", music_duration=120}, "none")
    HORDE:CreateEnemy("Xen Psychic Unit","npc_vj_horde_xen_psychic_unit",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song21.mp3", music_duration=84}, "regenerator")
    HORDE:CreateEnemy("Plague Platoon","npc_vj_horde_plague_platoon",     1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song24.mp3", music_duration=84}, "none")
    HORDE:CreateEnemy("Calmaticus",   "npc_vj_horde_xeno_calmaticus",    1,    10, true,  1, 1, 10, 1, nil, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="zombiesurvival/xeno_raid/genesis_of_the_virus.mp3", music_duration=185}, "none")

    HORDE:NormalizeEnemiesWeight()

    print("[HORDE] - Loaded default enemy config.")
end

-- =============================================================================
-- XENO WAVESET
-- All enemies replaced with xeno variants where available.
-- Enemies without a dedicated xeno NPC keep their original class but are tinted
-- green (Color(50, 220, 80)) so they are visually distinct.
-- =============================================================================
local XENO_GREEN = Color(50, 220, 80)

function HORDE:GetXenoEnemiesData()
    -- Wave 1
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  1, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.85,  1, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Headcrab Zombie Torso","npc_zombie_torso",                  0.30,  1, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Zombie Torso",         "npc_vj_zss_crabless_torso",         0.30,  1, false, 0.5, 1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.25,  1, true,  1,   1,   1.25, 1, XENO_GREEN)

    -- Wave 2
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  2, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  2, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  2, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  2, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.20,  2, true,  1,   1,   1.25, 1, XENO_GREEN)

    -- Wave 3
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  3, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  3, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  3, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  3, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.20,  3, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.20,  3, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.15,  3, true,  1,   1,   1.25, 1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 4
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  4, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  4, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  4, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  4, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.20,  4, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.20,  4, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.15,  4, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.15,  4, true,  1,   1,   1.25, 1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 5
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  5, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  5, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  5, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  5, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.20,  5, false, 1,   1.1, 1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Zombine",              "npc_vj_horde_xeno_zombine",         0.15,  5, false, 1,   1.1, 1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.20,  5, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.15,  5, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.15,  5, true,  1,   1,   1.25, 1, XENO_GREEN)
    -- Wave 5 bosses (xeno variants where available, green tint on all)
    HORDE:CreateEnemy("Mutated Hulk",         "npc_vj_horde_xeno_mutated_hulk",    1,     5, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=1.0, music="music/hl2_song20_submix0.mp3", music_duration=104}, nil, nil, nil, nil, {gadget="gadget_unstable_injection", drop_rate=0.5})
    HORDE:CreateEnemy("Plague Berserker",     "npc_vj_horde_platoon_berserker",    0.35,  5, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.75, music="music/hl2_song19.mp3", music_duration=115})
    HORDE:CreateEnemy("Plague Heavy",         "npc_vj_horde_platoon_heavy",        0.35,  5, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.75, music="music/hl2_song3.mp3", music_duration=91})
    HORDE:CreateEnemy("Plague Demolition",    "npc_vj_horde_platoon_demolitionist",0.35,  5, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.75, music="music/hl2_song19.mp3", music_duration=115})
    HORDE:CreateEnemy("Hell Knight",          "npc_vj_horde_hellknight",           1,     5, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.5, music="music/hl2_song3.mp3", music_duration=91}, "none", nil, nil, nil, {gadget="gadget_hellfire_tincture", drop_rate=0.5})
    HORDE:CreateEnemy("Xen Host Unit",        "npc_vj_horde_xen_host_unit",        1,     5, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=false, enemies_spawn_threshold=0.5, music="music/hl2_song20_submix0.mp3", music_duration=104}, "none", nil, nil, nil, {gadget="gadget_matriarch_womb", drop_rate=0.5})

    -- Wave 6
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  6, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  6, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  6, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  6, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.20,  6, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Zombine",              "npc_vj_horde_xeno_zombine",         0.10,  6, false, 1,   1,   1.1,  1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Charred Zombine",      "npc_vj_horde_xeno_charred_zombine", 0.05,  6, false, 1,   1,   1.1,  1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.20,  6, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.10,  6, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Scorcher",             "npc_vj_horde_scorcher",             0.05,  6, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.15,  6, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Hulk",                 "npc_vj_horde_xeno_hulk",            0.05,  6, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 7
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  7, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  7, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  7, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  7, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.15,  7, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Zombine",              "npc_vj_horde_xeno_zombine",         0.08,  7, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Charred Zombine",      "npc_vj_horde_xeno_charred_zombine", 0.06,  7, false, 1,   1,   1.1,  1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Plague Soldier",       "npc_vj_horde_xeno_plague_soldier",  0.05,  7, false, 1,   1,   1.25, 1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.15,  7, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Blight",               "npc_vj_horde_xeno_blight",          0.05,  7, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.10,  7, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Scorcher",             "npc_vj_horde_scorcher",             0.05,  7, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.15,  7, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Hulk",                 "npc_vj_horde_xeno_hulk",            0.04,  7, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Lesion",               "npc_vj_horde_xeno_lesion",          0.03,  7, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 8
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  8, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  8, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  8, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  8, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.15,  8, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Zombine",              "npc_vj_horde_xeno_zombine",         0.08,  8, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Charred Zombine",      "npc_vj_horde_xeno_charred_zombine", 0.06,  8, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Plague Soldier",       "npc_vj_horde_xeno_plague_soldier",  0.05,  8, false, 1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.15,  8, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Blight",               "npc_vj_horde_xeno_blight",          0.05,  8, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.10,  8, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Scorcher",             "npc_vj_horde_scorcher",             0.05,  8, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.10,  8, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Weeper",               "npc_vj_horde_xeno_weeper",          0.05,  8, true,  1,   1,   1.5,  1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Hulk",                 "npc_vj_horde_xeno_hulk",            0.04,  8, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Yeti",                 "npc_vj_horde_yeti",                 0.02,  8, true,  1,   1,   3,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Lesion",               "npc_vj_horde_xeno_lesion",          0.03,  8, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 9
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00,  9, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80,  9, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40,  9, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Fast Zombie",          "npc_fastzombie",                    0.20,  9, false, 0.75,1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Poison Zombie",        "npc_poisonzombie",                  0.15,  9, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Zombine",              "npc_vj_horde_xeno_zombine",         0.08,  9, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Charred Zombine",      "npc_vj_horde_xeno_charred_zombine", 0.06,  9, false, 1,   1,   1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Plague Soldier",       "npc_vj_horde_xeno_plague_soldier",  0.05,  9, false, 1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.15,  9, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Blight",               "npc_vj_horde_xeno_blight",          0.05,  9, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.10,  9, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Scorcher",             "npc_vj_horde_scorcher",             0.05,  9, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.10,  9, true,  1,   1,   1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Weeper",               "npc_vj_horde_xeno_weeper",          0.05,  9, true,  1,   1,   1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Hulk",                 "npc_vj_horde_xeno_hulk",            0.03,  9, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Yeti",                 "npc_vj_horde_yeti",                 0.02,  9, true,  1,   1,   3,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Lesion",               "npc_vj_horde_xeno_lesion",          0.02,  9, true,  1,   1,   2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Plague Elite",         "npc_vj_horde_xeno_plague_elite",    0.015, 9, true,  1,   1,   3,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 10
    HORDE:CreateEnemy("zombie vj",            "npc_vj_zss_crabless_slow",          1,    10, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("zombie fast",          "npc_fastzombie",                    1,    10, false, 1,   1,   1,    1, XENO_GREEN)
    HORDE:CreateEnemy("zombie poison",        "npc_poisonzombie",                  0.5,  10, false, 1,   1,   1,    1, XENO_GREEN)
    -- Wave 10 bosses
    HORDE:CreateEnemy("Alpha Gonome",         "npc_vj_horde_xeno_alpha_gonome",    1,    10, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song24.mp3", music_duration=77}, "fume")
    HORDE:CreateEnemy("Gamma Gonome",         "npc_vj_horde_xeno_gamma_gonome",    1,    10, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song15.mp3", music_duration=120}, "none")
    HORDE:CreateEnemy("Subject: Wallace Breen","npc_vj_horde_breen",               1,    10, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song21.mp3", music_duration=84}, "decay")
    HORDE:CreateEnemy("Xen Destroyer Unit",   "npc_vj_horde_xen_destroyer_unit",   1,    10, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song15.mp3", music_duration=120}, "none")
    HORDE:CreateEnemy("Xen Psychic Unit",     "npc_vj_horde_xen_psychic_unit",     1,    10, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song21.mp3", music_duration=84}, "regenerator")
    HORDE:CreateEnemy("Plague Platoon",       "npc_vj_horde_xeno_plague_platoon",  1,    10, true,  1,   1,   10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song24.mp3", music_duration=84}, "none")

    -- Wave 11 — deepening xeno infestation, heavy elite pressure
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00, 11, false, 1,    1,    1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80, 11, false, 1,    1,    1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Crawler",              "npc_vj_horde_xeno_crawler",         0.40, 11, false, 1,    1,    1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Zombine",              "npc_vj_horde_xeno_zombine",         0.10, 11, false, 1,    1,    1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Charred Zombine",      "npc_vj_horde_xeno_charred_zombine", 0.08, 11, false, 1,    1,    1.1,  1, XENO_GREEN)
    HORDE:CreateEnemy("Plague Soldier",       "npc_vj_horde_xeno_plague_soldier",  0.07, 11, false, 1,    1.1,  1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Exploder",             "npc_vj_horde_xeno_exploder",        0.15, 11, true,  1,    1,    1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Blight",               "npc_vj_horde_xeno_blight",          0.07, 11, true,  1,    1,    1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Vomitter",             "npc_vj_horde_xeno_vomitter",        0.10, 11, true,  1,    1,    1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Scorcher",             "npc_vj_horde_scorcher",             0.06, 11, true,  1,    1,    1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Screecher",            "npc_vj_horde_xeno_screecher",       0.10, 11, true,  1,    1,    1.25, 1, XENO_GREEN)
    HORDE:CreateEnemy("Weeper",               "npc_vj_horde_xeno_weeper",          0.07, 11, true,  1,    1,    1.5,  1, XENO_GREEN)
    HORDE:CreateEnemy("Hulk",                 "npc_vj_horde_xeno_hulk",            0.05, 11, true,  1,    1,    2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Lesion",               "npc_vj_horde_xeno_lesion",          0.04, 11, true,  1,    1,    2,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Plague Elite",         "npc_vj_horde_xeno_plague_elite",    0.03, 11, true,  1,    1.1,  3,    1, XENO_GREEN, nil, nil, nil, nil, nil, nil, 1)

    -- Wave 12 — FINAL WAVE. Calmaticus is the sole boss.
    -- A thin xeno vanguard fills the field while the Heart of the Virus approaches.
    HORDE:CreateEnemy("Walker",               "npc_vj_horde_xeno_walker",          1.00, 12, false, 1.2,  1.1,  1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Sprinter",             "npc_vj_horde_xeno_sprinter",        0.80, 12, false, 1.2,  1.1,  1,    1, XENO_GREEN)
    HORDE:CreateEnemy("Hulk",                 "npc_vj_horde_xeno_hulk",            0.08, 12, false, 1.2,  1.1,  2,    1, XENO_GREEN)
    HORDE:CreateEnemy("Plague Elite",         "npc_vj_horde_xeno_plague_elite",    0.05, 12, false, 1.2,  1.1,  3,    1, XENO_GREEN)
    -- The Heart of the Xeno Virus
    HORDE:CreateEnemy("Calmaticus",           "npc_vj_horde_xeno_calmaticus",      1,    12, true,  1,    1,    10,   1, XENO_GREEN, nil, nil,
    {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="zombiesurvival/xeno_raid/genesis_of_the_virus.mp3", music_duration=185}, "none")

    HORDE:NormalizeEnemiesWeight()

    print("[HORDE] - Loaded xeno enemy config.")
end

-- Helper: resets the enemy tables and reloads based on the current waveset string.
-- Call this server-side whenever HORDE.waveset changes.
local function ReloadEnemiesByWaveset(waveset)
    HORDE.enemies = {}
    HORDE.bosses = {}
    HORDE.enemies_normalized = {}
    HORDE.bosses_normalized = {}

    if waveset == "xeno" then
        HORDE.max_waves = 12
        HORDE:GetXenoEnemiesData()
    elseif waveset == "sea_infection" then
        HORDE.max_waves = 11   -- 10 regular + wave 11 boss (Thymicgthys)
        HORDE:GetSeaInfectionEnemiesData()
    else
        -- Respect horde_max_wave convar but cap at 10 for default
        HORDE.max_waves = math.min(10, math.max(1, GetConVarNumber("horde_max_wave")))
        HORDE:GetDefaultEnemiesData()
    end

    HORDE.InvalidateHordeEnemyCache = 1
end

-- Startup
if SERVER then
    util.AddNetworkString("Horde_SetEnemiesData")
    util.AddNetworkString("Horde_SetWaveset")
    util.AddNetworkString("Horde_WavesetChanged")
    util.AddNetworkString("Horde_XenoFogStart")
    util.AddNetworkString("Horde_XenoFogEnd")
    util.AddNetworkString("Horde_XenoAdaptationSync")
    util.AddNetworkString("Horde_SeaFogStart")
    util.AddNetworkString("Horde_SeaFogEnd")

    if GetConVar("horde_external_lua_config"):GetString() and GetConVar("horde_external_lua_config"):GetString() ~= "" then
    else
        if GetConVarNumber("horde_default_enemy_config") == 1 then
            HORDE:GetDefaultEnemiesData()
        else
            GetEnemiesData()
        end
    end

    -- Manual enemy data push from Enemy Config editor (existing behavior).
    net.Receive("Horde_SetEnemiesData", function (len, ply)
        if not ply:IsSuperAdmin() then return end
        local enemies_len = net.ReadUInt(32)
        local data = net.ReadData(enemies_len)
        local str = util.Decompress(data)
        HORDE.enemies = util.JSONToTable(str)
        HORDE.InvalidateHordeEnemyCache = 1
        HORDE:SetEnemiesData()
    end)

    -- Waveset selection request from any admin.
    net.Receive("Horde_SetWaveset", function(len, ply)
        if not ply:IsAdmin() then return end

        local requested = net.ReadString()
        if requested ~= "default" and requested ~= "xeno" and requested ~= "sea_infection" then return end

        -- Xeno waveset requires at least Amateur rank on any class/subclass.
        if requested == "xeno" then
            if not HORDE:PlayerMeetsRank(ply, HORDE.Rank_Amateur) then
                HORDE:SendNotification(
                    "Xeno waveset requires at least Amateur rank on any class or subclass.",
                    1, ply)
                return
            end
        end

        -- Sea-Infection waveset also requires at least Amateur rank.
        if requested == "sea_infection" then
            if not HORDE:PlayerMeetsRank(ply, HORDE.Rank_Amateur) then
                HORDE:SendNotification(
                    "Sea-Infection waveset requires at least Amateur rank on any class or subclass.",
                    1, ply)
                return
            end
        end

        local previous = HORDE.waveset
        HORDE.waveset = requested
        ReloadEnemiesByWaveset(requested)

        -- If switching away from xeno, clear the fog and reset adaptation on all clients.
        if previous == "xeno" and requested ~= "xeno" then
            net.Start("Horde_XenoFogEnd")
            net.Broadcast()
            -- Reset server-side adaptation
            HORDE.xeno_adaptation = {}
            net.Start("Horde_XenoAdaptationSync")
                net.WriteTable({})
            net.Broadcast()
        end

        -- If switching away from sea_infection, clear its blue fog.
        if previous == "sea_infection" and requested ~= "sea_infection" then
            net.Start("Horde_SeaFogEnd")
            net.Broadcast()
        end

        -- Broadcast the new waveset to all clients so their UI stays in sync.
        net.Start("Horde_WavesetChanged")
            net.WriteString(requested)
        net.Broadcast()

        HORDE:SendNotification("Waveset changed to: " .. requested, 0)
        print("[HORDE] - Waveset changed to: " .. requested .. " by " .. ply:Nick())
    end)

    -- On wave 10 start in xeno mode: dense fog + ominous chat message.
    hook.Add("HordeWaveStart", "Horde_XenoWave10Events", function(wave)
        if HORDE.waveset ~= "xeno" then return end
        if wave ~= 10 then return end

        -- Trigger dense green fog on all clients.
        net.Start("Horde_XenoFogStart")
        net.Broadcast()

        -- Broadcast the ominous chat message to all players.
        for _, ply in pairs(player.GetAll()) do
            ply:PrintMessage(HUD_PRINTTALK, "The Heart of the Xeno Virus approaches sinisterly.")
        end
    end)

    -- On wave 10 start in Sea-Infection mode: deep blue abyssal fog + ominous chat.
    hook.Add("HordeWaveStart", "Horde_SeaWave10Events", function(wave)
        if HORDE.waveset ~= "sea_infection" then return end
        if wave ~= 10 then return end

        net.Start("Horde_SeaFogStart")
        net.Broadcast()

        for _, ply in pairs(player.GetAll()) do
            ply:PrintMessage(HUD_PRINTTALK, "The abyss stirs. Thymicgthys, Sea Born Ruler, rises from the depths.")
        end
    end)
end

-- Clients receive waveset changes and update HORDE.waveset for UI.
if CLIENT then
    net.Receive("Horde_WavesetChanged", function()
        HORDE.waveset = net.ReadString()
    end)
end

-- =============================================================================
-- SEA-INFECTION ENEMY ROSTER
-- 24 unique Seaborn-themed enemies tinted bioluminescent blue.
-- Inspired by Arknights' Seaborn faction: aquatic, parasitic, deep-sea horrors.
-- All use existing VJ Horde NPC classes with blue tints and retuned scales.
--
-- ENEMY ROSTER (24 unique types):
--   Tidewalker          — Basic seaborn shambler. Slow but tough.
--   Skimmer             — Fast seaborn scout. Sprinter analogue.
--   Reef Crawler        — Low, skittering crab-like horror. Crawler analogue.
--   Abyssal Lurker      — Explosive bladder. Exploder analogue.
--   Vomit Eel           — Ranged acid spitter. Vomitter analogue.
--   Pressure Screamer   — Sonic burst emitter. Screecher analogue.
--   Tide Zombie         — Half-devoured corpse. Zombine analogue.
--   Charred Tideling    — Flame-touched seaborn. Charred Zombine analogue.
--   Deep Hulk           — Massive armored brute. Hulk analogue.
--   Mutation Hulk       — Aberrant growth form. Mutated Hulk analogue.
--   Coral Blight        — Crystalline hazard zone. Blight analogue.
--   Plague Diver        — Soldier-class seaborn. Plague Soldier analogue.
--   Weeping Polyp       — Toxic mist emanator. Weeper analogue.
--   Lesion Tendril      — Whip-like stinger. Lesion analogue.
--   Elite Predator      — Alpha-class hunter. Plague Elite analogue.
--   Deep Scorcher       — Thermal vent creature. Scorcher analogue.
--   Depth Parasite      — Tiny, fast, multiplying. Fast Zombie analogue.
--   Torso Crawler       — Severed upper body. Zombie Torso analogue.
--   Riftborn Yeti       — Pressurised deep giant. Yeti analogue.
--   Herald of Breen     — Corrupted deep herald. Horde Breen analogue.
--   Alpha Gonome        — Ancient sea gonome. Alpha Gonome analogue.
--   Gamma Gonome        — Mutated deep gonome. Gamma Gonome analogue.
--   Platoon Diver       — Elite diver pack. Plague Platoon analogue.
--   BOSS: Thymicgthys   — Sea Born Ruler. Wave 11 final boss.
-- =============================================================================


local SEA_BLUE = Color(30, 140, 255)  -- Bioluminescent deep blue tint

function HORDE:GetSeaInfectionEnemiesData()

    -- =========================================================================
    -- WAVE 1 — First contact: the shallows stir.
    -- Tidewalkers and Skimmers wade ashore alongside Nzr'apl Shamblers
    -- and nimble Tide Runners — the Seaborn vanguard makes landfall.
    -- =========================================================================
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  1, false, 1.1,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.85,  1, false, 0.9,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Torso Crawler",        "npc_vj_horde_sea_torso_crawler",     0.30,  1, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Depth Parasite",       "npc_vj_horde_sea_depth_parasite",    0.20,  1, false, 0.75, 1,    1,    1,    SEA_BLUE)
    -- Seaborn additions: T1 shambler and fast runner debut
    HORDE:CreateEnemy("Nzr'apl Shambler",     "npc_vj_horde_sb_nzrapl",            0.55,  1, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Runner",          "npc_vj_horde_sb_tide_runner",        0.45,  1, false, 1,    1,    1,    1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 2 — Reef Crawlers join the assault; Aegirian Infected emerge.
    -- The Corrupted Aegirian's poison aura signals a darker infection.
    -- =========================================================================
    HORDE:CreateEnemy("Plague Carrier",       "npc_vj_horde_sea_plague_carrier",    0.20,  2, false, 1,    1,    1.2,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  2, false, 1.1,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.80,  2, false, 0.9,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Reef Crawler",         "npc_vj_horde_sea_reef_crawler",      0.40,  2, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Depth Parasite",       "npc_vj_horde_sea_depth_parasite",    0.20,  2, false, 0.75, 1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Lurker",       "npc_vj_horde_sea_abyssal_lurker",    0.25,  2, true,  1,    1,    1.25, 1,    SEA_BLUE)
    -- Seaborn additions: Aegirian Infected faction arrives
    HORDE:CreateEnemy("Nzr'apl Shambler",     "npc_vj_horde_sb_nzrapl",            0.45,  2, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Runner",          "npc_vj_horde_sb_tide_runner",        0.40,  2, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Corrupted Aegirian",   "npc_vj_horde_sb_aegirian",           0.25,  2, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Aegirian Skimmer",     "npc_vj_horde_sb_skimmer",            0.30,  2, false, 1,    1,    1,    1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 3 — Vomit Eels arrive; ranged threats multiply.
    -- Tide Lurkers stalk unseen and the Abyssal Choir opens fire from range.
    -- =========================================================================
    HORDE:CreateEnemy("Brood Host",           "npc_vj_horde_sea_brood_host",        0.15,  3, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  3, false, 1.1,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.80,  3, false, 0.9,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Reef Crawler",         "npc_vj_horde_sea_reef_crawler",      0.40,  3, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Vomit Eel",            "npc_vj_horde_sea_vomit_eel",         0.30,  3, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Lurker",       "npc_vj_horde_sea_abyssal_lurker",    0.20,  3, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Zombie",          "npc_vj_horde_sea_tide_zombie",       0.10,  3, false, 1,    1,    1.1,  1,    SEA_BLUE)
    -- Seaborn additions: stealth ambushers and choir ranged support
    HORDE:CreateEnemy("Corrupted Aegirian",   "npc_vj_horde_sb_aegirian",           0.20,  3, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Aegirian Skimmer",     "npc_vj_horde_sb_skimmer",            0.25,  3, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Lurker",          "npc_vj_horde_sb_lurker",             0.18,  3, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Choir",        "npc_vj_horde_sb_choir",              0.15,  3, true,  1,    1,    1.25, 1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 4 — Pressure Screamers shatter morale; Plague Divers surface.
    -- Tide Zealots begin their suicidal devotion. Nessuno Thralls carve
    -- through the press with inhuman speed. Void Screamers warp the air.
    -- =========================================================================
    HORDE:CreateEnemy("Spore Drifter",        "npc_vj_horde_sea_spore_drifter",     0.25,  4, false, 1,    1,    0.9,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  4, false, 1.1,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.75,  4, false, 0.9,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Reef Crawler",         "npc_vj_horde_sea_reef_crawler",      0.35,  4, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Pressure Screamer",    "npc_vj_horde_sea_pressure_screamer", 0.20,  4, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Plague Diver",         "npc_vj_horde_sea_plague_diver",      0.15,  4, false, 1,    1.1,  1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Vomit Eel",            "npc_vj_horde_sea_vomit_eel",         0.25,  4, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Zombie",          "npc_vj_horde_sea_tide_zombie",       0.10,  4, false, 1,    1,    1.1,  1,    SEA_BLUE)
    -- Seaborn additions: zealot bombers, rapid thralls, sonic screamers
    HORDE:CreateEnemy("Tide Lurker",          "npc_vj_horde_sb_lurker",             0.18,  4, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Choir",        "npc_vj_horde_sb_choir",              0.15,  4, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Zealot",          "npc_vj_horde_sb_zealot",             0.20,  4, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Nessuno Thrall",       "npc_vj_horde_sb_nessuno",            0.18,  4, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Void Screamer",        "npc_vj_horde_sb_screamer",           0.15,  4, true,  1,    1,    1.25, 1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 5 — Charred Tidelings ignite chaos; Coral Blight zones emerge.
    -- Bioluminescent Burners burn bright and hot. Inkblood Spectres stalk
    -- from the dark. The Tide Assimilator reshapes what it kills.
    -- =========================================================================
    HORDE:CreateEnemy("Tidecaller",           "npc_vj_horde_sea_tidecaller",        0.12,  5, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  5, false, 1.2,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.75,  5, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Charred Tideling",     "npc_vj_horde_sea_charred_tideling",  0.15,  5, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Coral Blight",         "npc_vj_horde_sea_coral_blight",      0.15,  5, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Pressure Screamer",    "npc_vj_horde_sea_pressure_screamer", 0.20,  5, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Plague Diver",         "npc_vj_horde_sea_plague_diver",      0.15,  5, false, 1,    1.1,  1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Lurker",       "npc_vj_horde_sea_abyssal_lurker",    0.20,  5, true,  1,    1,    1.25, 1,    SEA_BLUE)
    -- Seaborn additions: fire-touched and shadow assassins emerge
    HORDE:CreateEnemy("Tide Zealot",          "npc_vj_horde_sb_zealot",             0.20,  5, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Nessuno Thrall",       "npc_vj_horde_sb_nessuno",            0.20,  5, false, 1,    1,    1.1,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Void Screamer",        "npc_vj_horde_sb_screamer",           0.15,  5, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Bioluminescent Burner","npc_vj_horde_sb_burner",             0.12,  5, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Inkblood Spectre",     "npc_vj_horde_sb_inkblood",           0.10,  5, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Assimilator",     "npc_vj_horde_sb_assimilator",        0.12,  5, true,  1,    1,    1.25, 1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 6 — Deep Hulks lumber forward; Weeping Polyps begin saturation.
    -- The Abyssal Warden makes its first crushing appearance.
    -- Seaborn Revenants refuse to die.
    -- =========================================================================
    HORDE:CreateEnemy("Kelp Strangler",       "npc_vj_horde_sea_kelp_strangler",    0.15,  6, false, 1,    1,    1.2,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  6, false, 1.2,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.70,  6, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Deep Hulk",            "npc_vj_horde_sea_deep_hulk",         0.10,  6, true,  1.2,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Weeping Polyp",        "npc_vj_horde_sea_weeping_polyp",     0.15,  6, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Coral Blight",         "npc_vj_horde_sea_coral_blight",      0.15,  6, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Plague Diver",         "npc_vj_horde_sea_plague_diver",      0.15,  6, false, 1,    1.1,  1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Deep Scorcher",        "npc_vj_horde_sea_deep_scorcher",     0.10,  6, true,  1,    1,    1.5,  1,    SEA_BLUE)
    -- Seaborn additions: armored warden, undying revenant, spreading assimilator
    HORDE:CreateEnemy("Bioluminescent Burner","npc_vj_horde_sb_burner",             0.12,  6, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Inkblood Spectre",     "npc_vj_horde_sb_inkblood",           0.10,  6, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Tide Assimilator",     "npc_vj_horde_sb_assimilator",        0.12,  6, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Warden",       "npc_vj_horde_sb_warden",             0.06,  6, true,  1,    1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Seaborn Revenant",     "npc_vj_horde_sb_revenant",           0.10,  6, true,  1,    1,    1.5,  1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 7 — Riftborn Yeti and Lesion Tendrils; pressure intensifies.
    -- The Deep Prophet first whispers its name. The Abyssal Herald stalks
    -- from the shadows. Revenants surge in greater numbers.
    -- =========================================================================
    HORDE:CreateEnemy("Abyssal Shade",        "npc_vj_horde_sea_abyssal_shade",     0.12,  7, false, 1,    1,    1.2,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Barnacle Golem",       "npc_vj_horde_sea_barnacle_golem",    0.05,  7, true,  1.1,  1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  7, false, 1.3,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.70,  7, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Reef Crawler",         "npc_vj_horde_sea_reef_crawler",      0.30,  7, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Riftborn Yeti",        "npc_vj_horde_sea_riftborn_yeti",     0.08,  7, true,  1.1,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Lesion Tendril",       "npc_vj_horde_sea_lesion_tendril",    0.10,  7, true,  1,    1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Deep Hulk",            "npc_vj_horde_sea_deep_hulk",         0.08,  7, true,  1.2,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Weeping Polyp",        "npc_vj_horde_sea_weeping_polyp",     0.12,  7, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Pressure Screamer",    "npc_vj_horde_sea_pressure_screamer", 0.15,  7, true,  1,    1,    1.25, 1,    SEA_BLUE)
    -- Seaborn additions: prophets and heralds emerge from the deep
    HORDE:CreateEnemy("Tide Assimilator",     "npc_vj_horde_sb_assimilator",        0.12,  7, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Warden",       "npc_vj_horde_sb_warden",             0.06,  7, true,  1.1,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Seaborn Revenant",     "npc_vj_horde_sb_revenant",           0.10,  7, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Deep Prophet",         "npc_vj_horde_sb_prophet",            0.04,  7, true,  1,    1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Herald",       "npc_vj_horde_sb_herald",             0.06,  7, true,  1,    1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)

    -- =========================================================================
    -- WAVE 8 — Elite Predators hunt; Mutation Hulks emerge from the deep.
    -- Deep Prophets unleash their coral barrages. Ishar'mla Sprouts begin
    -- surfacing as advance scouts of something far larger beneath.
    -- =========================================================================
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  8, false, 1.3,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.70,  8, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Elite Predator",       "npc_vj_horde_sea_elite_predator",    0.08,  8, true,  1,    1.1,  3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Mutation Hulk",        "npc_vj_horde_sea_mutation_hulk",     0.06,  8, true,  1.2,  1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Riftborn Yeti",        "npc_vj_horde_sea_riftborn_yeti",     0.07,  8, true,  1.1,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Deep Scorcher",        "npc_vj_horde_sea_deep_scorcher",     0.10,  8, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Alpha Gonome",         "npc_vj_horde_sea_alpha_gonome",      0.07,  8, true,  1,    1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Plague Diver",         "npc_vj_horde_sea_plague_diver",      0.12,  8, false, 1.1,  1.1,  1.25, 1,    SEA_BLUE)
    -- Seaborn additions: elite abyssals and first Sprout scouts
    HORDE:CreateEnemy("Abyssal Warden",       "npc_vj_horde_sb_warden",             0.06,  8, true,  1.1,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Seaborn Revenant",     "npc_vj_horde_sb_revenant",           0.10,  8, true,  1,    1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Deep Prophet",         "npc_vj_horde_sb_prophet",            0.05,  8, true,  1,    1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Herald",       "npc_vj_horde_sb_herald",             0.06,  8, true,  1.1,  1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Inkblood Spectre",     "npc_vj_horde_sb_inkblood",           0.08,  8, true,  1.1,  1,    2,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Ishar'mla Sprout",     "npc_vj_horde_sb_isharspawn",         0.04,  8, true,  1,    1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)

    -- =========================================================================
    -- WAVE 9 — Herald of Breen commands; Gamma Gonomes multiply.
    -- The Ishar'mla Sprouts swarm in force. The full Seaborn apex faction
    -- is now assembled and pressing hard toward the final surge.
    -- =========================================================================
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00,  9, false, 1.4,  1.1,  1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.70,  9, false, 1,    1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Herald of Breen",      "npc_vj_horde_sea_herald",            0.05,  9, true,  1.1,  1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Gamma Gonome",         "npc_vj_horde_sea_gamma_gonome",      0.06,  9, true,  1,    1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Alpha Gonome",         "npc_vj_horde_sea_alpha_gonome",      0.06,  9, true,  1,    1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Mutation Hulk",        "npc_vj_horde_sea_mutation_hulk",     0.06,  9, true,  1.2,  1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Elite Predator",       "npc_vj_horde_sea_elite_predator",    0.07,  9, true,  1,    1.1,  3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Lurker",       "npc_vj_horde_sea_abyssal_lurker",    0.15,  9, true,  1,    1,    1.25, 1,    SEA_BLUE)
    HORDE:CreateEnemy("Weeping Polyp",        "npc_vj_horde_sea_weeping_polyp",     0.10,  9, true,  1,    1,    1.5,  1,    SEA_BLUE)
    -- Seaborn additions: apex predators converge; Sprouts swarm in numbers
    HORDE:CreateEnemy("Deep Prophet",         "npc_vj_horde_sb_prophet",            0.05,  9, true,  1.1,  1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Herald",       "npc_vj_horde_sb_herald",             0.06,  9, true,  1.1,  1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Warden",       "npc_vj_horde_sb_warden",             0.05,  9, true,  1.2,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Seaborn Revenant",     "npc_vj_horde_sb_revenant",           0.10,  9, true,  1.1,  1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Ishar'mla Sprout",     "npc_vj_horde_sb_isharspawn",         0.06,  9, true,  1,    1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Tide Assimilator",     "npc_vj_horde_sb_assimilator",        0.10,  9, true,  1.1,  1,    1.25, 1,    SEA_BLUE)

    -- =========================================================================
    -- WAVE 10 — The full Seaborn vanguard surges. Every horror of the deep
    -- converges for the final push before the BOSS: Ishar'mla Echo rises
    -- from the abyss and opens the gate for what follows in wave 11.
    -- =========================================================================
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00, 10, false, 1.5,  1.1,  1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Skimmer",              "npc_vj_horde_sea_skimmer",           0.70, 10, false, 1.1,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Reef Crawler",         "npc_vj_horde_sea_reef_crawler",      0.30, 10, false, 1.1,  1,    1,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Elite Predator",       "npc_vj_horde_sea_elite_predator",    0.07, 10, true,  1.1,  1.2,  3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Mutation Hulk",        "npc_vj_horde_sea_mutation_hulk",     0.06, 10, true,  1.3,  1.1,  2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Gamma Gonome",         "npc_vj_horde_sea_gamma_gonome",      0.06, 10, true,  1.1,  1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Coral Blight",         "npc_vj_horde_sea_coral_blight",      0.10, 10, true,  1.1,  1,    1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Lesion Tendril",       "npc_vj_horde_sea_lesion_tendril",    0.08, 10, true,  1.1,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Platoon Diver",        "npc_vj_horde_sea_platoon_diver",     0.10, 10, false, 1.1,  1.1,  1.25, 1,    SEA_BLUE)
    -- Seaborn apex units flood in before the wave boss
    HORDE:CreateEnemy("Deep Prophet",         "npc_vj_horde_sb_prophet",            0.06, 10, true,  1.2,  1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Herald",       "npc_vj_horde_sb_herald",             0.07, 10, true,  1.2,  1,    2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Warden",       "npc_vj_horde_sb_warden",             0.05, 10, true,  1.3,  1,    2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Ishar'mla Sprout",     "npc_vj_horde_sb_isharspawn",         0.07, 10, true,  1.1,  1,    3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Inkblood Spectre",     "npc_vj_horde_sb_inkblood",           0.08, 10, true,  1.2,  1,    2,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Seaborn Revenant",     "npc_vj_horde_sb_revenant",           0.08, 10, true,  1.2,  1,    1.5,  1,    SEA_BLUE)
    -- Wave 10 BOSS: Ishar'mla Echo — the herald of Skadi's descent
    HORDE:CreateEnemy("Ishar'mla Echo",       "npc_vj_horde_sb_ishar",              1,    10, true,  1,    1,    10,   1,    SEA_BLUE, nil, nil,
        {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.5, music="music/hl1_song24.mp3", music_duration=84}, "none")

    -- =========================================================================
    -- WAVE 11 — FINAL WAVE: The abyss opens fully.
    -- Skadi the Corrupted, supreme ruler of the Seaborn, descends.
    -- The mightiest Seaborn hold the line as Skadi reshapes the world.
    -- =========================================================================
    HORDE:CreateEnemy("Tidewalker",           "npc_vj_horde_sea_tidewalker",        1.00, 11, false, 1.6,  1.2,  1,    1.1,  SEA_BLUE)
    HORDE:CreateEnemy("Mutation Hulk",        "npc_vj_horde_sea_mutation_hulk",     0.10, 11, false, 1.4,  1.2,  2.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Elite Predator",       "npc_vj_horde_sea_elite_predator",    0.06, 11, false, 1.2,  1.3,  3,    1,    SEA_BLUE)
    HORDE:CreateEnemy("Ishar'mla Sprout",     "npc_vj_horde_sb_isharspawn",         0.08, 11, false, 1.2,  1.1,  3,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Abyssal Herald",       "npc_vj_horde_sb_herald",             0.06, 11, false, 1.3,  1.1,  2.5,  1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    HORDE:CreateEnemy("Seaborn Revenant",     "npc_vj_horde_sb_revenant",           0.07, 11, false, 1.3,  1.2,  1.5,  1,    SEA_BLUE)
    HORDE:CreateEnemy("Abyssal Warden",       "npc_vj_horde_sb_warden",             0.05, 11, false, 1.4,  1.1,  2,    1,    SEA_BLUE, nil, nil, nil, nil, nil, nil, 1)
    -- Final BOSS: Skadi the Corrupted — Sea Born Ruler, Thymicgthys
    HORDE:CreateEnemy("Sea Born Ruler, Thymicgthys", "npc_vj_horde_sb_abyssal_king", 1,   11, true,  1,    1,    10,   1.2,  SEA_BLUE, nil, nil,
        {is_boss=true, end_wave=true, unlimited_enemies_spawn=true, enemies_spawn_threshold=0.3,
         music="zombiesurvival/xeno_raid/genesis_of_the_virus.mp3", music_duration=185}, "none")

    HORDE:NormalizeEnemiesWeight()

    print("[HORDE] - Loaded Sea-Infection enemy config. 44 enemy types (24 original + 20 Seaborn) across 11 waves.")
end
