if CLIENT then
	local lang = {}
	lang[ "zh-cn" ] = {
		[ "Weapon" ] = "钉锤",
		[ "Purpose" ] = "用木板封住门窗,或用来维修其它设施.",
		[ "Instruct" ] = "左键放置木板/维修物品/拆除物品\nE+左右键旋转木板\n右键打开放置模式面板\nR键快速切换模式",
		[ "Author" ] = "作者",
		[ "Purpose2" ] = "目的",
		[ "Mode" ] = "模式",
		[ "Mode0" ] = "破坏",
		[ "Mode1" ] = "维修",
		[ "Mode2" ] = "钉子",
		[ "Mode3" ] = "放置",
		[ "Health" ] = "血量",
		[ "Plank" ] = "木板",
		[ "Angle" ] = "角度",
	}
	lang[ "en" ] = {
		[ "Weapon" ] = "Barricade",
		[ "Purpose" ] = "Place wooden planks or repair things",
		[ "Instruct" ] = "M1 - place planks/repair or destroy things\nE+M1/E+M2 - rotate placement angle\nM2 - select placement mode\nR - quick switch",
		[ "Author" ] = "Author",
		[ "Purpose2" ] = "Purpose",
		[ "Mode" ] = "Mode",
		[ "Mode0" ] = "Destruct",
		[ "Mode1" ] = "Repair",
		[ "Mode2" ] = "Nail",
		[ "Mode3" ] = "Build",
		[ "Health" ] = "Health",
		[ "Plank" ] = "Plank",
		[ "Angle" ] = "Angle",
	}
	lang[ "de" ] = {
		[ "Weapon" ] = "Barrikade",
		[ "Purpose" ] = "Holzbretter platzieren oder Dinge reparieren",
		[ "Instruct" ] = "M1 – Bretter platzieren/Dinge reparieren oder zerstören\nE+M1/E+M2 – Platzierungswinkel drehen\nM2 – Platzierungsmodus auswählen\nR - schnell umschalten",
		[ "Author" ] = "Autor",
		[ "Purpose2" ] = "Zweck",
		[ "Mode" ] = "Modus",
		[ "Mode0" ] = "Zerstören",
		[ "Mode1" ] = "Reparatur",
		[ "Mode2" ] = "Nagel",
		[ "Mode3" ] = "Ort",
		[ "Health" ] = "Gesundheit",
		[ "Plank" ] = "Planke",
		[ "Angle" ] = "Winkel",
	}
	lang[ "ru" ] = {
		[ "Weapon" ] = "Молоток",
		[ "Purpose" ] = "Ставьте деревянные доски или ремонтируйте вещи",
		[ "Instruct" ] = "M1 - поставить доски/починить или уничтожить вещи\nE+M1/E+M2 – повернуть угол размещения\nM2 – 2 - выберите режим размещения\nR - быстрый переключатель",
		[ "Author" ] = "Автор",
		[ "Purpose2" ] = "Цель",
		[ "Mode" ] = "Режим",
		[ "Mode0" ] = "Уничтожить",
		[ "Mode1" ] = "Ремонт",
		[ "Mode2" ] = "Гвозди",
		[ "Mode3" ] = "Построить",
		[ "Health" ] = "Здоровье",
		[ "Plank" ] = "Планка",
		[ "Angle" ] = "Угол",
	}
	lang[ "fr" ] = {
		[ "Weapon" ] = "Marteau",
		[ "Purpose" ] = "Placer des planches de bois ou réparer des choses",
		[ "Instruct" ] = "M1 - placer des planches/réparer ou détruire des choses\nE+M1/E+M2 – faire pivoter l'angle de placement\nM2 – 2 - sélectionner le mode de placement\nR - commutateur rapide",
		[ "Author" ] = "Auteur",
		[ "Purpose2" ] = "Objectif",
		[ "Mode" ] = "Mode",
		[ "Mode0" ] = "Détruire",
		[ "Mode1" ] = "Réparation",
		[ "Mode2" ] = "Ongles",
		[ "Mode3" ] = "Lieu",
		[ "Health" ] = "Santé",
		[ "Plank" ] = "Planche",
		[ "Angle" ] = "Angle",
	}
	lang[ "pl" ] = {
		[ "Weapon" ] = "Młotek",
		[ "Purpose" ] = "Układanie drewnianych desek lub naprawa przedmiotów",
		[ "Instruct" ] = "M1 - stawiaj deski/naprawiaj lub niszcz rzeczy\nE+M1/E+M2 - obrócić kąt umieszczenia\nM2 - wybierz tryb umieszczania\nR - szybkie przełączanie",
		[ "Author" ] = "Autor",
		[ "Purpose2" ] = "Cel",
		[ "Mode" ] = "Tryb",
		[ "Mode0" ] = "Zniszczyć",
		[ "Mode1" ] = "Naprawa",
		[ "Mode2" ] = "Paznokcie",
		[ "Mode3" ] = "Miejsce",
		[ "Health" ] = "Zdrowie",
		[ "Plank" ] = "Deska",
		[ "Angle" ] = "Kąt",
	}
	lang[ "ja" ] = {
		[ "Weapon" ] = "ハンマー",
		[ "Purpose" ] = "木の板を置いたり、物を修理したりする",
		[ "Instruct" ] = "M1 - 板を置く/物を修理または破壊する\nE+M1/E+M2 - 配置角度を回転する\nM2 - 配置モードを選択します\nR - クイックスイッチ",
		[ "Author" ] = "著者",
		[ "Purpose2" ] = "目的",
		[ "Mode" ] = "モード",
		[ "Mode0" ] = "破壊",
		[ "Mode1" ] = "修理",
		[ "Mode2" ] = "釘",
		[ "Mode3" ] = "コンストラクト",
		[ "Health" ] = "健康",
		[ "Plank" ] = "板",
		[ "Angle" ] = "角度",
	}
	local ln, lg = string.lower( GetConVar( "gmod_language" ):GetString() ), "en"
	if ln != nil and istable( lang[ ln ] ) then lg = ln end
	for holder, text in pairs( lang[ lg ] ) do
		language.Add( "xdebc."..holder, text )
	end
	language.Add( "weapon_xdebarricade", language.GetPhrase( "xdebc.Weapon" ) )
	surface.CreateFont( "xde_Select", { font = "Halflife2", size = 128, weight = 1, antialias = true, bold = true } )
	killicon.AddFont( "weapon_xdebarricade", "HL2MPTypeDeath", "6", Color( 255, 255, 255, 255 ) )
	surface.CreateFont( "xdebc_Font1", { font = "tahoma", size = 32, weight = 100, antialias = true } )
	surface.CreateFont( "xdebc_Font2", { font = "tahoma", size = 24, weight = 100, antialias = true } )
end

local SVConvars = bit.bor( FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_LUA_SERVER )
CreateConVar( "xdebc_hp", "10", SVConvars, "Maximum health multiplier for reinforced planks", 1, 100 )
CreateConVar( "xdebc_nailhp", "5", SVConvars, "Maximum health multiplier for nails, default max health is 10, 0=unbreakable", 0, 100 )
CreateClientConVar( "xdebc_max", "0", true, true, "Fully reinforce your planks when placed, admin only", 0, 1 )

