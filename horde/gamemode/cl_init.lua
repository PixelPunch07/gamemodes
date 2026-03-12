include("shared.lua")
include("sh_particles.lua")
include("sh_translate.lua")
include("sh_horde.lua")
include("sh_gadget.lua")
include("sh_status.lua")
include("sh_damage.lua")
include("sh_infusion.lua")
include("sh_item.lua")
include("sh_class.lua")
include("sh_mutation.lua")
include("sh_enemy.lua")
include("sh_perk.lua")
include("sh_maps.lua")
include("sh_custom.lua")
include("sh_rank.lua")
include("sh_sync.lua")
include("sh_misc.lua")
include("sh_objective.lua")
include("sh_spells.lua")
include("sh_attachments.lua")

include("cl_economy.lua")
include("cl_achievement.lua")
include("cl_hitnumbers.lua")
include("gui/cl_gameinfo.lua")
include("gui/cl_status.lua")
include("gui/cl_ready.lua")
include("gui/cl_class.lua")
include("gui/cl_description.lua")
include("gui/cl_spelldescription.lua")
include("gui/cl_infusion.lua")
include("gui/cl_item.lua")
include("gui/cl_spellitem.lua")
include("gui/cl_itemconfig.lua")
include("gui/cl_classconfig.lua")
include("gui/cl_enemyconfig.lua")
include("gui/cl_mapconfig.lua")
include("gui/cl_configmenu.lua")
include("gui/cl_shop.lua")
include("gui/cl_spellforge.lua")
include("gui/cl_stats.lua")
include("gui/cl_summary.lua")
include("gui/cl_scoreboard.lua")
include("gui/cl_3d2d.lua")
include("gui/cl_subclassbutton.lua")
include("gui/cl_perkbutton.lua")
include("gui/cl_leaderboard.lua")
include("gui/cl_arccwcustomize.lua")
include("gui/cl_difficulty.lua")
include("gui/cl_waveset.lua")
include("gui/cl_startup_vote.lua")

include("status/sh_mind.lua")
include("gui/scoreboard/dpingmeter.lua")
include("gui/scoreboard/dheaderpanel.lua")
include("gui/scoreboard/dplayerline.lua")

include("arccw/attachments/horde_akimbo_deagle.lua")
include("arccw/attachments/horde_akimbo_m9.lua")
include("arccw/attachments/horde_akimbo_glock.lua")
include("arccw/attachments/horde_ubgl_medic.lua")
include("arccw/attachments/horde_ammo_ap.lua")
include("arccw/attachments/horde_ammo_sabot.lua")
include("arccw/attachments/horde_ubgl_m203.lua")

--include("arccw/attachments/horde_go_perk_burst_fire.lua")
--include("arccw/attachments/horde_go_perk_agile_maneuver.lua")
--include("arccw/attachments/horde_go_perk_auto_reload.lua")

--Shotgun ammo attachments--
include("arccw/attachments/horde_go_ammo_sg_triple.lua")
include("arccw/attachments/horde_go_ammo_sg_sabot.lua")
include("arccw/attachments/horde_go_ammo_sg_slug.lua")
include("arccw/attachments/horde_go_ammo_sg_scatter.lua")
include("arccw/attachments/horde_go_ammo_sg_magnum.lua")

include("arccw/attachments/horde_go_nova_mag_8.lua")
include("arccw/attachments/horde_go_mag7_mag_3.lua")
include("arccw/attachments/horde_go_mag7_mag_7.lua")
include("arccw/attachments/horde_go_870_mag_4.lua")
include("arccw/attachments/horde_go_870_mag_8.lua")
include("arccw/attachments/horde_go_m1014_mag_4.lua")
include("arccw/attachments/horde_go_m1014_mag_8.lua")

-- Some users report severe lag with halo
CreateConVar("horde_enable_halo", 1, FCVAR_ARCHIVE + FCVAR_LUA_CLIENT, "Enables highlight for last 10 enemies.")

