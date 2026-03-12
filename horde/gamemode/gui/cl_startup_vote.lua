============================================

local vote_open       = false
local vote_phase      = nil        -- "difficulty" | "waveset"
local vote_options    = {}         -- { id, label, color }
local vote_deadline   = 0          -- CurTime() + seconds_left
local vote_tally      = {}         -- option_id → { {steamid, name}, … }
local my_vote         = nil        -- option_id the local player chose
local show_result     = false      -- true during the 3.5s result display
local result_winner   = nil
local result_tally    = {}

-- Each entry: { steamid, name, opt_id, x (current), x_target, y, alpha, slide_t }
local avatars = {}
local AVATAR_SIZE  = 40
local AVATAR_SPEED = 8   -- lerp speed

local function RebuildAvatars(tally, options, sw, sh)
    local col_x = {}
    local n_cols = #options
    local col_w  = sw / n_cols
    for i, opt in ipairs(options) do
        col_x[opt.id] = (i - 0.5) * col_w
    end

    local new_avatars = {}
    local existing = {}
    for _, av in ipairs(avatars) do
        existing[av.steamid] = av
    end

    for _, opt in ipairs(options) do
        local list = tally[opt.id] or {}
        for row, info in ipairs(list) do
            local cx = col_x[opt.id] or sw * 0.5
            local ty = sh * 0.62 + (row - 1) * (AVATAR_SIZE + 6)
            local av
            if existing[info.steamid] then
                av = existing[info.steamid]
                av.opt_id   = opt.id
                av.x_target = cx
                av.y        = ty
            else
                av = {
                    steamid  = info.steamid,
                    name     = info.name,
                    opt_id   = opt.id,
                    x        = -AVATAR_SIZE * 2,   -- starts off-screen left
                    x_target = cx,
                    y        = ty,
                    alpha    = 0,
                    slide_t  = 0,
                }
            end
            table.insert(new_avatars, av)
        end
    end
    avatars = new_avatars
end

local VotePanel = nil

