-- Horde Waveset Menu
-- Allows admins to switch between "Default" and "Xeno" enemy wavesets.
-- Opens via: horde_waveset_menu (concommand) → server → Horde_ToggleWaveset net msg → client
-- Or directly via the Configuration Menu button.

local PANEL = {}

local WAVESETS = {
    {
        id          = "default",
        label       = "DEFAULT",
        desc        = "Original enemy roster. Vanilla Horde enemies across all 10 waves.",
        sub         = "Zombies, Crawlers, Hulks, Gonomes and more.",
        color       = Color(180, 80,  80),
    },
    {
        id          = "xeno",
        label       = "XENO",
        desc        = "Xeno-variant enemies replace all standard NPCs. Every enemy is tinted green.",
        sub         = "Xeno Walkers, Sprinters, Plague Soldiers, Xeno Gonomes and more.",
        color       = Color(50,  220, 80),
        req_rank    = HORDE.Rank_Amateur,
    },
    {
        id          = "sea_infection",
        label       = "SEA-INFECTION",
        desc        = "Seaborn entities from the deep. All enemies tinted bioluminescent blue.",
        sub         = "Tidewalkers, Abyssal Lurkers, Coral Brutes, Reef Parasites and more.",
        color       = Color(30,  160, 255),
        req_rank    = HORDE.Rank_Skilled,
    },
}