MySelf = MySelf or NULL
hook.Add("InitPostEntity", "GetLocal", function()
    MySelf = LocalPlayer()

    GAMEMODE.HookGetLocal = GAMEMODE.HookGetLocal or function(g) end
    gamemode.Call("HookGetLocal", MySelf)
    RunConsoleCommand("initpostentity")
end)

function HORDE:ToggleShop()
    if MySelf:Horde_GetCurrentSubclass() == "Necromancer" or MySelf:Horde_GetCurrentSubclass() == "Artificer" or MySelf:Horde_GetCurrentSubclass() == "Warlock" then
        if not HORDE.ShopGUI then
            HORDE.ShopGUI = vgui.Create("HordeSpellForge")
            HORDE.ShopGUI:SetVisible(false)
        end
    
        if HORDE.ShopGUI:IsVisible() then
            HORDE.ShopGUI:Hide()
            gui.EnableScreenClicker(false)
        else
            HORDE.ShopGUI:Remove()
            if HORDE.StatsGUI then
                HORDE.StatsGUI:Remove()
            end
            HORDE.ShopGUI = vgui.Create("HordeSpellForge")
            HORDE.ShopGUI:Show()
            gui.EnableScreenClicker(true)
        end
        return
    end
    if not HORDE.ShopGUI then
        HORDE.ShopGUI = vgui.Create("HordeShop")
        HORDE.ShopGUI:SetVisible(false)
    end

    if HORDE.ShopGUI:IsVisible() then
        HORDE.ShopGUI:Hide()
        gui.EnableScreenClicker(false)
    else
        HORDE.ShopGUI:Remove()
        if HORDE.StatsGUI then
            HORDE.StatsGUI:Remove()
        end
        HORDE.ShopGUI = vgui.Create("HordeShop")
        HORDE.ShopGUI:Show()
        gui.EnableScreenClicker(true)
    end
end

function HORDE:ToggleStats()
    if not HORDE.StatsGUI then
        HORDE.StatsGUI = vgui.Create("HordeStats")
        HORDE.StatsGUI:SetVisible(false)
    end

    if HORDE.StatsGUI:IsVisible() then
        HORDE.StatsGUI:Hide()
        gui.EnableScreenClicker(false)
        timer.Remove("Horde_PollStats")
    else
        if HORDE.ShopGUI then
            HORDE.ShopGUI:Remove()
        end
        HORDE.StatsGUI:Remove()
        HORDE.StatsGUI = vgui.Create("HordeStats")
        HORDE.StatsGUI:Show()
        gui.EnableScreenClicker(true)
        HORDE:GetStats()
        timer.Create("Horde_PollStats", 1, 0, function ()
            HORDE:GetStats()
        end)
    end
end

function HORDE:ToggleItemConfig()
    if not HORDE.ItemConfigGUI then
        HORDE.ItemConfigGUI = vgui.Create("HordeItemConfig")
        HORDE.ItemConfigGUI:SetVisible(false)
    end

    if HORDE.ItemConfigGUI:IsVisible() then
        HORDE.ItemConfigGUI:Hide()
        gui.EnableScreenClicker(false)
    else
        HORDE.ItemConfigGUI:Show()
        gui.EnableScreenClicker(true)
    end
end

function HORDE:ToggleEnemyConfig()
    if not HORDE.EnemyConfigGUI then
        HORDE.EnemyConfigGUI = vgui.Create("HordeEnemyConfig")
        HORDE.EnemyConfigGUI:SetVisible(false)
    end

    if HORDE.EnemyConfigGUI:IsVisible() then
        HORDE.EnemyConfigGUI:Hide()
        gui.EnableScreenClicker(false)
    else
        HORDE.EnemyConfigGUI:Show()
        gui.EnableScreenClicker(true)
    end
end

