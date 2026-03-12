-- =============================================================================
-- HORDE STARTUP VOTE SYSTEM  (server)
-- On map load, opens a two-phase vote for all players:
--   Phase 1 → Difficulty   (60s, or instant when everyone votes)
--   Phase 2 → Waveset      (60s, or instant when everyone votes)
-- Results are applied and broadcast; votes are shown per-player in the HUD.
-- =============================================================================

util.AddNetworkString("Horde_StartupVoteOpen")   -- sv → cl  open a vote phase
util.AddNetworkString("Horde_StartupVoteSync")   -- sv → cl  update live tallies
util.AddNetworkString("Horde_StartupVoteResult") -- sv → cl  announce winner + close
util.AddNetworkString("Horde_StartupVoteCast")   -- cl → sv  player casts a vote

-- ─── State ────────────────────────────────────────────────────────────────────
local VOTE_PHASES = { "difficulty", "waveset" }
local vote_active   = false
local vote_phase    = nil          -- "difficulty" or "waveset"
local vote_tally    = {}           -- option_index → { player, ... }
local vote_cast     = {}           -- player → option_index
local vote_timer    = "Horde_StartupVoteTimer"
local VOTE_DURATION = 60

-- ─── Helpers ──────────────────────────────────────────────────────────────────
local function GetVoteOptions(phase)
    if phase == "difficulty" then
        -- Returns { id (int), label, color }
        local opts = {}
        for i, name in ipairs(HORDE.difficulty_text) do
            table.insert(opts, {
                id    = i,
                label = name,
                color = HORDE.difficulty_colors[i] or Color(200, 200, 200),
            })
        end
        return opts
    elseif phase == "waveset" then
        return {
            { id = "default", label = "DEFAULT", color = Color(180, 80,  80) },
            { id = "xeno",    label = "XENO",    color = Color(50,  220, 80) },
        }
    end
    return {}
end

local function CountPlayers()
    local n = 0
    for _, _ in pairs(player.GetAll()) do n = n + 1 end
    return n
end

local function AllVotesCast()
    local n_cast = 0
    for _, _ in pairs(vote_cast) do n_cast = n_cast + 1 end
    return n_cast >= CountPlayers()
end

-- Builds the net-friendly tally: option_id → list of { steamid, name, avatar_steamid }
local function BuildSyncTable()
    local t = {}
    for opt_key, players in pairs(vote_tally) do
        local list = {}
        for _, ply in ipairs(players) do
            if IsValid(ply) then
                table.insert(list, {
                    steamid = ply:SteamID64() or "",
                    name    = ply:Name(),
                })
            end
        end
        t[tostring(opt_key)] = list
    end
    return t
end

local function BroadcastSync(time_left)
    net.Start("Horde_StartupVoteSync")
        net.WriteString(vote_phase)
        net.WriteTable(BuildSyncTable())
        net.WriteFloat(time_left or VOTE_DURATION)
    net.Broadcast()
end

-- ─── Apply result ─────────────────────────────────────────────────────────────
local function ApplyResult(phase, winning_id)
    if phase == "difficulty" then
        local diff = tonumber(winning_id)
        if diff and diff >= 1 and diff <= #HORDE.difficulty_text then
            HORDE.difficulty = diff
            GetConVar("horde_difficulty"):SetInt(diff - 1)
            HORDE:ApplyDifficultyScaling()
            net.Start("Horde_SyncDifficulty")
                net.WriteUInt(HORDE.difficulty, 4)
            net.Broadcast()
            print("[HORDE] Startup vote → Difficulty: " .. HORDE.difficulty_text[diff])
        end
    elseif phase == "waveset" then
        local ws = tostring(winning_id)
        if ws == "default" or ws == "xeno" then
            HORDE.waveset = ws
            local function ReloadEnemiesByWaveset(waveset) end  -- stub; real one is in sh_enemy
            -- Reload enemies via the existing helper (fires as if admin clicked it)
            hook.Run("Horde_WavesetChanged_Server", ws)
            net.Start("Horde_WavesetChanged")
                net.WriteString(ws)
            net.Broadcast()
            print("[HORDE] Startup vote → Waveset: " .. ws)
        end
    end
end