function PANEL:Init()
    local sw, sh = ScrW(), ScrH()
    local w, h = math.min(sw * 0.48, 600), math.min(sh * 0.55, 420)
    self:SetSize(w, h)
    self:SetPos((sw - w) / 2, (sh - h) / 2)
    self:MakePopup()

    -- Title
    local title = vgui.Create("DLabel", self)
    title:SetFont("HudHintTextLarge")
    title:SetText("SELECT WAVESET")
    title:SetTextColor(Color(255, 255, 255))
    title:SizeToContents()
    title:SetPos(20, 14)

    -- Close button
    local close_btn = vgui.Create("DButton", self)
    close_btn:SetFont("marlett")
    close_btn:SetText("r")
    close_btn.Paint = function() end
    close_btn:SetColor(Color(255, 255, 255))
    close_btn:SetSize(32, 32)
    close_btn:SetPos(w - 40, 8)
    close_btn.DoClick = function() HORDE:ToggleWavesetMenu() end

    -- Separator
    local sep = vgui.Create("DPanel", self)
    sep:SetPos(0, 44)
    sep:SetSize(w, 2)
    sep.Paint = function(_, pw, ph)
        surface.SetDrawColor(50, 220, 80)
        surface.DrawRect(0, 0, pw, ph)
    end

    -- Admin-only notice if not admin
    local is_admin = IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()
    if not is_admin then
        local notice = vgui.Create("DLabel", self)
        notice:SetFont("Trebuchet18")
        notice:SetText("⚠  Only admins can change the waveset.")
        notice:SetTextColor(Color(255, 200, 60))
        notice:SizeToContents()
        notice:SetPos(w / 2 - notice:GetWide() / 2, 52)
    end

    -- Waveset rows
    self.ws_panels = {}
    local y_start = is_admin and 58 or 82

    for _, ws in ipairs(WAVESETS) do
        local row = vgui.Create("DPanel", self)
        row:SetPos(14, y_start)
        row:SetSize(w - 28, 100)
        y_start = y_start + 112

        local is_selected = (HORDE.waveset == ws.id)
        local hovered     = false
        local capture_ws  = ws   -- capture loop var

        row.Paint = function(_, pw, ph)
            local bg = is_selected and Color(15, 50, 15, 230) or Color(30, 30, 30, 210)
            draw.RoundedBox(4, 0, 0, pw, ph, bg)
            -- Left accent stripe
            local stripe = is_selected and capture_ws.color or Color(60, 60, 60)
            if hovered and not is_selected then stripe = capture_ws.color end
            draw.RoundedBox(2, 0, 0, 5, ph, stripe)
            -- Outline
            if is_selected or hovered then
                surface.SetDrawColor(capture_ws.color)
                surface.DrawOutlinedRect(0, 0, pw, ph, 1)
            end
        end

        row.OnCursorEntered = function() hovered = true end
        row.OnCursorExited  = function() hovered = false end

        -- Name label
        local name_lbl = vgui.Create("DLabel", row)
        name_lbl:SetFont("HudSelectionText")
        name_lbl:SetText(ws.label)
        name_lbl:SetTextColor(ws.color)
        name_lbl:SizeToContents()
        name_lbl:SetPos(16, 10)

        -- "ACTIVE" badge
        local active_lbl = vgui.Create("DLabel", row)
        active_lbl:SetFont("Trebuchet18")
        active_lbl:SetText(is_selected and "  ◀  ACTIVE" or "")
        active_lbl:SetTextColor(ws.color)
        active_lbl:SizeToContents()
        active_lbl:SetPos(name_lbl:GetX() + name_lbl:GetWide() + 6, 13)

        -- Description
        local desc_lbl = vgui.Create("DLabel", row)
        desc_lbl:SetFont("Trebuchet18")
        desc_lbl:SetText(ws.desc)
        desc_lbl:SetTextColor(Color(200, 200, 200))
        desc_lbl:SizeToContents()
        desc_lbl:SetPos(16, 38)

        -- Sub-description
        local sub_lbl = vgui.Create("DLabel", row)
        sub_lbl:SetFont("Trebuchet18")
        sub_lbl:SetText(ws.sub)
        sub_lbl:SetTextColor(Color(140, 140, 140))
        sub_lbl:SizeToContents()
        sub_lbl:SetPos(16, 62)

        -- Rank requirement badge (shown only if waveset has one)
        if ws.req_rank then
            local ply        = LocalPlayer()
            local meets      = HORDE:PlayerMeetsRank(ply, ws.req_rank)
            local rank_col   = meets and Color(50, 205, 50) or Color(255, 80, 80)
            local rank_txt   = meets
                and ("✔  Requires " .. ws.req_rank .. " rank  (met)")
                or  ("✘  Requires " .. ws.req_rank .. " rank on any class/subclass")
            local rank_lbl = vgui.Create("DLabel", row)
            rank_lbl:SetFont("Trebuchet18")
            rank_lbl:SetText(rank_txt)
            rank_lbl:SetTextColor(rank_col)
            rank_lbl:SizeToContents()
            rank_lbl:SetPos(name_lbl:GetX() + name_lbl:GetWide() + 12, 10)
        end

        -- Click: send request to server (admin only, rank check)
        row.OnMousePressed = function(_, mcode)
            if mcode ~= MOUSE_LEFT then return end
            if not is_admin then return end
            if is_selected then return end

            -- Client-side rank gate (server double-checks too)
            if ws.req_rank and not HORDE:PlayerMeetsRank(LocalPlayer(), ws.req_rank) then
                HORDE:PlayNotification(
                    "Requires " .. ws.req_rank .. " rank on any class or subclass.",
                    1, "materials/status/necrosis.png", Color(255, 80, 80))
                return
            end

            net.Start("Horde_SetWaveset")
                net.WriteString(capture_ws.id)
            net.SendToServer()

            -- Optimistic local update + rebuild
            HORDE.waveset = capture_ws.id
            self:Remove()
            HORDE.WavesetGUI = nil
            timer.Simple(0.05, function()
                HORDE:ToggleWavesetMenu()
            end)
        end

        self.ws_panels[ws.id] = {
            row        = row,
            active_lbl = active_lbl,
            set_selected = function(sel)
                is_selected = sel
                active_lbl:SetText(sel and "  ◀  ACTIVE" or "")
                active_lbl:SizeToContents()
            end,
        }
    end

    -- Footer note
    local note = vgui.Create("DLabel", self)
    note:SetFont("Trebuchet18")
    note:SetText("Changes take effect on the next wave spawn.")
    note:SetTextColor(Color(120, 120, 120))
    note:SizeToContents()
    note:SetPos(w / 2 - note:GetWide() / 2, h - 26)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 235))
    -- Top green bar
    draw.RoundedBoxEx(4, 0, 0, w, 44, Color(20, 70, 20, 255), true, true, false, false)
end

vgui.Register("HordeWavesetMenu", PANEL, "DPanel")

-- Toggle function mirroring the pattern used by other Horde menus.
function HORDE:ToggleWavesetMenu()
    if IsValid(HORDE.WavesetGUI) then
        HORDE.WavesetGUI:Remove()
        HORDE.WavesetGUI = nil
        return
    end
    HORDE.WavesetGUI = vgui.Create("HordeWavesetMenu")
end

-- Receive server-opened toggle (optional, mirrors Horde_ToggleDifficulty pattern).
net.Receive("Horde_ToggleWaveset", function()
    HORDE:ToggleWavesetMenu()
end)