function HORDE:ToggleClassConfig()
    if not HORDE.ClassConfigGUI then
        HORDE.ClassConfigGUI = vgui.Create("HordeClassConfig")
        HORDE.ClassConfigGUI:SetVisible(false)
    end

    if HORDE.ClassConfigGUI:IsVisible() then
        HORDE.ClassConfigGUI:Hide()
        gui.EnableScreenClicker(false)
    else
        HORDE.ClassConfigGUI:Show()
        gui.EnableScreenClicker(true)
    end
end

function HORDE:ToggleMapConfig()
    if not HORDE.MapConfigGUI then
        HORDE.MapConfigGUI = vgui.Create("HordeMapConfig")
        HORDE.MapConfigGUI:SetVisible(false)
    end
    
    if HORDE.MapConfigGUI:IsVisible() then
        HORDE.MapConfigGUI:Hide()
        gui.EnableScreenClicker(false)
    else
        HORDE.MapConfigGUI:Show()
        gui.EnableScreenClicker(true)
    end
end

function HORDE:ToggleConfigMenu()
    if not HORDE.ConfigMenuGUI then
        HORDE.ConfigMenuGUI = vgui.Create("HordeConfigMenu")
        HORDE.ConfigMenuGUI:SetVisible(false)
    end

    if HORDE.ConfigMenuGUI:IsVisible() then
        HORDE.ConfigMenuGUI:Hide()
        gui.EnableScreenClicker(false)
    else
        HORDE.ConfigMenuGUI:Show()
        gui.EnableScreenClicker(true)
    end
end

function HORDE:ToggleDifficulty()
    if HORDE.DifficultyGUI and HORDE.DifficultyGUI:IsValid() then
        if HORDE.DifficultyGUI:IsVisible() then
            HORDE.DifficultyGUI:Hide()
            gui.EnableScreenClicker(false)
            return
        end
        HORDE.DifficultyGUI:Remove()
    end
    HORDE.DifficultyGUI = vgui.Create("HordeDifficultyMenu")
    HORDE.DifficultyGUI:Show()
    gui.EnableScreenClicker(true)
end

-- Entity Highlights
HORDE.Player_Looking_At_Minion = nil
if GetConVarNumber("horde_enable_halo") == 1 then
    hook.Add("PreDrawHalos", "Horde_AddMinionHalos", function()
        local ent = util.TraceLine(util.GetPlayerTrace(MySelf)).Entity
        if ent and ent:IsValid() then
            if ent:GetNWEntity("HordeOwner") and ent:GetNWEntity("HordeOwner") == MySelf then
                -- Do not highlight minions if they do not belong to you
                halo.Add({ent}, Color(0, 255, 0), 1, 1, 1, true, true)
                HORDE.Player_Looking_At_Minion = ent
            end
        else
            HORDE.Player_Looking_At_Minion = nil
        end
    end)
end

net.Receive("Horde_HighlightEntities", function (len, ply)
    if GetConVarNumber("horde_enable_halo") == 0 then return end
    local render = net.ReadUInt(3)
    if render == HORDE.render_highlight_enemies then
        hook.Add("PreDrawHalos", "Horde_AddEnemyHalos", function()
            local enemies = ents.FindByClass("npc*")
            for key, enemy in pairs(enemies) do
                if enemy:GetNWEntity("HordeOwner"):IsPlayer() then
                    -- Do not highlight friendly minions
                    enemies[key] = nil
                end
            end
            halo.Add(enemies, Color(255, 0, 0), 1, 1, 1, true, true)
        end)
    elseif render == HORDE.render_highlight_ammoboxes then
        hook.Add("PreDrawHalos", "Horde_AddAmmoBoxHalos", function()
            halo.Add(ents.FindByClass("horde_ammobox"), Color(0, 255, 0), 1, 1, 1, true, true)
            halo.Add(ents.FindByClass("horde_gadgetbox"), Color(255, 0, 0), 1, 1, 1, true, true)
        end)
        timer.Simple(10, function ()
            hook.Remove("PreDrawHalos", "Horde_AddAmmoBoxHalos")
        end)
    else
        hook.Remove("PreDrawHalos", "Horde_AddEnemyHalos")
        hook.Remove("PreDrawHalos", "Horde_AddAmmoBoxHalos")
    end
end)