-- ─── Resolve & advance ────────────────────────────────────────────────────────
local function ResolveVote()
    timer.Remove(vote_timer)

    -- Count highest-voted option (ties go to lower index / "default")
    local winner_key   = nil
    local winner_count = -1
    for opt_key, players in pairs(vote_tally) do
        local n = 0
        for _, ply in ipairs(players) do
            if IsValid(ply) then n = n + 1 end
        end
        if n > winner_count then
            winner_count = n
            winner_key   = opt_key
        end
    end

    -- If nobody voted at all, pick first option as default
    if not winner_key then
        local opts = GetVoteOptions(vote_phase)
        if opts[1] then winner_key = tostring(opts[1].id) end
    end

    ApplyResult(vote_phase, winner_key)

    -- Broadcast result
    net.Start("Horde_StartupVoteResult")
        net.WriteString(vote_phase)
        net.WriteString(tostring(winner_key or ""))
        net.WriteTable(BuildSyncTable())
    net.Broadcast()

    vote_active = false

    -- Advance to next phase after a short display pause
    local next_phase_idx = nil
    for i, p in ipairs(VOTE_PHASES) do
        if p == vote_phase then
            next_phase_idx = i + 1
            break
        end
    end

    if next_phase_idx and VOTE_PHASES[next_phase_idx] then
        timer.Simple(3.5, function()
            HORDE:StartupVoteBegin(VOTE_PHASES[next_phase_idx])
        end)
    end
end

-- ─── Open a vote phase ────────────────────────────────────────────────────────
function HORDE:StartupVoteBegin(phase)
    vote_phase  = phase
    vote_active = true
    vote_tally  = {}
    vote_cast   = {}

    -- Pre-populate tally buckets
    local opts = GetVoteOptions(phase)
    for _, opt in ipairs(opts) do
        vote_tally[tostring(opt.id)] = {}
    end

    -- Send open packet
    local opts_net = {}
    for _, o in ipairs(opts) do
        table.insert(opts_net, {
            id    = tostring(o.id),
            label = o.label,
            r = o.color.r, g = o.color.g, b = o.color.b,
        })
    end

    net.Start("Horde_StartupVoteOpen")
        net.WriteString(phase)
        net.WriteTable(opts_net)
        net.WriteFloat(VOTE_DURATION)
    net.Broadcast()

    -- Countdown timer
    local elapsed = 0
    timer.Create(vote_timer, 1, VOTE_DURATION, function()
        elapsed = elapsed + 1
        local remaining = VOTE_DURATION - elapsed
        BroadcastSync(remaining)
        if remaining <= 0 then
            ResolveVote()
        end
    end)
end

-- ─── Receive player vote ──────────────────────────────────────────────────────
net.Receive("Horde_StartupVoteCast", function(len, ply)
    if not vote_active then return end

    local chosen = net.ReadString()

    -- Validate option exists
    if not vote_tally[chosen] then return end

    -- Remove previous vote if any
    local prev = vote_cast[ply]
    if prev and vote_tally[prev] then
        for i, p in ipairs(vote_tally[prev]) do
            if p == ply then
                table.remove(vote_tally[prev], i)
                break
            end
        end
    end

    vote_cast[ply] = chosen
    table.insert(vote_tally[chosen], ply)

    -- Sync updated tally immediately
    local elapsed_ratio = 0
    BroadcastSync(VOTE_DURATION)   -- client uses its own countdown; just sync tallies

    -- Auto-resolve if everyone has voted
    if AllVotesCast() then
        timer.Simple(1.2, function()   -- tiny pause so last avatar animates in
            if vote_active then ResolveVote() end
        end)
    end
end)

-- ─── Handle late-joiners ──────────────────────────────────────────────────────
hook.Add("PlayerInitialSpawn", "Horde_StartupVoteResync", function(ply)
    if not vote_active then return end
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        local opts = GetVoteOptions(vote_phase)
        local opts_net = {}
        for _, o in ipairs(opts) do
            table.insert(opts_net, {
                id    = tostring(o.id),
                label = o.label,
                r = o.color.r, g = o.color.g, b = o.color.b,
            })
        end
        net.Start("Horde_StartupVoteOpen")
            net.WriteString(vote_phase)
            net.WriteTable(opts_net)
            net.WriteFloat(VOTE_DURATION)
        net.Send(ply)
        BroadcastSync(VOTE_DURATION)
    end)
end)

-- ─── Remove vote from disconnected players ────────────────────────────────────
hook.Add("PlayerDisconnected", "Horde_StartupVoteDisconnect", function(ply)
    if not vote_active then return end
    local prev = vote_cast[ply]
    if prev and vote_tally[prev] then
        for i, p in ipairs(vote_tally[prev]) do
            if p == ply then table.remove(vote_tally[prev], i) break end
        end
    end
    vote_cast[ply] = nil
end)

-- ─── Launch on map start (after entities init so ranks are loaded) ────────────
hook.Add("InitPostEntity", "Horde_StartupVoteLaunch", function()
    timer.Simple(4, function()
        HORDE:StartupVoteBegin("difficulty")
    end)
end)