sound.Add( {
	name = "xdebarricade.hitworld",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 75,
	pitch = { 90, 95 },
	sound = ")weapons/hammer/hit_world01.wav"
} )
sound.Add( {
	name = "xdebarricade.hit",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 75,
	pitch = { 100, 105 },
	sound = ")weapons/hammer/hit_melee01.wav"
} )
sound.Add( {
	name = "xdebarricade.hitplank",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 75,
	pitch = { 100, 105 },
	sound = {
		")weapons/plank/plank_hit-01.wav",
		")weapons/plank/plank_hit-02.wav",
		")weapons/plank/plank_hit-03.wav",
		")weapons/plank/plank_hit-04.wav"
	}
} )
sound.Add( {
	name = "xdebarricade.hitfix",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 75,
	pitch = { 100, 105 },
	sound = {
		")weapons/hammer/hit_nail01.wav",
		")weapons/hammer/hit_nail02.wav",
		")weapons/hammer/hit_nail03.wav",
		")weapons/hammer/hit_nail04.wav"
	}
} )
sound.Add( {
	name = "xdebarricade.hitmiss",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 75,
	pitch = { 100, 105 },
	sound = ")weapons/iceaxe/iceaxe_swing1.wav"
} )

local xdebc_Planks = {
	{ "models/props_debris/wood_board01a.mdl", Angle( 0, 0, 0 ), Vector( 1, 2, 64 ), 60 },
	{ "models/props_debris/wood_board02a.mdl", Angle( 0, 0, 0 ), Vector( 1, 2, 32 ), 25 },
	{ "models/props_debris/wood_board03a.mdl", Angle( 0, 0, 0 ), Vector( 1, 4, 64 ), 60 },
	{ "models/props_debris/wood_board04a.mdl", Angle( 0, 0, 0 ), Vector( 1, 4, 32 ), 25 },
	{ "models/props_debris/wood_board05a.mdl", Angle( 0, 0, 0 ), Vector( 1, 8, 64 ), 60 },
	{ "models/props_debris/wood_board06a.mdl", Angle( 0, 0, 0 ), Vector( 1, 8, 32 ), 25 },
	{ "models/props_debris/wood_board07a.mdl", Angle( 0, 0, 0 ), Vector( 4, 4, 64 ), 60 },
	{ "models/props_wasteland/dockplank01b.mdl", Angle( 0, 0, 0 ), Vector( 7, 101, 1 ), 90 },
}

AddCSLuaFile()

SWEP.PrintName		= "#xdebc.Weapon"
SWEP.Author 		= "LemonCola3424"
SWEP.Purpose 		= "#xdebc.Purpose"
SWEP.Instructions	= "#xdebc.Instruct"
SWEP.Category 		= "Other"
SWEP.ViewModelFOV	= 64
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/c_barricadeswep.mdl"
SWEP.WorldModel		= "models/weapons/w_barricadeswep.mdl"
SWEP.Spawnable		= true
SWEP.AdminOnly		= false
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "None"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "None"
SWEP.Weight					= 0
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.RightOnce 				= false
SWEP.ReloadOnce 			= false

if SERVER then
	util.AddNetworkString( "xdebc_S2C_Gesture" )
	util.AddNetworkString( "xdebc_S2C_Menu" )
	util.AddNetworkString( "xdebc_C2S_Menu" )
	util.AddNetworkString( "xdebc_C2S_Model" )
	util.AddNetworkString( "xdebc_C2S_Finish" )
	function xdebc_Unfreeze( ent )
		if !IsValid( ent ) or !IsValid( ent:GetPhysicsObject() ) then return end
		if !istable( ent.XDE_Planks ) then return end
		for k, v in pairs( ent.XDE_Planks ) do
			if !IsValid( v ) then return end
			if !v:IsInWorld() then v:Remove() continue end
			if true then
				v:SetParent()
				if IsValid( v:GetPhysicsObject() ) then
					v:GetPhysicsObject():Wake()
					v:GetPhysicsObject():EnableMotion( true )
					xdebc_Unfreeze( v )
				end
			end
		end
		ent.XDE_Planks = nil
	end
	net.Receive( "xdebc_C2S_Finish", function( len, ply )
		if !IsValid( ply ) or !ply:IsPlayer() or len > 0 then return end
		if !IsValid( ply:GetActiveWeapon() ) or ply:GetActiveWeapon():GetClass() != "weapon_horde_xdebarricade"
		or !ply:GetActiveWeapon():GetXDE_Menu() then return end local wep = ply:GetActiveWeapon()
		local vm = ply:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ) )
		vm:SetPlaybackRate( 1 )
		wep:IdleAnim()
		wep:SetHoldType( "slam" )
		wep:SetNextSecondaryFire( CurTime() +0.2 )
		wep:SetXDE_Menu( false )
	end )
	net.Receive( "xdebc_C2S_Model", function( len, ply )
		if !IsValid( ply ) or !ply:IsPlayer() or len <= 0 or len >= 128 then return end
		local wep = ply:GetWeapon( "weapon_horde_xdebarricade" )
		if IsValid( wep ) and wep:GetNextSecondaryFire() <= CurTime() then
			wep:SetXDE_Mode( 3 )
			wep:SetXDE_Model( math.Round( net.ReadFloat() ) )
			wep:SetNextSecondaryFire( CurTime() +0.05 )
		end
	end )
	net.Receive( "xdebc_C2S_Menu", function( len, ply )
		if !IsValid( ply ) or !ply:IsPlayer() or len <= 0 or len >= 128 then return end
		local wep = ply:GetWeapon( "weapon_horde_xdebarricade" )
		if IsValid( wep ) and wep:GetNextSecondaryFire() <= CurTime() then
			wep:SetXDE_Mode( math.Clamp( math.Round( net.ReadFloat() ), 0, 9 ) )
			wep:SetNextSecondaryFire( CurTime() +0.05 )
		end
	end )
	hook.Add( "EntityTakeDamage", "xdebc_takedmg", function( tar, dmg )
		if dmg:GetDamage() > 0 and tar:Health() > 0 and tar:GetMaxHealth() > 0 then
			if IsValid( dmg:GetAttacker() ) and tar:GetNWBool( "XDEBC_Nail" ) and tar != Entity( 0 ) and tar != dmg:GetAttacker() then
				tar:SetHealth( math.max( 0, tar:Health() -dmg:GetDamage() ) )
				if tar:Health() <= 0 then
					tar:SetNWBool( "XDEBC_Nail", false )
					tar:EmitSound( "Metal_Box.BulletImpact" )
					timer.Simple( 0, function()
						if IsValid( tar ) then
							local eff = EffectData()
							eff:SetOrigin( tar:WorldSpaceCenter() -tar:GetForward()*2 )
							eff:SetNormal( -tar:GetForward() )
							eff:SetMagnitude( 1 )
							eff:SetRadius( 2 )
							eff:SetScale( 2 )
							util.Effect( "Sparks", eff )
							tar:Remove()
						end
					end )
				end
			end
		end
	end )
	hook.Add( "PostEntityTakeDamage", "xdebc_takedmg", function( tar, dmg, act )
		if act and dmg:GetDamage() > 0 and tar:Health() > 0 and tar:GetMaxHealth() > 0 then
			if !tar:IsPlayer() and !tar:IsNPC() and !tar:IsNextBot() then
				tar:SetNWInt( "XDEBC_HP", tar:Health() )
				tar:SetNWInt( "XDEBC_MP", tar:GetMaxHealth() )
			end
		end
	end )