net.Receive("Horde_HighlightSonar", function (len, ply)
    local entity = net.ReadEntity()
    local highlight = net.ReadBool()
    local idx = entity:EntIndex()
    if highlight == true then
        hook.Add("PreDrawHalos", "Horde_SonarHalo" .. idx, function()
            if !entity:IsValid() then hook.Remove("PreDrawHalos", "Horde_SonarHalo" .. idx) end
            halo.Add({entity}, Color(255, 255, 255), 5, 5, 1, true, true)
        end)
    else
        hook.Remove("PreDrawHalos", "Horde_SonarHalo" .. idx)
    end
end)

net.Receive("Horde_DeathMarkHighlight", function(len,ply)
    local entity = net.ReadEntity()
    local idx = entity:EntIndex()
    hook.Add("PreDrawHalos", "Horde_DeathMarkHalo" .. idx, function()
        if !entity:IsValid() then hook.Remove("PreDrawHalos", "Horde_DeathMarkHalo" .. idx) end
        halo.Add({entity}, Color(255, 0, 255), 3, 3, 1, true, true)
    end)
end)

net.Receive("Horde_HunterMarkHighlight", function(len,ply)
    local entity = net.ReadEntity()
    local idx = entity:EntIndex()
    hook.Add("PreDrawHalos", "Horde_HunterMarkHalo" .. idx, function()
        if !entity:IsValid() then hook.Remove("PreDrawHalos", "Horde_HunterMarkHalo" .. idx) end
        halo.Add({entity}, Color(0, 255, 255), 5, 5, 1, true, true)
    end)
end)

net.Receive("Horde_RemoveDeathMarkHighlight", function(len,ply)
    hook.Remove("PreDrawHalos", "Horde_DeathMarkHalo" .. net.ReadEntity():EntIndex())
end)

net.Receive("Horde_RemoveHunterMarkHighlight", function(len,ply)
    hook.Remove("PreDrawHalos", "Horde_HunterMarkHalo" .. net.ReadEntity():EntIndex())
end)

-- Performance friendly highlights (maybe)
local mark_remaining_enemies = {}
net.Receive("Horde_MarkRemainingEnemies", function()
    mark_remaining_enemies = net.ReadTable()
end)

local remaining_mat = Material("skull.png", "mips smooth")
local mat_white = Material("models/debug/debugwhite") -- Put this outside of rendering hook
hook.Add("PostDrawTranslucentRenderables", "Horde_MarkRemainingEnemies", function()
    if not mark_remaining_enemies then return end
    
    cam.IgnoreZ(true)
    render.SuppressEngineLighting(true)
    render.MaterialOverride(mat_white)
    render.SetColorModulation(1, 0.2, 0.2) -- 0 - 1
    
    for ent, _ in pairs(mark_remaining_enemies) do
        local entity = IsValid(ent)

        if !entity then
            mark_remaining_enemies[ent] = nil
            continue
        end

        local ply = LocalPlayer()
        local sData = {
        checkmode = 2,
        originVector = ply:EyePos(),
        targetEntity = ent,
        --advancedCheck = true,
        }
        if HORDE.IsInSight(sData) then continue end

        ent:DrawModel()
    end
    
    render.SetColorModulation(1, 1, 1)
    render.MaterialOverride()
    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
end)

-- Hitbox wireframe for debugging only --
hook.Add("PostDrawOpaqueRenderables", "renderhitbox", function()
    if GetConVar("horde_testing_render_hitboxes"):GetInt() == 0 then return end
    render.SetColorMaterial()
    for _, ent in ipairs(ents.FindByClass("npc_*")) do
        for hitgroup = 0, ent:GetHitBoxGroupCount() - 1 do
            for hitbox = 0, ent:GetHitBoxCount(hitgroup) - 1 do
                local mins, maxs = ent:GetHitBoxBounds(hitbox, hitgroup)
                local matrix = ent:GetBoneMatrix(ent:GetHitBoxBone(hitbox, hitgroup))
                if(matrix) then
                    local pos = matrix:GetTranslation()
                    render.DrawWireframeBox(pos, matrix:GetAngles(), mins, maxs, Color(0, 255, 255))
                end
            end
        end
    end
end)

