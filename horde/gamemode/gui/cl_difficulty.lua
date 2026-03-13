-- Horde Difficulty Menu
-- Allows players to change difficulty mid-game.
-- Opens via: horde_difficulty_menu (concommand) → server → Horde_ToggleDifficulty net msg → client

local PANEL = {}

local DIFF_DESCRIPTIONS = {
    "Standard gameplay. All enemies have baseline stats.",
    "Increased enemy damage and count. Harsher at high fall speeds.",
    "Tougher enemies, harsher fall damage, and tighter spawn zones.",
    "Enemies mutate frequently. Status effects linger longer.",
    "The horde shows no mercy. Elite enemies are dramatically stronger.",
    "Absolute carnage. Not for the faint of heart.",
}

local XP_LABELS = {
    "No XP bonus",
    "+5% XP",
    "+12% XP",
    "+20% XP",
    "+28% XP",
    "+40% XP",
}

function PANEL:Init()
    local sw, sh = ScrW(), ScrH()
    local w, h = math.min(sw * 0.55, 720), math.min(sh * 0.75, 620)
    self:SetSize(w, h)
    self:SetPos((sw - w) / 2, (sh - h) / 2)

    -- Title bar
    local title = vgui.Create("DLabel", self)
    title:SetFont("HudHintTextLarge")
    title:SetText("SELECT DIFFICULTY")
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
    close_btn.DoClick = function() HORDE:ToggleDifficulty() end

    -- Separator line
    local sep = vgui.Create("DPanel", self)
    sep:SetPos(0, 44)
    sep:SetSize(w, 2)
    sep.Paint = function(pnl, pw, ph)
        surface.SetDrawColor(HORDE.color_crimson)
        surface.DrawRect(0, 0, pw, ph)
    end

    -- Scroll panel for difficulty rows
    local scroll = vgui.Create("DScrollPanel", self)
    scroll:SetPos(0, 50)
    scroll:SetSize(w, h - 50)
    scroll.Paint = function() end

    local sbar = scroll:GetVBar()
    sbar:SetWide(4)
    sbar.Paint = function(pnl, pw, ph)
        draw.RoundedBox(2, 0, 0, pw, ph, Color(30, 30, 30, 200))
    end
    sbar.btnUp.Paint   = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(pnl, pw, ph)
        draw.RoundedBox(2, 0, 0, pw, ph, HORDE.color_crimson_dim)
    end

    self.diff_panels = {}

    for i, diff_name in ipairs(HORDE.difficulty_text) do
        local row = vgui.Create("DPanel", scroll)
        row:Dock(TOP)
        row:DockMargin(12, 8, 12, 0)
        row:SetTall(88)

        local is_selected = (HORDE.difficulty == i)
        local diff_color  = HORDE.difficulty_colors[i] or Color(200, 200, 200)
        local hovered     = false

        row.Paint = function(pnl, pw, ph)
            local bg = is_selected and Color(60, 15, 15, 230) or Color(30, 30, 30, 210)
            draw.RoundedBox(4, 0, 0, pw, ph, bg)
            -- Left accent stripe
            local stripe_color = is_selected and HORDE.color_crimson or Color(60, 60, 60)
            if hovered and not is_selected then stripe_color = diff_color end
            draw.RoundedBox(2, 0, 0, 4, ph, stripe_color)
            -- Hover / selected outline
            if is_selected or hovered then
                surface.SetDrawColor(is_selected and HORDE.color_crimson or diff_color)
                surface.DrawOutlinedRect(0, 0, pw, ph, 1)
            end
        end

        row.OnCursorEntered = function() hovered = true end
        row.OnCursorExited  = function() hovered = false end

        -- Difficulty name
        local name_label = vgui.Create("DLabel", row)
        name_label:SetFont("HudSelectionText")
        name_label:SetText(diff_name)
        name_label:SetTextColor(diff_color)
        name_label:SizeToContents()
        name_label:SetPos(16, 10)

        -- Currently selected badge
        local sel_label = vgui.Create("DLabel", row)
        sel_label:SetFont("Trebuchet18")
        sel_label:SetText(is_selected and "  ◀  CURRENT" or "")
        sel_label:SetTextColor(HORDE.color_crimson)
        sel_label:SizeToContents()
        sel_label:SetPos(name_label:GetX() + name_label:GetWide() + 6, 12)
        self.diff_panels[i] = { row = row, sel_label = sel_label, is_selected_ref = function() return is_selected end }

        -- Description
        local desc_label = vgui.Create("DLabel", row)
        desc_label:SetFont("Trebuchet18")
        desc_label:SetText(DIFF_DESCRIPTIONS[i] or "")
        desc_label:SetTextColor(Color(190, 190, 190))
        desc_label:SizeToContents()
        desc_label:SetPos(16, 36)

        -- XP bonus badge
        local xp_label = vgui.Create("DLabel", row)
        xp_label:SetFont("Trebuchet18")
        xp_label:SetText(XP_LABELS[i] or "")
        xp_label:SetTextColor(diff_color)
        xp_label:SizeToContents()
        xp_label:SetPos(16, 58)

        -- MALICE rank requirement badge
        local MALICE_INDEX = 6
        if i == MALICE_INDEX then
            local ply = LocalPlayer()
            local meets = HORDE:PlayerMeetsRank(ply, HORDE.Rank_Skilled)
            local req_label = vgui.Create("DLabel", row)
            req_label:SetFont("Trebuchet18")
            if meets then
                req_label:SetText("✔  Requires Skilled rank  (met)")
                req_label:SetTextColor(Color(50, 205, 50))
            else
                req_label:SetText("✘  Requires Skilled rank on any class/subclass")
                req_label:SetTextColor(Color(255, 80, 80))
            end
            req_label:SizeToContents()
            req_label:SetPos(name_label:GetX() + name_label:GetWide() + 12, 10)
        end

        -- Click handler – close the menu and request the change
        local capture = i  -- capture loop var
        local capture_is_selected = function() return is_selected end
        row.OnMousePressed = function(pnl, mcode)
            if mcode ~= MOUSE_LEFT then return end
            if is_selected then return end

            -- Update all rows locally
            for j, entry in ipairs(self.diff_panels) do
                -- Toggle selection visual by rebuilding
            end

            -- Send request to server
            net.Start("Horde_RequestDifficulty")
                net.WriteUInt(capture, 4)
            net.SendToServer()

            -- Optimistic local update
            HORDE.difficulty = capture
            -- Rebuild menu to show new selection
            self:Remove()
            HORDE.DifficultyGUI = nil
            timer.Simple(0.05, function()
                HORDE:ToggleDifficulty()
            end)
        end

        self.diff_panels[i].set_selected = function(sel)
            is_selected = sel
            sel_label:SetText(sel and "  ◀  CURRENT" or "")
            sel_label:SizeToContents()
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20, 235))
    -- Top crimson bar
    draw.RoundedBoxEx(4, 0, 0, w, 44, HORDE.color_crimson_dark, true, true, false, false)
end

vgui.Register("HordeDifficultyMenu", PANEL, "DPanel")
