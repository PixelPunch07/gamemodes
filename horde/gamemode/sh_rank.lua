if SERVER then
util.AddNetworkString("Horde_SyncExp")
end

HORDE.Rank_Novice = "Novice"             -- 0  - 4
HORDE.Rank_Amateur = "Amateur"           -- 5  - 9
HORDE.Rank_Skilled = "Skilled"           -- 10 - 14
HORDE.Rank_Professional = "Professional" -- 15 - 19
HORDE.Rank_Expert = "Expert"             -- 20 - 24
HORDE.Rank_Champion = "Champion"         -- 25 - 29
HORDE.Rank_Elite = "Elite"               -- 30 - 34
HORDE.Rank_Veteran = "Veteran"           -- 35 - 39
HORDE.Rank_Legend = "Legend"             -- 40 - 44
HORDE.Rank_Master = "Master"             -- 45 - 100
HORDE.player_ranks = {}
HORDE.player_exps = {}
HORDE.max_level = 100

HORDE.Rank_Colors = {
    [HORDE.Rank_Novice]       = color_white,
    [HORDE.Rank_Amateur]      = Color(50, 205, 50),
    [HORDE.Rank_Skilled]      = Color(135, 206, 235),
    [HORDE.Rank_Professional] = Color(220, 0, 220),
    [HORDE.Rank_Expert]       = Color(255, 69, 0),
    [HORDE.Rank_Champion]     = Color(255, 215, 0),
    [HORDE.Rank_Elite]        = Color(0, 210, 210),
    [HORDE.Rank_Veteran]      = Color(255, 140, 0),
    [HORDE.Rank_Legend]       = Color(180, 100, 255),
    [HORDE.Rank_Master]       = HORDE.color_crimson
}

-- XP multiplier per difficulty index (1 = Normal .. 6 = Malice)
HORDE.difficulty_xp_multiplier = { 1.0, 1.05, 1.12, 1.20, 1.28, 1.40 }

-- Difficulty display colors used by the in-game difficulty menu
HORDE.difficulty_colors = {
    Color(200, 200, 200), -- NORMAL
    Color(50,  205, 50),  -- HARD
    Color(135, 206, 235), -- REALISM
    Color(180, 100, 255), -- NIGHTMARE
    Color(255, 140, 0),   -- APOCALYPSE
    Color(220, 20,  60),  -- MALICE
}

function HORDE:ScrubSteamID(ply)
	return ply:SteamID():gsub(":", "_")
end

local plymeta = FindMetaTable("Player")

function plymeta:Horde_GetExp(class_name)
    if not self.Horde_Exps then self.Horde_Exps = {} end
    if SERVER then
    end
    return self.Horde_Exps[class_name] or 0
end

function plymeta:Horde_SetExp(class_name, exp)
    if SERVER then
    end
    if not self:IsValid() then return end
    if not self.Horde_Exps then self.Horde_Exps = {} end
    if not class_name then return end
    self.Horde_Exps[class_name] = exp
    local level = self:Horde_GetLevel(class_name)
    if exp >= HORDE:GetExpToNextLevel(level + 1) then
        self:Horde_SetLevel(class_name, level + 1)
        self.Horde_Exps[class_name] = 0
    end
end

function plymeta:Horde_GetLevel(class_name)
    if not self.Horde_Levels then self.Horde_Levels = {} end
    return self.Horde_Levels[class_name] or 0
end

function plymeta:Horde_SetLevel(class_name, level)
    if not self:IsValid() then return end
    if not self.Horde_Levels then self.Horde_Levels = {} end
    if not class_name then return end
    self.Horde_Levels[class_name] = level
    local rank, rank_level = HORDE:LevelToRank(level)
    self:Horde_SetRankLevel(class_name, rank_level)
    self:Horde_SetRank(class_name, rank)

    if SERVER then
        hook.Run("Horde_PrecomputePerkLevelBonus", self)
    end
end

function plymeta:Horde_SetPerkLevelBonus(perk, bonus)
    if not self.Horde_Perk_Level_Bonus then self.Horde_Perk_Level_Bonus = {} end
    self.Horde_Perk_Level_Bonus[perk] = bonus