net.Receive("Horde_ToggleShop", function ()
    HORDE:ToggleShop()
end)

net.Receive("Horde_ToggleItemConfig", function ()
    HORDE:ToggleItemConfig()
end)

net.Receive("Horde_ToggleEnemyConfig", function ()
    HORDE:ToggleEnemyConfig()
end)

net.Receive("Horde_ToggleClassConfig", function ()
    HORDE:ToggleClassConfig()
end)

net.Receive("Horde_ToggleMapConfig", function ()
    HORDE:ToggleMapConfig()
end)

net.Receive("Horde_ToggleConfigMenu", function ()
    HORDE:ToggleConfigMenu()
end)

net.Receive("Horde_ToggleDifficulty", function ()
    HORDE:ToggleDifficulty()
end)

net.Receive("Horde_ToggleStats", function ()
    HORDE:ToggleStats()
end)

net.Receive("Horde_ForceCloseShop", function ()
    if HORDE.ShopGUI then
        if HORDE.ShopGUI:IsVisible() then
            HORDE.ShopGUI:Hide()
        end
    end

    if HORDE.ItemConfigGUI then
        if HORDE.ItemConfigGUI:IsVisible() then
            HORDE.ItemConfigGUI:Hide()
        end
    end

    if HORDE.EnemyConfigGUI then
        if HORDE.EnemyConfigGUI:IsVisible() then
            HORDE.EnemyConfigGUI:Hide()
        end
    end

    HORDE.TipPanel:SetVisible(false)
    HORDE.leader_board:SetVisible(false)

    gui.EnableScreenClicker(false)
end)

net.Receive("Horde_SideNotification", function(length)
    local str = net.ReadString()
    local type = net.ReadInt(2)
    if string.find(str, "bought") then
        HORDE:PlayNotification(str, type, "status/canbuy.png")
    else
        HORDE:PlayNotification(str, type)
    end
end)

net.Receive("Horde_SideNotificationDebuff", function(length)
    local debuff = net.ReadUInt(32)
    local debuff_str = translate.Get("Notifications_Debuff_" .. HORDE.Status_String[debuff]) or HORDE.Debuff_Notifications[debuff]
    HORDE:PlayNotification(debuff_str, 0, HORDE.Status_Icon[debuff], HORDE.STATUS_COLOR[debuff])
end)

net.Receive("Horde_SideNotificationObjective", function(length)
    local obj = net.ReadUInt(4)
    local str = net.ReadString()
    HORDE:PlayNotification(str, 0, HORDE.Objective_Icon[obj], Color(0,255,0))
end)

net.Receive("Horde_SyncItems", function ()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    local str = util.Decompress(data)
    HORDE.items = util.JSONToTable(str)
end)

net.Receive("Horde_SyncEnemies", function ()
    local len = net.ReadUInt(32)
    local data = net.ReadData(len)
    local str = util.Decompress(data)
    HORDE.enemies = util.JSONToTable(str)
end)

net.Receive("Horde_SyncDifficulty", function ()
    HORDE.difficulty = net.ReadUInt(4)
end)

net.Receive("Horde_SyncMaps", function ()
    HORDE.map_whitelist = net.ReadTable()
    HORDE.map_blacklist = net.ReadTable()
end)

net.Receive("Horde_SyncMutations", function ()
    HORDE.mutations = net.ReadTable()
end)

hook.Add("HUDShouldDraw", "Horde_RemoveRetardRedScreen", function(name)
    if (name == "CHudDamageIndicator") then
       return false
    end
end)