local function CreateVotePanel()
    if IsValid(VotePanel) then VotePanel:Remove() end

    VotePanel = vgui.Create("DPanel")
    VotePanel:SetSize(ScrW(), ScrH())
    VotePanel:SetPos(0, 0)
    VotePanel:MakePopup()
    VotePanel:SetKeyboardInputEnabled(false)
    VotePanel:SetMouseInputEnabled(true)

    -- Title text shown at top
    local phase_labels = { difficulty = "CHOOSE DIFFICULTY", waveset = "CHOOSE WAVESET" }

    VotePanel.Paint = function(self, w, h)
        -- Dark overlay
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 185))

        local n = #vote_options
        if n == 0 then return end

        local col_w = w / n

        for i, opt in ipairs(vote_options) do
            local cx = (i - 1) * col_w
            local col_color = opt.color
            local is_mine   = (my_vote == opt.id)

            -- Column background
            local bg_alpha = is_mine and 55 or 22
            draw.RoundedBox(0, cx, 0, col_w, h, Color(col_color.r * 0.15, col_color.g * 0.15, col_color.b * 0.15, bg_alpha))

            -- Vertical separator
            if i > 1 then
                surface.SetDrawColor(60, 60, 60, 160)
                surface.DrawRect(cx, 0, 1, h)
            end

            -- Selection glow on hover / selected
            local mx, my2 = VotePanel:CursorPos()
            local hovered = (mx >= cx and mx < cx + col_w) and not show_result

            if is_mine or hovered then
                local glow_alpha = is_mine and 80 or 40
                draw.RoundedBox(0, cx, 0, col_w, h, Color(col_color.r, col_color.g, col_color.b, glow_alpha))
            end

            -- Option label centred in upper third
            local label_y = h * 0.32
            draw.SimpleText(opt.label, "HudHintTextLarge", cx + col_w * 0.5, label_y,
                col_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Vote count
            local tcount = vote_tally[opt.id] and #vote_tally[opt.id] or 0
            draw.SimpleText(tostring(tcount) .. " vote" .. (tcount ~= 1 and "s" or ""),
                "Trebuchet18", cx + col_w * 0.5, label_y + 30,
                Color(200, 200, 200), TEXT_ALIGN_CENTER)

            -- "YOUR VOTE" badge
            if is_mine then
                draw.SimpleText("▶  YOUR VOTE", "Trebuchet18",
                    cx + col_w * 0.5, label_y + 56,
                    col_color, TEXT_ALIGN_CENTER)
            end

            -- Rank requirement warning inside column
            if not show_result then
                local req_txt = nil
                if vote_phase == "difficulty" and opt.id == tostring(6) then
                    local ok = HORDE:PlayerCanVoteMalice(LocalPlayer())
                    req_txt = ok and nil or "Requires Skilled rank"
                elseif vote_phase == "waveset" and opt.id == "xeno" then
                    local ok = HORDE:PlayerCanVoteXeno(LocalPlayer())
                    req_txt = ok and nil or "Requires Amateur rank"
                end
                if req_txt then
                    draw.SimpleText(req_txt, "Trebuchet18",
                        cx + col_w * 0.5, label_y + 76,
                        Color(255, 140, 40), TEXT_ALIGN_CENTER)
                end
            end
        end

        draw.RoundedBox(0, 0, 0, w, 64, Color(10, 10, 10, 220))

        local phase_txt = show_result
            and ("RESULT: " .. (vote_phase == "difficulty" and "DIFFICULTY" or "WAVESET"))
            or  (phase_labels[vote_phase] or "VOTE")
        draw.SimpleText(phase_txt, "HudHintTextLarge", w * 0.5, 32,
            Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if not show_result then
            local time_left = math.max(0, vote_deadline - CurTime())
            local frac = time_left / 60
            local bar_h = 6
            local bar_y = 64
            -- BG
            draw.RoundedBox(0, 0, bar_y, w, bar_h, Color(30, 30, 30))
            -- Fill  (goes from green → red)
            local fc = Color(Lerp(1 - frac, 60, 220), Lerp(1 - frac, 200, 40), 40)
            draw.RoundedBox(0, 0, bar_y, math.max(0, w * frac), bar_h, fc)
            -- Time text
            draw.SimpleText(string.format("%.0f", time_left) .. "s",
                "Trebuchet18", w - 12, bar_y + bar_h * 0.5 + 2,
                Color(200, 200, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        if show_result and result_winner then
            for i, opt in ipairs(vote_options) do
                if opt.id == result_winner then
                    local cx = (i - 1) * col_w
                    -- Bright border
                    surface.SetDrawColor(opt.color.r, opt.color.g, opt.color.b, 255)
                    surface.DrawOutlinedRect(cx, 0, col_w, h, 3)
                    draw.SimpleText("✔  SELECTED", "HudHintTextLarge",
                        cx + col_w * 0.5, h * 0.5,
                        opt.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    break
                end
            end
        end

        local dt = FrameTime()
        for _, av in ipairs(avatars) do
            av.x     = Lerp(dt * AVATAR_SPEED, av.x, av.x_target)
            av.alpha = math.min(255, av.alpha + dt * 300)
        end

        -- Draw avatars via surface.DrawTexturedRect with AvatarImage
        -- We draw them as simple coloured name badges since AvatarImage
        -- is a VGUI element; real avatar textures are handled below.
        for _, av in ipairs(avatars) do
            local ax = av.x - AVATAR_SIZE * 0.5
            local ay = av.y
            local a  = math.floor(av.alpha)
            -- Shadow
            draw.RoundedBox(4, ax + 2, ay + 2, AVATAR_SIZE, AVATAR_SIZE, Color(0,0,0, a * 0.5))
            -- Name badge background
            local opt_color = Color(100, 100, 100)
            for _, opt in ipairs(vote_options) do
                if opt.id == av.opt_id then opt_color = opt.color break end
            end
            draw.RoundedBox(4, ax, ay, AVATAR_SIZE, AVATAR_SIZE,
                Color(opt_color.r * 0.3, opt_color.g * 0.3, opt_color.b * 0.3, a))
            -- Initials fallback (avatar texture drawn on avatar panels below)
            surface.SetDrawColor(opt_color.r, opt_color.g, opt_color.b, a)
            surface.DrawOutlinedRect(ax, ay, AVATAR_SIZE, AVATAR_SIZE, 1)
            -- Name underneath
            draw.SimpleText(av.name, "Horde_Ready", ax + AVATAR_SIZE * 0.5,
                ay + AVATAR_SIZE + 3,
                Color(220, 220, 220, a), TEXT_ALIGN_CENTER)
        end
    end

    -- We maintain a pool of AvatarImage panels anchored by steamid64.
    VotePanel.avatar_panels = {}

    -- Click detection
    VotePanel.OnMousePressed = function(self, mcode)
        if mcode ~= MOUSE_LEFT then return end
        if show_result then return end

        local mx, _ = self:CursorPos()
        local w     = self:GetWide()
        local n     = #vote_options
        if n == 0 then return end

        local col_idx = math.floor(mx / (w / n)) + 1
        local opt = vote_options[col_idx]
        if not opt then return end

        -- Rank gate
        if vote_phase == "difficulty" and opt.id == tostring(6) then
            if not HORDE:PlayerCanVoteMalice(LocalPlayer()) then
                chat.AddText(Color(255, 100, 60), "[Horde] You need Skilled rank to vote for MALICE.")
                return
            end
        end
        if vote_phase == "waveset" and opt.id == "xeno" then
            if not HORDE:PlayerCanVoteXeno(LocalPlayer()) then
                chat.AddText(Color(255, 160, 40), "[Horde] You need Amateur rank to vote for XENO.")
                return
            end
        end

        my_vote = opt.id
        net.Start("Horde_StartupVoteCast")
            net.WriteString(opt.id)
        net.SendToServer()
    end

    VotePanel.Think = function(self)
        local w = self:GetWide()
        local h = self:GetTall()
        local existing = self.avatar_panels

        -- Build set of current steamids
        local seen = {}
        for _, av in ipairs(avatars) do
            seen[av.steamid] = true
            if not existing[av.steamid] then
                -- Create new AvatarImage panel
                local img = vgui.Create("AvatarImage", self)
                img:SetSize(AVATAR_SIZE, AVATAR_SIZE)
                img:SetSteamID(av.steamid, 32)
                existing[av.steamid] = { panel = img, steamid = av.steamid }
            end
        end

        -- Remove panels for players who are no longer in avatars list
        for sid, entry in pairs(existing) do
            if not seen[sid] then
                if IsValid(entry.panel) then entry.panel:Remove() end
                existing[sid] = nil
            end
        end

        -- Position panels to match animation state
        for _, av in ipairs(avatars) do
            local entry = existing[av.steamid]
            if entry and IsValid(entry.panel) then
                local ax = av.x - AVATAR_SIZE * 0.5
                local ay = av.y
                entry.panel:SetPos(ax, ay)
                entry.panel:SetAlpha(math.floor(av.alpha))
                entry.panel:SetVisible(true)
            end
        end
    end
end


net.Receive("Horde_StartupVoteOpen", function()
    vote_phase    = net.ReadString()
    local opts_raw = net.ReadTable()
    local secs    = net.ReadFloat()

    vote_options = {}
    vote_tally   = {}
    for _, o in ipairs(opts_raw) do
        table.insert(vote_options, {
            id    = o.id,
            label = o.label,
            color = Color(o.r, o.g, o.b),
        })
        vote_tally[o.id] = {}
    end

    my_vote      = nil
    show_result  = false
    result_winner = nil
    vote_deadline = CurTime() + secs
    vote_open    = true
    avatars      = {}

    gui.EnableScreenClicker(true)
    CreateVotePanel()
end)

net.Receive("Horde_StartupVoteSync", function()
    local phase   = net.ReadString()
    local tally   = net.ReadTable()
    local secs    = net.ReadFloat()

    -- Normalise keys
    vote_tally = {}
    for k, list in pairs(tally) do
        vote_tally[k] = list
    end

    vote_deadline = CurTime() + secs

    if IsValid(VotePanel) then
        RebuildAvatars(vote_tally, vote_options, ScrW(), ScrH())
    end
end)

net.Receive("Horde_StartupVoteResult", function()
    local phase  = net.ReadString()
    local winner = net.ReadString()
    local tally  = net.ReadTable()

    vote_tally    = {}
    for k, list in pairs(tally) do vote_tally[k] = list end

    result_winner = winner
    result_tally  = tally
    show_result   = true

    RebuildAvatars(vote_tally, vote_options, ScrW(), ScrH())

    -- Close after display pause
    timer.Simple(3.2, function()
        vote_open   = false
        show_result = false
        avatars     = {}
        if IsValid(VotePanel) then
            VotePanel:Remove()
            VotePanel = nil
        end
        gui.EnableScreenClicker(false)
    end)
end)