else
	if IsValid( XDEBCMenu ) then XDEBCMenu:Remove() end
	XDEBCMenu = nil
	local Zom = Material( "vgui/zoom" )
	net.Receive( "xdebc_S2C_Gesture", function()
		local ent, act = net.ReadEntity(), math.Round( net.ReadFloat() )
		if IsValid( ent ) and ent:GetClass() == "weapon_horde_xdebarricade" and IsValid( ent.Owner )
		and ent.Owner:GetActiveWeapon() == ent then
			ent:DoGesture( act )
		end
	end )
	net.Receive( "xdebc_S2C_Menu", function()
		local ply, mode, mdl = LocalPlayer(), math.Round( net.ReadFloat() ), math.Round( net.ReadFloat() )
		surface.PlaySound( "common/wpn_hudon.wav" )
		timer.Remove( "xdebc_hidemenu" )
		if IsValid( XDEBCMenu ) then
			local pan = XDEBCMenu
			pan:Show()
			pan:SetAlpha( 1 )
			pan:AlphaTo( 255, 0.1 )
        	pan:SetMouseInputEnabled( true )
        	pan:SetKeyboardInputEnabled( true )
			pan.N_Close = CurTime() +0.15
			pan.N_Mode = mode
			pan.N_Blur = SysTime()
			return
		end
		XDEBCMenu = vgui.Create( "DFrame" )
		local pan = XDEBCMenu
		pan:SetSize( 800, 600 )
		pan:Center()
		pan:MakePopup()
        pan:SetMouseInputEnabled( true )
        pan:SetKeyboardInputEnabled( true )
		pan:ShowCloseButton( false )
		pan:SetTitle( "" )
		pan:SetAlpha( 1 )
		pan:AlphaTo( 255, 0.2 )
		pan.N_Mode = mode
		pan.N_Model = mdl
		pan.N_Close = CurTime() +0.15
		pan.N_Blur = SysTime()
		pan.N_Delay = CurTime() +0.1
		function pan:Paint( w, h )
			Derma_DrawBackgroundBlur( pan, pan.N_Blur )
		end
		function pan:Think()
			local ply = LocalPlayer()
			if ( !IsValid( ply ) or !input.IsMouseDown( MOUSE_RIGHT ) or !IsValid( ply:GetActiveWeapon() ) or ply:GetActiveWeapon():GetClass() != "weapon_horde_xdebarricade")
			and pan.N_Close > 0 and pan.N_Close <= CurTime() then
				pan.N_Close = 0
                pan:AlphaTo( 1, 0.1 )
				pan:SetMouseInputEnabled( false )
				pan:SetKeyboardInputEnabled( false )
				net.Start( "xdebc_C2S_Finish" )
				net.SendToServer()
                timer.Create( "xdebc_hidemenu", 0.15, 1, function()
                    if IsValid( pan ) then pan:Hide() end
                end )
				surface.PlaySound( "common/wpn_hudoff.wav" )
			end
		end

        for i=1, 3 do
            local but = pan:Add( "DButton" )
            but:SetSize( 200, 60 )
            but:SetPos( 300 +( i == 1 and -250 or ( i == 3 and 250 or 0 ) ), 500 )
            but:SetText( "" )
            but.B_Hover = false
            but.N_Lerp = 0
			but.N_Mode = i-1
			but.N_Clicked = 0
            function but:Paint( w, h )
                but.N_Lerp = Lerp( 0.2, but.N_Lerp, ( but.B_Hover or but.N_Mode == pan.N_Mode ) and 1 or 0 )
                local ler, sel = but.N_Lerp, ( but.N_Mode == pan.N_Mode )
                surface.SetDrawColor( Color( 55 +( sel and 0 or ler*100 ), 55 +ler*155, 55, 55 ) )
                surface.DrawRect( 0, 0, w, h )
				if but.N_Clicked > CurTime() then
					local cli = math.Clamp( ( but.N_Clicked-CurTime() )/0.4, 0, 1 )
					surface.SetDrawColor( Color( 255 -( sel and ler*255 or 0 ), 255, 255 -ler*255, cli*255 ) )
					surface.DrawRect( w/2, 0, w/2*( 1-cli ) +1, h )
					surface.DrawRect( w/2 -w/2*( 1-cli ) +1, 0, w/2*( 1-cli ), h )
				end
                surface.SetDrawColor( 255, 255, 255, 55 +ler*55 )
                surface.SetMaterial( Zom )
                surface.DrawTexturedRectRotated( w/2, h/2, w, h, 0 )
                surface.DrawTexturedRectRotated( w/2, h/2, w, h, 180 )

                surface.SetDrawColor( Color( 0, 0, 0 ) )
                surface.DrawOutlinedRect( 0, 0, w, h, 3 )
                surface.SetDrawColor( Color( 255 -( sel and ler*255 or 0 ), 255, 255 -ler*255 ) )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )

                draw.TextShadow( {
                    text = language.GetPhrase( "xdebc.Mode"..but.N_Mode ),
                    pos = { w/2, h/2 },
                    font = "xdebc_Font1",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = Color( 255 -( sel and ler*255 or 0 ), 255, 255 -ler*255 )
                }, 1, alp )
            end
            function but:OnCursorEntered() but.B_Hover = true end
            function but:OnCursorExited() but.B_Hover = false end
            function but:DoClick()
				if pan.N_Mode == but.N_Mode or pan.N_Delay > CurTime() then return end
				but.N_Clicked = CurTime() +0.4
				pan.N_Mode = but.N_Mode
				net.Start( "xdebc_C2S_Menu" )
				net.WriteFloat( but.N_Mode )
				net.SendToServer()
				surface.PlaySound( "common/wpn_moveselect.wav" )
            end
        end
        for i=1, 8 do
			local mdl = xdebc_Planks[ i ][ 1 ]
            local but = pan:Add( "DButton" )
            but:SetSize( 175, 175 )
            but:SetPos( 12.5 +200*( i <= 4 and i -1 or i -5 ), 50 +( i <= 4 and 0 or 200 ) )
            but:SetText( "" )
			but:SetToolTip( mdl )
            but.B_Hover = false
            but.N_Lerp = 0
			but.N_Model = i
			but.N_Clicked = 0
            function but:Paint( w, h )
                but.N_Lerp = Lerp( 0.2, but.N_Lerp, ( but.B_Hover or ( pan.N_Mode == 3 and but.N_Model == pan.N_Model ) ) and 1 or 0 )
                local ler, sel = but.N_Lerp, ( but.N_Model == pan.N_Model and pan.N_Mode == 3 )
                surface.SetDrawColor( Color( 55 +( sel and 0 or ler*100 ), 55 +ler*155, 55, 55 ) )
                surface.DrawRect( 0, 0, w, h )
				if but.N_Clicked > CurTime() then
					local cli = math.Clamp( ( but.N_Clicked-CurTime() )/0.4, 0, 1 )
					surface.SetDrawColor( Color( 255 -( sel and ler*255 or 0 ), 255, 255 -ler*255, cli*255 ) )
					surface.DrawRect( 0, 0, w, h )
				end
				surface.SetDrawColor( Color( 0, 0, 0, 200 -ler*200 ) )
				surface.DrawRect( 0, h -35, w, 35 )
				surface.SetDrawColor( 255, 255, 255, 55 +ler*55 )
                surface.SetMaterial( Zom )
                surface.DrawTexturedRectRotated( w/2, h/2, w, h, 0 )
                surface.DrawTexturedRectRotated( w/2, h/2, w, h, 180 )
                surface.SetDrawColor( Color( 0, 0, 0 ) )
                surface.DrawOutlinedRect( 0, 0, w, h, 3 )
                surface.SetDrawColor( Color( 255 -( sel and ler*255 or 0 ), 255, 255 -ler*255 ) )
                surface.DrawOutlinedRect( 0, 0, w, h, 2 )
                draw.TextShadow( {
                    text = i,
                    pos = { w/2, h -20 },
                    font = "xdebc_Font2",
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = Color( 255 -( sel and ler*255 or 0 ), 255, 255 -ler*255 )
                }, 1, alp )
            end
            function but:OnCursorEntered() but.B_Hover = true end
            function but:OnCursorExited() but.B_Hover = false end
            function but:DoClick()
				if ( pan.N_Mode == 3 and pan.N_Model == but.N_Model ) or pan.N_Delay > CurTime() then return end
				but.N_Clicked = CurTime() +0.4
				pan.N_Model = but.N_Model
				pan.N_Mode = 3
				net.Start( "xdebc_C2S_Model" )
				net.WriteFloat( but.N_Model )
				net.SendToServer()
				surface.PlaySound( "common/wpn_moveselect.wav" )
            end
			local ico = but:Add( "ModelImage" )
			ico:DockMargin( 5, 5, 5, 5 )
			ico:Dock( FILL )
			ico:SetModel( mdl )
			ico:SetMouseInputEnabled( false )
			ico:SetKeyboardInputEnabled( false )
        end
	end )