net.Receive("Horde_GameEnd", function ()
    local status = net.ReadString()

    local mvp = net.ReadEntity()
    local mvp_damage = net.ReadUInt(32)
    local mvp_kills = net.ReadUInt(32)

    local damage_player = net.ReadEntity()
    local most_damage = net.ReadUInt(32)

    local kills_player = net.ReadEntity()
    local most_kills = net.ReadUInt(32)

    local most_heal_player = net.ReadEntity()
    local most_heal = net.ReadUInt(32)

    local headshot_player = net.ReadEntity()
    local most_headshots = net.ReadUInt(32)

    local elite_kill_player = net.ReadEntity()
    local most_elite_kills = net.ReadUInt(32)

    local damage_taken_player = net.ReadEntity()
    local most_damage_taken = net.ReadUInt(32)

    local total_damage = net.ReadUInt(32)

    local maps = net.ReadTable()

    local end_gui = vgui.Create("HordeSummaryPanel")
    end_gui:SetData(status, mvp, mvp_damage, mvp_kills, damage_player, most_damage, kills_player, most_kills, most_heal_player, most_heal, headshot_player, most_headshots, elite_kill_player, most_elite_kills, damage_taken_player, most_damage_taken, total_damage, maps)
end)

killicon.AddAlias("arccw_horde_awp", "arccw_go_awp")
killicon.AddAlias("arccw_horde_barret", "arccw_mw2_barrett")
killicon.Add("arccw_nade_medic", "arccw/weaponicons/arccw_nade_medic", Color(0, 0, 0, 255))
killicon.Add("npc_turret_floor", "vgui/hud/npc_turret_floor", Color(0, 0, 0, 255))
killicon.AddAlias("npc_vj_horde_shotgun_turret", "npc_turret_floor")
killicon.AddAlias("npc_vj_horde_sniper_turret", "npc_turret_floor")

-- =============================================================================
-- XENO FOG
-- Dense green atmospheric fog that rolls in at wave 10 of the Xeno waveset.
-- Uses CalcView to set engine-level fog parameters.
-- =============================================================================
local xeno_fog_active  = false
local xeno_fog_opacity = 0       -- 0..1, lerped in over time
local xeno_fog_target  = 0       -- target opacity (0 = off, 1 = full)

net.Receive("Horde_XenoFogStart", function()
    xeno_fog_active = true
    xeno_fog_target = 1
end)

net.Receive("Horde_XenoFogEnd", function()
    xeno_fog_target = 0
    -- Hook stays alive to lerp out; it removes itself once opacity reaches 0.
end)

hook.Add("CalcView", "Horde_XenoFog", function(ply, origin, angles, fov, znear, zfar)
    if not xeno_fog_active then return end

    -- Smoothly lerp opacity toward the target each frame.
    local dt = FrameTime()
    xeno_fog_opacity = math.Clamp(xeno_fog_opacity + (xeno_fog_target - xeno_fog_opacity) * dt * 0.8, 0, 1)

    -- Once fully faded out, deactivate entirely.
    if xeno_fog_target == 0 and xeno_fog_opacity < 0.005 then
        xeno_fog_active  = false
        xeno_fog_opacity = 0
        return
    end

    local view = {}
    view.origin   = origin
    view.angles   = angles
    view.fov      = fov
    view.znear    = znear
    view.zfar     = zfar

    -- Dense green fog that closes in hard from 80 to 900 units.
    view.fogenable     = true
    view.fogcolor      = Color(20, 160, 50)
    view.fogstart      = 80
    view.fogend        = 900
    view.fogmaxdensity = 0.92 * xeno_fog_opacity

    return view
end)

-- =============================================================================
-- XENO ADAPTATION HUD
-- Displays the current enemy damage-type adaptation resistances when any
-- resistance is non-zero and the XENO waveset is active.
-- =============================================================================
local XENO_HUD_ORDER = {
    HORDE.DMG_COLD,
    HORDE.DMG_LIGHTNING,
    HORDE.DMG_FIRE,
    HORDE.DMG_POISON,
    HORDE.DMG_BLAST,
    HORDE.DMG_BALLISTIC,
    HORDE.DMG_SLASH,
    HORDE.DMG_BLUNT,
    HORDE.DMG_PHYSICAL,
}