end

function plymeta:Horde_GetPerkLevelBonus(perk)
    if not self.Horde_Perk_Level_Bonus then return 0 end
    return self.Horde_Perk_Level_Bonus[perk] or 0
end

function plymeta:Horde_GetRankLevel(class_name)
    if not self.Horde_RankLevels then self.Horde_RankLevels = {} end
    return self.Horde_RankLevels[class_name] or 0
end

function plymeta:Horde_SetRankLevel(class_name, level)
    if not self:IsValid() then return end
    if not self.Horde_RankLevels then self.Horde_RankLevels = {} end
    self.Horde_RankLevels[class_name] = level
end

function plymeta:Horde_GetRank(class_name)
    if not self.Horde_Ranks then self.Horde_Ranks = {} end
    return self.Horde_Ranks[class_name] or HORDE.Rank_Novice
end

function plymeta:Horde_SetRank(class_name, rank)
    if not self:IsValid() then return end
    if not self.Horde_Ranks then self.Horde_Ranks = {} end
    self.Horde_Ranks[class_name] = rank
end

function plymeta:Horde_SyncExp()
    for subclass_name, subclass in pairs(HORDE.subclasses) do
        net.Start("Horde_SyncExp")
            net.WriteEntity(self)
            net.WriteString(subclass.PrintName)
            net.WriteUInt(self:Horde_GetExp(subclass.PrintName), 32)
            net.WriteUInt(self:Horde_GetLevel(subclass.PrintName), 8)
        net.Broadcast()
    end
end

function HORDE:GetExpToNextLevel(level)
    return math.floor(50 + 2 * math.pow(1.1, level) + level * 25 + 100 * math.floor(level / 5))
end

function HORDE:LevelToRank(level)
    if level < 45 then
        local rank = HORDE.Rank_Novice
        if level < 5 then
        elseif level < 10 then
            rank = HORDE.Rank_Amateur
        elseif level < 15 then
            rank = HORDE.Rank_Skilled
        elseif level < 20 then
            rank = HORDE.Rank_Professional
        elseif level < 25 then
            rank = HORDE.Rank_Expert
        elseif level < 30 then
            rank = HORDE.Rank_Champion
        elseif level < 35 then
            rank = HORDE.Rank_Elite
        elseif level < 40 then
            rank = HORDE.Rank_Veteran
        elseif level < 45 then
            rank = HORDE.Rank_Legend
        end
        return rank, level % 5
    else
        return HORDE.Rank_Master, level - 45
    end
end

if CLIENT then
net.Receive("Horde_SyncExp", function(length)
    local ply = net.ReadEntity()
    local class_name = net.ReadString()
    local exp = net.ReadUInt(32)
    local level = net.ReadUInt(8)
    if not ply:IsValid() then return end
    ply:Horde_SetLevel(class_name, level)
    ply:Horde_SetExp(class_name, exp)
end)
end
-- =============================================================================
-- Rank ordering table (shared) — used by rank-gate checks.
-- =============================================================================
HORDE.rank_order = {
    [HORDE.Rank_Novice]       = 1,
    [HORDE.Rank_Amateur]      = 2,
    [HORDE.Rank_Skilled]      = 3,
    [HORDE.Rank_Professional] = 4,
    [HORDE.Rank_Expert]       = 5,
    [HORDE.Rank_Champion]     = 6,
    [HORDE.Rank_Elite]        = 7,
    [HORDE.Rank_Veteran]      = 8,
    [HORDE.Rank_Legend]       = 9,
    [HORDE.Rank_Master]       = 10,
}

-- Returns true if the player has ANY subclass whose rank is >= required_rank.
-- Works on both server and client (HORDE.subclasses is shared).
function HORDE:PlayerMeetsRank(ply, required_rank)
    if not IsValid(ply) then return false end
    local req = HORDE.rank_order[required_rank] or 1
    for _, subclass in pairs(HORDE.subclasses) do
        local rank = ply:Horde_GetRank(subclass.PrintName)
        if (HORDE.rank_order[rank] or 1) >= req then
            return true
        end
    end
    return false
end