end

if CLIENT then
	SWEP.Slot				= 0
	SWEP.SlotPos			= 10
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false
	SWEP.UseHands           = true
	SWEP.SwayScale			= 1
	SWEP.BobScale			= 1
	SWEP.BounceWeaponIcon	= false
	SWEP.CrossMove 			= 0
	SWEP.PosFX 				= 0
	SWEP.PosFY 				= 0
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.Text( {
			text = "c",
			pos = { x +wide/2, y +tall/2 },
			font = "xde_Select",
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 255, 255, 255 )
		} )
		y = y+10
		x = x+10
		wide = wide-20
		self:PrintWeaponInfo( x+wide+20, y +tall*0.95, alpha )
	end
	local Mat = Material( "gui/gradient_up" )
	function SWEP:PrintWeaponInfo( x, y, alpha )
		if self.InfoMarkup == nil then
			local str, title_color, text_color = "", "<color=255,255,255,255>", "<color=200,200,200,255>"
			str = "<font=TargetID>"
			if ( self.Author != "" ) then str = str..title_color..language.GetPhrase( "xdebc.Author" )..": </color>"..text_color..self.Author.."</color>\n" end
			if ( self.Purpose != "" ) then str = str..title_color..language.GetPhrase( "xdebc.Purpose2" )..": </color>"..text_color..language.GetPhrase( self.Purpose ).."</color>\n" end
			if ( self.Instructions != "" ) then str = str..title_color.."\n</color>"..text_color..language.GetPhrase( self.Instructions ).."</color>\n" end
			self.InfoMarkup = markup.Parse( str, 350 )
		end
		local xx, yy, ww, hh = x-6, y-6, 362, self.InfoMarkup:GetHeight() +24
		draw.RoundedBox( 0, xx, yy, ww, hh, Color( 100, 100, 100, 255, alpha ) )
		surface.SetDrawColor( 55, 55, 55, 255 )
		surface.SetMaterial( Mat )
		surface.DrawTexturedRect( xx, yy, ww, hh )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawOutlinedRect( xx, yy, ww, hh, 2 )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawOutlinedRect( xx, yy, ww, hh, 1 )
		self.InfoMarkup:Draw( x + 5, y + 5, nil, nil, alpha )
		self.InfoMarkup = nil
	end 
	function SWEP:DrawHUD()
		local own = LocalPlayer()
		if !IsValid( own ) or !own:Alive() then return end
		if GetConVar( "cl_drawhud" ):GetInt() <= 0 or vgui.CursorVisible() then self.CrossMove = 0 return end
		local mode = self:GetXDE_Mode()
		if mode <= 1 then
			local tr = util.TraceLine( {
				start = own:GetShootPos(),
				endpos = own:GetShootPos() +own:GetAimVector()*96,
				filter = own,
				mask = MASK_SHOT_HULL
			} )
			if !IsValid( tr.Entity ) then
				tr = util.TraceHull( {
					start = own:GetShootPos(),
					endpos = own:GetShootPos() +own:GetAimVector()*96,
					filter = own,
					mins = Vector( -2, -2, -2 ),
					maxs = Vector( 2, 2, 2 ),
					mask = MASK_SHOT_HULL
				} )
			end
			local ent, si, txt, col = tr.Entity, self.CrossMove, "", Color( 255, 255, 255 )
			local ww, hh, al, md = ScrW()/2, ScrH()/2, false, self:GetXDE_Mode()
			if IsValid( ent ) then
				if !ent:IsWorld() then
					ww, hh = ent:WorldSpaceCenter():ToScreen().x, ent:WorldSpaceCenter():ToScreen().y
				end
				if md == 0 then
					if ent:Health() > 0 or ent:GetNWBool( "XDEBC_Nail" ) then
						col = Color( 255, 0, 0 )
					else
						col = Color( 255, 255, 0 )
					end
				elseif md == 1 then
					if ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() or ent:Health() <= 0 or ent:GetMaxHealth() <= 0 then
						col = Color( 255, 255, 0 )
					else
						local hp, mp = ent:Health(), ent:GetMaxHealth()
						local mhp
						if ent:GetNWInt( "XDEBC_HP" ) > 0 then
							hp, mp = ent:GetNWInt( "XDEBC_HP" ), ent:GetNWInt( "XDEBC_MP" )
						end
						if ent:GetNWBool( "XDEBC_Nail" ) then
							mhp = math.ceil( ent:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_nailhp" ):GetFloat() ) )
						else
							mhp = math.ceil( ent:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_hp" ):GetFloat() ) )
						end
						if hp >= mhp then
							col = Color( 0, 255, 255 )
						else
							col = Color( 0, 255, 0 )
						end
					end
				end
				al = true
			end
			ww = math.Clamp( ww, si*2, ScrW() -si*2 )
			hh = math.Clamp( hh, si*2, ScrH() -si*2 )
			self.PosFX = Lerp( 0.2, self.PosFX, ww )
			self.PosFY = Lerp( 0.2, self.PosFY, hh )
			local ww, hh = self.PosFX, self.PosFY
			self.CrossMove = Lerp( 0.2, self.CrossMove, al and 25 or 50 )
			surface.SetDrawColor( col )
			surface.DrawLine( ww-si, hh-si, ww-si, hh -si/2 ) surface.DrawLine( ww-si, hh-si, ww -si/2, hh -si )
			surface.DrawLine( ww+si, hh+si, ww+si, hh +si/2 ) surface.DrawLine( ww+si, hh+si, ww +si/2, hh +si )
			surface.DrawLine( ww-si, hh+si, ww-si, hh +si/2 ) surface.DrawLine( ww-si, hh+si, ww -si/2, hh+si )
			surface.DrawLine( ww+si, hh-si, ww+si, hh -si/2 ) surface.DrawLine( ww+si, hh-si, ww +si/2, hh-si )
			draw.TextShadow( {
				text = language.GetPhrase( "xdebc.Mode" )..":",
				pos = { ww, hh +si*2 },
				font = "xdebc_Font2",
				xalign = TEXT_ALIGN_RIGHT,
				yalign = TEXT_ALIGN_CENTER,
				color = col
			}, 1, 255 )
			draw.TextShadow( {
				text = language.GetPhrase( "xdebc.Mode"..math.Clamp( self:GetXDE_Mode(), 0, 3 ) ),
				pos = { ww, hh +si*2 },
				font = "xdebc_Font2",
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER,
				color = col
			}, 1, 255 )
			if IsValid( ent ) and ( !ent:IsNPC() and !ent:IsPlayer() and !ent:IsNextBot() ) then
				local hp, mp = ent:Health(), ent:GetMaxHealth()
				if ent:GetNWInt( "XDEBC_HP" ) > 0 then
					hp, mp = ent:GetNWInt( "XDEBC_HP" ), ent:GetNWInt( "XDEBC_MP" )
				end
				if ( hp > 0 and mp > 0 ) or ent:GetNWBool( "XDEBC_Nail" ) then
					draw.TextShadow( {
						text = language.GetPhrase( "xdebc.Health" )..":"..hp.."/"..mp,
						pos = { ww, hh +si*3 },
						font = "xdebc_Font2",
						xalign = TEXT_ALIGN_CENTER,
						yalign = TEXT_ALIGN_CENTER,
						color = col
					}, 1, 255 )
				end
			end
		elseif mode == 2 then
			local col, tab = Color( 255, 255, 255 ), xdebc_Planks[ self:GetXDE_Model() ]
			local tr = util.TraceLine( {
				start = own:GetShootPos(),
				endpos = own:GetShootPos() +own:GetAimVector()*96,
				filter = own,
				mask = MASK_SHOT_HULL
			} )
			local yes = ( tr.Hit and ( !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() ) )
			col = ( yes and Color( 0, 255, 0 ) or Color( 255, 255, 0 ) )
			if self:GetXDE_Cant() then col = Color( 255, 0, 0 ) end
			if yes and self:GetNextPrimaryFire() <= CurTime() then
				local pi = 3.141592654
				local po1, an1 = tr.HitPos, tr.HitNormal:Angle()
				cam.Start3D()
				render.SetColorMaterial()
				render.DrawBox( po1, own:EyeAngles(), Vector( -4, -1, -1 ), Vector( 8, 1, 1 ), Color( col.r, col.g, col.b, 55 ) )
				render.DrawWireframeBox( po1, own:EyeAngles(), Vector( -4, -1, -1 ), Vector( 8, 1, 1 ), Color( col.r, col.g, col.b, 155 ) )
				render.DrawWireframeBox( po1, own:EyeAngles(), Vector( -4.02, -1.02, -1.02 ), Vector( 8.02, 1.02, 1.02 ), Color( 0, 0, 0, 155 ) )
				cam.End3D()
			end

			local ww, hh = ScrW()/2, ScrH()/2
			self.PosFX = Lerp( 0.2, self.PosFX, ww )
			self.PosFY = Lerp( 0.2, self.PosFY, hh )
			local ww, hh = self.PosFX, self.PosFY

			draw.TextShadow( {
				text = language.GetPhrase( "xdebc.Mode" )..":",
				pos = { ww, hh +100 },
				font = "xdebc_Font2",
				xalign = TEXT_ALIGN_RIGHT,
				yalign = TEXT_ALIGN_CENTER,
				color = col
			}, 1, 255 )
			draw.TextShadow( {
				text = language.GetPhrase( "xdebc.Mode2" ),
				pos = { ww, hh +100 },
				font = "xdebc_Font2",
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER,
				color = col
			}, 1, 255 )
		else
			local col, tab = Color( 255, 255, 255 ), xdebc_Planks[ self:GetXDE_Model() ]
			local tr = util.TraceLine( {
				start = own:GetShootPos(),
				endpos = own:GetShootPos() +own:GetAimVector()*96,
				filter = own,
				mask = MASK_SHOT_HULL
			} )
			local yes = ( tr.Hit and ( !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() ) )
			col = ( yes and Color( 0, 255, 0 ) or Color( 255, 255, 0 ) )
			if self:GetXDE_Cant() then col = Color( 255, 0, 0 ) end
			if yes and self:GetNextPrimaryFire() <= CurTime() then
				local pi = 3.141592654
				local po1, an1 = self:GetXDE_Pos(), self:GetXDE_Ang()
				cam.Start3D()
				render.SetColorMaterial()
				render.DrawBox( po1, an1, -tab[ 3 ], tab[ 3 ], Color( col.r, col.g, col.b, 55 ) )
				render.DrawWireframeBox( po1, an1, -tab[ 3 ], tab[ 3 ], Color( col.r, col.g, col.b, 155 ) )
				render.DrawWireframeBox( po1, an1, -tab[ 3 ] -Vector( 0.02, 0.02, 0.02 ), tab[ 3 ] +Vector( 0.02, 0.02, 0.02 ), Color( 0, 0, 0, 155 ) )
				cam.End3D()
			end

			local ww, hh = ScrW()/2, ScrH()/2
			self.PosFX = Lerp( 0.2, self.PosFX, ww )
			self.PosFY = Lerp( 0.2, self.PosFY, hh )
			local ww, hh = self.PosFX, self.PosFY

			draw.TextShadow( {
				text = language.GetPhrase( "xdebc.Mode" )..":",
				pos = { ww, hh +100 },
				font = "xdebc_Font2",
				xalign = TEXT_ALIGN_RIGHT,
				yalign = TEXT_ALIGN_CENTER,
				color = col
			}, 1, 255 )
			draw.TextShadow( {
				text = language.GetPhrase( "xdebc.Mode3" ),
				pos = { ww, hh +100 },
				font = "xdebc_Font2",
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER,
				color = col
			}, 1, 255 )
		end
	end
end
function SWEP:IdleAnim()
	if CLIENT then return end
	local own = self.Owner
	timer.Remove( "weapon_idle"..self:EntIndex() )
	timer.Create( "weapon_idle"..self:EntIndex(), self:SequenceDuration() +FrameTime()*10, 1, function()
		if IsValid( self ) and IsValid( own ) and own:GetActiveWeapon() == self then
			self:SendWeaponAnim( ACT_VM_IDLE )
		end
	end )
end
function SWEP:DoGesture( act )
	local own = self.Owner
	if CLIENT then
		own:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, act, true )
	else
		net.Start( "xdebc_S2C_Gesture" )
		net.WriteEntity( self )
		net.WriteFloat( act )
		net.Broadcast()
	end
end
function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "XDE_Mode" )
	self:NetworkVar( "Int", 1, "XDE_Angle" )
	self:NetworkVar( "Int", 2, "XDE_Model" )
	self:NetworkVar( "Bool", 0, "XDE_Menu" )
	self:NetworkVar( "Bool", 1, "XDE_Cant" )
	self:NetworkVar( "Vector", 0, "XDE_Pos" )
	self:NetworkVar( "Angle", 0, "XDE_Ang" )
	self:NetworkVarNotify( "XDE_Mode", function()
		if CLIENT then
			self.CrossMove = 0
			self.PosFX = ScrW()/2
			self.PosFY = ScrH()/2
		end
	end )