local ADAPT_LABEL = {
    [HORDE.DMG_COLD]      = "Frost",
    [HORDE.DMG_LIGHTNING] = "Shock",
    [HORDE.DMG_FIRE]      = "Fire",
    [HORDE.DMG_POISON]    = "Poison",
    [HORDE.DMG_BLAST]     = "Blast",
    [HORDE.DMG_BALLISTIC] = "Ballistic",
    [HORDE.DMG_SLASH]     = "Slash",
    [HORDE.DMG_BLUNT]     = "Blunt",
    [HORDE.DMG_PHYSICAL]  = "Physical",
}

local ADAPT_COLOR = {
    [HORDE.DMG_COLD]      = Color(100, 220, 255),
    [HORDE.DMG_LIGHTNING] = Color(255, 230, 50),
    [HORDE.DMG_FIRE]      = Color(255, 100, 40),
    [HORDE.DMG_POISON]    = Color(180, 80, 220),
    [HORDE.DMG_BLAST]     = Color(255, 160, 40),
    [HORDE.DMG_BALLISTIC] = Color(200, 200, 200),
    [HORDE.DMG_SLASH]     = Color(200, 200, 200),
    [HORDE.DMG_BLUNT]     = Color(200, 200, 200),
    [HORDE.DMG_PHYSICAL]  = Color(200, 200, 200),
}

hook.Add("HUDPaint", "Horde_XenoAdaptationHUD", function()
    if not HORDE.xeno_adaptation then return end
    if HORDE.waveset ~= "xeno" then return end

    -- Collect adapted types.
    local active = {}
    for _, dmg_type in ipairs(XENO_HUD_ORDER) do
        local resist = HORDE.xeno_adaptation[dmg_type]
        if resist and resist > 0 then
            table.insert(active, { dmg_type = dmg_type, resist = resist })
        end
    end
    if #active == 0 then return end

    -- Layout
    local sw, sh = ScrW(), ScrH()
    local row_h   = ScreenScale(12)
    local padding = ScreenScale(5)
    local bar_w   = ScreenScale(60)
    local label_w = ScreenScale(48)
    local total_h = padding * 2 + #active * (row_h + ScreenScale(2)) + ScreenScale(14)
    local total_w = label_w + bar_w + padding * 3
    local x = sw - total_w - ScreenScale(8)
    local y = sh * 0.35

    -- Background
    draw.RoundedBox(4, x - padding, y - padding, total_w + padding * 2, total_h, Color(10, 10, 10, 180))

    -- Title
    draw.SimpleText("XENO ADAPTATION", "Horde_Ready", x + total_w * 0.5, y, Color(60, 220, 80), TEXT_ALIGN_CENTER)
    y = y + ScreenScale(14)

    for _, entry in ipairs(active) do
        local dt    = entry.dmg_type
        local pct   = math.floor(entry.resist * 100 + 0.5)
        local frac  = entry.resist / 0.36  -- progress toward cap
        local col   = ADAPT_COLOR[dt] or Color(200, 200, 200)
        local lbl   = ADAPT_LABEL[dt] or "???"

        -- Label
        draw.SimpleText(lbl, "Horde_Ready", x, y + row_h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Bar background
        local bx = x + label_w
        draw.RoundedBox(2, bx, y, bar_w, row_h, Color(30, 30, 30, 200))

        -- Bar fill  (goes red as it nears cap)
        local fill_col = Color(
            Lerp(frac, col.r * 0.6, 220),
            Lerp(frac, col.g * 0.6, 30),
            Lerp(frac, col.b * 0.6, 30)
        )
        draw.RoundedBox(2, bx, y, math.max(2, bar_w * frac), row_h, fill_col)

        -- Percentage text
        draw.SimpleText(pct .. "%", "Horde_Ready", bx + bar_w + ScreenScale(3), y + row_h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        y = y + row_h + ScreenScale(2)
    end
end)
