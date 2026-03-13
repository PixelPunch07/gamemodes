-- =============================================================================
-- XENO ADAPTATION HUD  (client-side)
-- Displays a small panel in the bottom-right corner showing which elemental
-- damage types the Xeno horde has adapted to and how much resistance they have.
-- Only visible when HORDE.waveset == "xeno" and there is at least one active
-- adaptation.
-- =============================================================================

-- Local copy of adaptation table, kept in sync via net message.
local xeno_adapt_local = {}

net.Receive("Horde_XenoAdaptationSync", function()
    xeno_adapt_local = net.ReadTable()
end)

-- ----------------------------------------------------------------
-- Ordered list of adaptable types for consistent display order.
-- ----------------------------------------------------------------
local ADAPT_DISPLAY = {
    { id = HORDE.DMG_COLD,      label = "Cold",      color = HORDE.DMG_COLOR[HORDE.DMG_COLD]      },
    { id = HORDE.DMG_LIGHTNING, label = "Lightning", color = HORDE.DMG_COLOR[HORDE.DMG_LIGHTNING] },
    { id = HORDE.DMG_FIRE,      label = "Fire",      color = HORDE.DMG_COLOR[HORDE.DMG_FIRE]      },
    { id = HORDE.DMG_POISON,    label = "Poison",    color = HORDE.DMG_COLOR[HORDE.DMG_POISON]    },
    { id = HORDE.DMG_BLAST,     label = "Blast",     color = HORDE.DMG_COLOR[HORDE.DMG_BLAST]     },
}

local ADAPT_CAP         = 0.36
local BAR_W             = ScreenScale(90)
local BAR_H             = ScreenScale(10)
local ROW_H             = ScreenScale(14)
local LABEL_W           = ScreenScale(48)
local PAD                = ScreenScale(6)
local ICON_SIZE         = ScreenScale(10)

surface.CreateFont("Horde_XenoAdaptLabel", {
    font   = "Trebuchet MS",
    size   = math.floor(ScreenScale(6)),
    bold   = true,
    extended = true,
})

-- Panel anchored bottom-right.
local adapt_panel = vgui.Create("DPanel")
adapt_panel:SetSize(LABEL_W + BAR_W + PAD * 3, 1)  -- height is set dynamically
adapt_panel.Paint = function(pnl, pw, ph)
    if not GetConVar("horde_enable_client_gui") or GetConVarNumber("horde_enable_client_gui") == 0 then return end
    if HORDE.waveset ~= "xeno" then return end

    -- Collect active adaptations.
    local active = {}
    for _, entry in ipairs(ADAPT_DISPLAY) do
        local val = xeno_adapt_local[entry.id] or xeno_adapt_local[tostring(entry.id)]
        if val and val > 0 then
            table.insert(active, { entry = entry, val = val })
        end
    end

    if #active == 0 then return end

    -- Dynamic height.
    local panel_h = PAD * 2 + #active * ROW_H + ScreenScale(16)
    pnl:SetSize(pw, panel_h)
    pnl:SetPos(ScrW() - pw - ScreenScale(4), ScrH() - panel_h - ScreenScale(4))

    -- Background.
    draw.RoundedBox(4, 0, 0, pw, panel_h, Color(15, 30, 15, 200))
    -- Header.
    draw.SimpleText("XENO ADAPTATION", "Horde_XenoAdaptLabel",
        pw / 2, PAD + ScreenScale(4),
        Color(50, 220, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    -- Separator.
    surface.SetDrawColor(50, 220, 80, 120)
    surface.DrawRect(PAD, PAD + ScreenScale(9), pw - PAD * 2, 1)

    -- Rows.
    for idx, item in ipairs(active) do
        local y = PAD + ScreenScale(14) + (idx - 1) * ROW_H

        -- Label.
        draw.SimpleText(item.entry.label, "Horde_XenoAdaptLabel",
            PAD, y + ROW_H / 2,
            item.entry.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Bar background.
        local bar_x = LABEL_W + PAD
        draw.RoundedBox(3, bar_x, y + (ROW_H - BAR_H) / 2, BAR_W, BAR_H, Color(40, 40, 40, 200))

        -- Bar fill.
        local fill_frac = math.min(item.val / ADAPT_CAP, 1)
        local fill_w    = math.max(2, math.floor(BAR_W * fill_frac))
        -- Color lerp: green → yellow → red as it fills toward cap.
        local r = math.floor(255 * fill_frac)
        local g = math.floor(200 * (1 - fill_frac) + 50)
        local b = 30
        draw.RoundedBox(3, bar_x, y + (ROW_H - BAR_H) / 2, fill_w, BAR_H,
            Color(r, g, b, 220))

        -- Percentage text inside / next to bar.
        local pct_str = string.format("%.1f%%", item.val * 100)
        draw.SimpleText(pct_str, "Horde_XenoAdaptLabel",
            bar_x + BAR_W - PAD, y + ROW_H / 2,
            Color(220, 220, 220), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

-- Initial positioning (no active adaptations yet, size=1 is fine).
adapt_panel:SetPos(ScrW() - LABEL_W - BAR_W - PAD * 3 - ScreenScale(4), ScrH() - ScreenScale(4))