end
function SWEP:Initialize()
	if SERVER then
		self:SetXDE_Menu( false )
		self:SetXDE_Cant( false )
		self:SetXDE_Mode( 0 )
		self:SetXDE_Model( 1 )
	end
	self:SetHoldType( "slam" )
	self.RightOnce = false
end
function SWEP:Deploy() local own = self.Owner
	self:SetHoldType( "slam" )
	self:IdleAnim()
	self.RightOnce = false
	if SERVER then
		self:SetXDE_Menu( false )
	end
	self:NextThink( CurTime() )
	return true
end
function SWEP:PrimaryAttack() local own = self.Owner
	if !IsValid( own ) or !own:IsPlayer() then return end
	if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
	if own:KeyDown( IN_USE ) then
		self:SetXDE_Angle( self:GetXDE_Angle()%360 -15*( own:KeyDown( IN_SPEED ) and 2 or 1 ) )
		self:EmitSound( "buttons/lightswitch2.wav", 70, 110, 0.5, CHAN_ITEM )
		self:SetNextSecondaryFire( CurTime() +0.2 )
		return
	end
	local mode = self:GetXDE_Mode()
	if mode == 0 or mode == 1 then

		own:LagCompensation( true )
		local tr = util.TraceLine( {
			start = own:GetShootPos(),
			endpos = own:GetShootPos() +own:GetAimVector()*96,
			filter = own,
			mask = MASK_SHOT_HULL
		} )
		if !IsValid( tr.Entity ) then
			tr = util.TraceHull( {
				start = own:GetShootPos(),
				endpos = own:GetShootPos() +own:GetAimVector()*96,
				filter = own,
				mins = Vector( -2, -2, -2 ),
				maxs = Vector( 2, 2, 2 ),
				mask = MASK_SHOT_HULL
			} )
		end
		local ent, yes = tr.Entity, false
		if SERVER then
			if IsValid( ent ) and ( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() ) and ent:Health() > 0 and ent:GetMaxHealth() > 0 then
				own:EmitSound( "xdebarricade.hit" )   
				
			elseif tr.Hit then  
				if IsValid( ent ) and ent:Health() > 0 then
					if mode == 0 then
						own:EmitSound( "xdebarricade.hitworld" )
						giveamount = ent:GetMaxHealth() *ent:Health()*0.0041
		self.Owner:Horde_AddMoney(giveamount)
		 self.Owner:Horde_SyncEconomy()
					print(giveamount)
					else
						local mhp = math.ceil( ent:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_hp" ):GetFloat() ) )
						if ent:Health() >= mhp then
							own:EmitSound( "xdebarricade.hitworld" )
								
						else
							own:EmitSound( "xdebarricade.hitfix" )
							
						end
					end
					yes = true
				else
					own:EmitSound( "xdebarricade.hitworld" )
					
				end
			else
				own:EmitSound( "xdebarricade.hitmiss" )
			end
		end
		if SERVER and IsValid( ent ) then
			if mode == 0 or ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
				local dmg = DamageInfo()
				dmg:SetAttacker( own )
				dmg:SetInflictor( self )
				dmg:SetDamage( yes and ent:Health()*10 or ( mode == 0 and 40 or 20 ) )
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetDamagePosition( tr.HitPos )
				dmg:SetDamageForce( own:EyeAngles():Forward()*16384 )
				ent:DispatchTraceAttack( dmg, tr, tr.HitNormal )
			elseif ent:Health() > 0 and ent:GetMaxHealth() > 0 then
				local mhp
				if ent:GetNWBool( "XDEBC_Nail" ) then
					mhp = math.ceil( ent:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_nailhp" ):GetFloat() ) )
				else
					mhp = math.ceil( ent:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_hp" ):GetFloat() ) )
				end
				if ent:Health() < mhp then
					local pos = tr.HitPos +tr.HitNormal
					timer.Simple( 0, function()
						local eff = EffectData()
						eff:SetOrigin( pos )
						eff:SetMagnitude( 2 )
						eff:SetRadius( 1 )
						eff:SetScale( 1 )
						util.Effect( "ElectricSpark", eff )
					end )
				end
				ent:RemoveAllDecals()
				if ent:IsOnFire() then ent:Extinguish() end
				ent:SetHealth( math.min( mhp, ent:Health() +( ent:GetNWBool( "XDEBC_Nail" ) and 10 or 20 ) ) )
			end
			if !ent:IsPlayer() and !ent:IsNPC() and !ent:IsNextBot() then
				ent:SetNWInt( "XDEBC_HP", ent:Health() )
				ent:SetNWInt( "XDEBC_MP", ent:GetMaxHealth() )
			end
		end
		self:SendWeaponAnim( ACT_VM_HITCENTER )
		if SERVER then
			self:DoGesture( mode == 0 and ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE or ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE )
		end
		self:IdleAnim()
		own:LagCompensation( false )
		self:SetNextPrimaryFire( CurTime() +( mode == 0 and 0.8 or 0.4 ) )
		self:SetNextSecondaryFire( CurTime() +0.2 )
	elseif mode == 2 and own:CheckLimit( "props" ) then
		own:LagCompensation( true )
		local tr = util.TraceLine( {
			start = own:GetShootPos(),
			endpos = own:GetShootPos() +own:GetAimVector()*96,
			filter = own,
			mask = MASK_SHOT_HULL
		} )
		local yes = ( tr.Hit and ( !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() ) )
		if SERVER and yes and !self:GetXDE_Cant() then
			local ent = tr.Entity
			self:SendWeaponAnim( ACT_VM_HITKILL )
			if SERVER then
				self:DoGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
			end
			self:IdleAnim()
			local pos, nor = tr.HitPos, own:EyeAngles():Forward()
			local nai = ents.Create( "prop_physics" )
			nai:SetModel( "models/props_mining/railroad_spike01.mdl" )
			nai:SetPos( pos -nor*4 )
			nai:SetAngles( nor:Angle() )
			nai:Spawn()
			nai:Activate()
			nai:SetCollisionGroup( COLLISION_GROUP_WORLD )
			nai.XDE_BCEnt = ent
			nai:SetNWBool( "XDEBC_Nail", true )
			nai:GetPhysicsObject():SetMass( 1 )
			if GetConVar( "xdebc_nailhp" ):GetFloat() > 0 then
				nai:SetMaxHealth( 10 )
				nai:SetHealth( 10 )
				if own:IsAdmin() and own:GetInfoNum( "xdebc_max", 0 ) > 0 then
					local mhp = math.ceil( nai:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_nailhp" ):GetFloat() ) )
					nai:SetHealth( mhp )
				end
			end

			constraint.NoCollide( nai, ent, 0, tr.PhysicsBone )
			local wld, fil, lat = 1, {}, nil
			while wld <= 8 do
				local t2 = util.TraceLine( {
					start = pos -nor*2,
					endpos = pos +nor*8,
					filter = { own, nai, unpack( fil ) },
					mask = MASK_SHOT_HULL
				} )
				local bon, tar = t2.PhysicsBone, t2.Entity
				if ( !IsValid( tar ) and tar != Entity( 0 ) ) or tar == lat then
					break
				else
					wld = wld +1
					if tar == Entity( 0 ) or ( !NADMOD or NADMOD.PlayerCanTouch( own, tar ) ) then
						constraint.Weld( nai, tar, 0, bon, 0, true )
					end
					constraint.NoCollide( nai, tar, 0, bon )
					lat = tar
					table.insert( fil, lat )
				end
				if tar == Entity( 0 ) then
					nai:GetPhysicsObject():EnableMotion( false )
				end
			end
			if NADMOD then
				NADMOD.PlayerMakePropOwner( own, nai )
			end
			hook.Run( "PlayerSpawnedProp", own, nai:GetModel(), nai )
			undo.Create( "#xdebc.Mode2" )
			undo.AddEntity( nai )
			undo.SetPlayer( own )
			undo.Finish()
			cleanup.Add( own, "props", nai )
			local nor = tr.HitNormal
			timer.Simple( 0, function()
				local eff = EffectData()
				eff:SetOrigin( pos +nor )
				eff:SetNormal( nor )
				eff:SetMagnitude( 1 )
				eff:SetRadius( 2 )
				eff:SetScale( 2 )
				util.Effect( "Sparks", eff )
			end )
			own:EmitSound( "Weapon_Crossbow.BoltHitWorld" )
			self:SetNextPrimaryFire( CurTime() +0.8 )
			self:SetNextSecondaryFire( CurTime() +0.2 )
			if !ent:IsWorld() then
				local dmg = DamageInfo()
				dmg:SetAttacker( own )
				dmg:SetInflictor( self )
				dmg:SetDamage( 1 )
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetDamagePosition( tr.HitPos )
				dmg:SetDamageForce( own:EyeAngles():Forward()*1024 )
				ent:DispatchTraceAttack( dmg, tr, tr.HitNormal )
			end
		else
			self:SetNextSecondaryFire( CurTime() +0.2 )
		end
		own:LagCompensation( false )

	elseif mode == 3 and own:CheckLimit( "props" ) then
		own:LagCompensation( true )
		local tab = xdebc_Planks[ self:GetXDE_Model() ]
		local tr = util.TraceLine( {
			start = own:GetShootPos(),
			endpos = own:GetShootPos() +own:GetAimVector()*96,
			filter = own,
			mask = MASK_SHOT_HULL
		} )
		local yes = ( tr.Hit and ( !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() ) )
		if SERVER and yes and !self:GetXDE_Cant() then
			local pi = 3.141592654
			local pos, ang = tr.HitPos, ( ( tr.HitPos +tr.HitNormal )-( tr.HitPos -tr.HitNormal ) ):Angle()
			local ori, deg = Vector( 0, 0, 0 ), self:GetXDE_Angle()
			local po1, an1, po2, an2
			if self:GetXDE_Model() == 8 then
				deg = -deg +180
				ori = Vector( 0, -tab[ 4 ]*math.cos( deg*pi/180 ), tab[ 4 ]*math.sin( deg*pi/180 ) )
				po1, an1 = LocalToWorld( ori, Angle( deg +90, 90, 90 ) +tab[ 2 ], pos, ang )
				ori = Vector( 0, -tab[ 4 ]*2*math.cos( deg*pi/180 ), tab[ 4 ]*2*math.sin( deg*pi/180 ) )
				po2, an2 = LocalToWorld( ori, Angle( deg +90, 90, 90 ) +tab[ 2 ], pos, ang )
			else
				ori = Vector( 0, tab[ 4 ]*math.cos( deg*pi/180 ), tab[ 4 ]*math.sin( deg*pi/180 ) )
				po1, an1 = LocalToWorld( ori, Angle( 0, 0, deg +90 ) +tab[ 2 ], pos, ang )
				ori = Vector( 0, tab[ 4 ]*2*math.cos( deg*pi/180 ), tab[ 4 ]*2*math.sin( deg*pi/180 ) )
				po2, an2 = LocalToWorld( ori, Angle( 0, 0, deg +90 ) +tab[ 2 ], pos, ang )
			end
			local t1 = util.TraceLine( {
				start = pos,
				endpos = po2,
				mask = MASK_SHOT_HULL
			} )
			if !t1.Hit then 
				local plk = ents.Create( "prop_physics" )
			
				plk:SetModel( tab[ 1 ] )
				plk:SetPos( po1 +tr.HitNormal*0.25 )
				plk:SetAngles( an1 )
				plk:Spawn()
				plk:SetMaxHealth( plk:GetMaxHealth()*1.5 )
				plk:SetHealth(plk:GetMaxHealth())
				plk:SetOwner(self.Owner)
			giveamount = plk:GetMaxHealth() *plk:Health()*0.0041
			if self.Owner:Horde_GetMoney() >= giveamount then
				local ent = tr.Entity
				self:SendWeaponAnim( ACT_VM_HITKILL )
				if SERVER then
					self:DoGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM )
				end
				self:IdleAnim()

		
		self.Owner:Horde_AddMoney(-giveamount)
		 self.Owner:Horde_SyncEconomy()
				plk:Activate()
				if own:IsAdmin() and own:GetInfoNum( "xdebc_max", 0 ) > 0 then
					local mhp = math.ceil( ent:GetMaxHealth()*math.max( 1, GetConVar( "xdebc_hp" ):GetFloat() ) )
					plk:SetHealth( mhp )
				end
				plk.XDE_BCEnt = ent
				if ent:GetMoveType() == MOVETYPE_VPHYSICS and IsValid( ent:GetPhysicsObject() ) and !IsValid( ent:GetParent() ) then
					plk:GetPhysicsObject():Wake()
					plk:GetPhysicsObject():EnableMotion( ent:GetPhysicsObject():IsMotionEnabled() )
				else
					if !ent:IsWorld() then
						plk:SetParent( ent )
					end
					plk:GetPhysicsObject():EnableMotion( false )
				end
				if !ent:IsWorld() then
					constraint.NoCollide( plk, ent, 0, tr.PhysicsBone )
					if ent == Entity( 0 ) or ( !NADMOD or NADMOD.PlayerCanTouch( own, ent ) ) then
						constraint.Weld( plk, ent, 0, tr.PhysicsBone, 0, true )
					end
					if !istable( ent.XDE_Planks ) then ent.XDE_Planks = {} end
					ent:CallOnRemove( "XDE_DropPlanks", function()
						xdebc_Unfreeze( ent )
					end )
					table.insert( ent.XDE_Planks, plk )
				end
				if NADMOD then
					NADMOD.PlayerMakePropOwner( own, plk )
				end
				hook.Run( "PlayerSpawnedProp", own, tab[ 1 ], plk )
				undo.Create( "#xdebc.Plank" )
				undo.AddEntity( plk )
				undo.SetPlayer( own )
				undo.Finish()
				cleanup.Add( own, "props", plk )
				local nor = tr.HitNormal
				timer.Simple( 0, function()
					local eff = EffectData()
					eff:SetOrigin( pos +nor )
					eff:SetNormal( nor )
					eff:SetMagnitude( 1 )
					eff:SetRadius( 2 )
					eff:SetScale( 2 )
					util.Effect( "Sparks", eff )
				end )
				own:EmitSound( "xdebarricade.hitplank" )
				self:SetNextPrimaryFire( CurTime() +0.8 )
				self:SetNextSecondaryFire( CurTime() +0.2 )
				print("hit")


				if !ent:IsWorld() then
					local dmg = DamageInfo()
					dmg:SetAttacker( own )
					dmg:SetInflictor( self )
					dmg:SetDamage( 5 )
					dmg:SetDamageType( DMG_CLUB )
					dmg:SetDamagePosition( tr.HitPos )
					dmg:SetDamageForce( own:EyeAngles():Forward()*1024 )
					ent:DispatchTraceAttack( dmg, tr, tr.HitNormal )
				end
				else
				plk:remove()
				end
			else
				self:SetNextSecondaryFire( CurTime() +0.2 )
			end
		else
			self:SetNextSecondaryFire( CurTime() +0.2 )
		end
		own:LagCompensation( false )
	end
end
function SWEP:SecondaryAttack() local own = self.Owner
	if !IsValid( own ) or !own:IsPlayer() then return end
	if self:GetNextSecondaryFire() > CurTime() or self.RightOnce then return end
	if own:KeyDown( IN_USE ) then
		self:SetXDE_Angle( self:GetXDE_Angle()%360 +15*( own:KeyDown( IN_SPEED ) and 2 or 1 ) )
		self:EmitSound( "buttons/lightswitch2.wav", 60, 100, 0.5, CHAN_ITEM )
		self:SetNextSecondaryFire( CurTime() +0.2 )
		return
	end
	if SERVER then
		net.Start( "xdebc_S2C_Menu" )
		net.WriteFloat( self:GetXDE_Mode() )
		net.WriteFloat( self:GetXDE_Model() )
		net.Send( own )
		timer.Remove( "weapon_idle"..self:EntIndex() )
		local vm = own:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "holster" ) )
		vm:SetPlaybackRate( 1 )
		self:SetXDE_Menu( true )
		self:SetHoldType( "passive" )
	end
	self.RightOnce = true
	self:SetNextSecondaryFire( CurTime() +0.2 )
end
function SWEP:Reload() local own = self.Owner
	if !IsValid( own ) or !own:IsPlayer() or self:GetXDE_Menu() then return end
	if self:GetNextSecondaryFire() > CurTime() or self.ReloadOnce or self.RightOnce then return end
	if SERVER then
		self:SetXDE_Mode( self:GetXDE_Mode() >= 3 and 0 or self:GetXDE_Mode() +1 )
	end
	self.ReloadOnce = true
	self:SetNextSecondaryFire( CurTime() +0.1 )
end
function SWEP:Think() local own = self.Owner
	if !IsValid( own ) or !own:IsPlayer() then return end
	if !own:KeyDown( IN_ATTACK2 ) and self.RightOnce and self:GetNextPrimaryFire() <= CurTime() and !self:GetXDE_Menu() then
		self.RightOnce = false
	end
		if !own:KeyDown( IN_RELOAD ) and self.ReloadOnce and self:GetNextPrimaryFire() <= CurTime() and !self:GetXDE_Menu() then
			self.ReloadOnce = false
		end
	if SERVER and self:GetXDE_Mode() >= 2 then
		own:LagCompensation( true )
		local tab = xdebc_Planks[ self:GetXDE_Model() ]
		
		local tr = util.TraceLine( {
			start = own:GetShootPos(),
			endpos = own:GetShootPos() +own:GetAimVector()*96,
			filter = own,
			mask = MASK_SHOT_HULL
		} )
		local yes = ( tr.Hit and ( !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() ) )
		if yes then
			local pi = 3.141592654
			local pos, ang = tr.HitPos, ( ( tr.HitPos +tr.HitNormal )-( tr.HitPos -tr.HitNormal ) ):Angle()
			local ori, deg = Vector( 0, 0, 0 ), self:GetXDE_Angle()
			local po1, an1, po2, an2
			if self:GetXDE_Mode() == 2 then
				po1, an1 = tr.HitPos, tr.HitNormal:Angle()

				self:SetXDE_Cant( false )
			else
				if self:GetXDE_Model() == 8 then
					deg = -deg +180
					ori = Vector( 0, -tab[ 4 ]*math.cos( deg*pi/180 ), tab[ 4 ]*math.sin( deg*pi/180 ) )
					po1, an1 = LocalToWorld( ori, Angle( deg +90, 90, 90 ) +tab[ 2 ], pos, ang )
					ori = Vector( 0, -tab[ 4 ]*2*math.cos( deg*pi/180 ), tab[ 4 ]*2*math.sin( deg*pi/180 ) )
					po2, an2 = LocalToWorld( ori, Angle( deg +90, 90, 90 ) +tab[ 2 ], pos, ang )
				else
					ori = Vector( 0, tab[ 4 ]*math.cos( deg*pi/180 ), tab[ 4 ]*math.sin( deg*pi/180 ) )
					po1, an1 = LocalToWorld( ori, Angle( 0, 0, deg +90 ) +tab[ 2 ], pos, ang )
					ori = Vector( 0, tab[ 4 ]*2*math.cos( deg*pi/180 ), tab[ 4 ]*2*math.sin( deg*pi/180 ) )
					po2, an2 = LocalToWorld( ori, Angle( 0, 0, deg +90 ) +tab[ 2 ], pos, ang )
				end
				self:SetXDE_Pos( po1 )
				self:SetXDE_Ang( an1 )
				local t1 = util.TraceLine( {
					start = pos,
					endpos = po2,
					mask = MASK_SHOT_HULL
				} )
				self:SetXDE_Cant( t1.Hit )
			end
		else
			self:SetXDE_Cant( true )
		end
		own:LagCompensation( false )
	end
	self:NextThink( CurTime() +0.25 )
	return true
end
function SWEP:Holster()
	timer.Remove( "weapon_idle"..self:EntIndex() )
	if CLIENT then
		self.CrossMove = 0
		self.PosFX = ScrW()/2
		self.PosFY = ScrH()/2
	else
		self:SetXDE_Menu( false )
	end
	return true
end