AddCSLuaFile("shared.lua")
include("shared.lua")
include("autorun/vj_controls.lua")
-- Core
ENT.Model       = {"models/horde/gonome/gonome.mdl"}
ENT.StartHealth = 35000         
ENT.HullType    = HULL_MEDIUM_TALL
ENT.KnockbackImmune = true

ENT.SightDistance   = 12000
ENT.SightAngle      = 180        -- Sees all around
ENT.TurningSpeed    = 55
ENT.MaxJumpLegalDistance = VJ_Set(400, 600)

-- AI
ENT.VJ_NPC_Class                        = {"CLASS_ZOMBIE", "CLASS_XEN"}
ENT.ConstantlyFaceEnemy                 = true
ENT.ConstantlyFaceEnemy_IfAttacking     = true
ENT.ConstantlyFaceEnemy_Postures        = "Both"
ENT.ConstantlyFaceEnemyDistance         = 3000
ENT.FindEnemy_CanSeeThroughWalls        = true
ENT.NoChaseAfterCertainRange            = false
ENT.InvestigateSoundDistance            = 200

ENT.AttackProps     = true
ENT.PushProps       = true
ENT.PropAP_MaxSize  = 3

-- Damage/Injured
ENT.BloodColor      = "Green"
ENT.Immune_Dissolve = true
ENT.Immune_Physics  = true

-- Flinch
ENT.CanFlinch       = 0
ENT.NextFlinchTime  = 3
ENT.AnimTbl_Flinch  = {ACT_FLINCH_PHYSICS}
ENT.RunAwayOnUnknownDamage  = false
ENT.CallForBackUpOnDamage   = false

-- Melee — heavy hits, always bleeds
ENT.HasMeleeAttack                  = true
ENT.AnimTbl_MeleeAttack             = {ACT_MELEE_ATTACK1}
ENT.MeleeAttackDistance             = 38
ENT.MeleeAttackDamageDistance       = 100
ENT.TimeUntilMeleeAttackDamage      = 0.55
ENT.NextAnyAttackTime_Melee         = 0.7
ENT.MeleeAttackDamage               = 200        -- Hyperbuffed
ENT.SlowPlayerOnMeleeAttack         = true
ENT.SlowPlayerOnMeleeAttack_WalkSpeed = 80
ENT.SlowPlayerOnMeleeAttack_RunSpeed  = 80
ENT.MeleeAttackBleedEnemy           = true       -- VJ base bleed flag
ENT.HasExtraMeleeAttackSounds       = true
ENT.MeleeAttackWorldShakeOnMiss     = true
ENT.MeleeAttackWorldShakeOnMissAmplitude = 12

-- Knockback
ENT.HasMeleeAttackKnockBack         = true
ENT.MeleeAttackKnockBack_Forward1   = 200
ENT.MeleeAttackKnockBack_Forward2   = 250
ENT.MeleeAttackKnockBack_Up1        = 30
ENT.MeleeAttackKnockBack_Up2        = 50
ENT.MeleeAttackKnockBack_Right1     = -30
ENT.MeleeAttackKnockBack_Right2     = 30

-- Ranged — green weeper blasts that apply bleed
ENT.HasRangeAttack                      = true
ENT.AnimTbl_RangeAttack                 = {ACT_RANGE_ATTACK1}
ENT.RangeAttackEntityToSpawn            = "obj_vj_horde_calmaticus_spit"
ENT.RangeDistance                       = 2500
ENT.RangeToMeleeDistance                = 120
ENT.RangeUseAttachmentForPos            = false
ENT.TimeUntilRangeAttackProjectileRelease = 1.4
ENT.NextRangeAttackTime                 = 4
ENT.NextAnyAttackTime_Range             = 0.4

-- Leap (disabled on phase 1, activated on phases)
ENT.HasLeapAttack               = false
ENT.AnimTbl_LeapAttack          = {ACT_RANGE_ATTACK2}
ENT.LeapAttackAnimationDelay    = 0
ENT.NextLeapAttackTime          = 12
ENT.LeapAttackVelocityForward   = 550
ENT.LeapAttackVelocityUp        = 100
ENT.LeapAttackDamageDistance    = 160

-- Footsteps
ENT.FootStepTimeRun  = 0.28
ENT.FootStepTimeWalk = 0.28

-- Sounds (reuse gonome sounds)
ENT.SoundTbl_FootStep       = {"horde/gonome/gonome_step1.ogg","horde/gonome/gonome_step2.ogg","horde/gonome/gonome_step3.ogg","horde/gonome/gonome_step4.ogg"}
ENT.SoundTbl_Idle           = {"horde/gonome/gonome_idle1.ogg","horde/gonome/gonome_idle2.ogg"}
ENT.SoundTbl_MeleeAttack    = {"horde/gonome/gonome_melee1.ogg","horde/gonome/gonome_melee2.ogg"}
ENT.SoundTbl_MeleeAttackMiss = {"horde/gonome/gonome_melee1.ogg","horde/gonome/gonome_melee2.ogg"}
ENT.SoundTbl_LeapAttackJump = {"horde/gonome/gonome_jumpattack.ogg"}
ENT.SoundTbl_Pain           = {"horde/gonome/gonome_pain1.ogg","horde/gonome/gonome_pain2.ogg","horde/gonome/gonome_pain3.ogg","horde/gonome/gonome_pain4.ogg"}
ENT.SoundTbl_Death          = {"horde/gonome/gonome_death.ogg"}

-- Phase state flags
ENT.Calmaticus_Phase2   = false   -- 50% HP
ENT.Calmaticus_Phase3   = false   -- 25% HP

-- Internal cooldown trackers
ENT.NextAOEBlastTime    = 0
ENT.NextBarrageTime     = 0
ENT.NextRingTime        = 0
ENT.RangeAttackCooldown = 0

-- AOE blast interval for 25% phase
ENT.AOEBlastCooldown    = 15

function ENT:CustomOnInitialize()
    self:SetCollisionBounds(Vector(22, 22, 90), Vector(-22, -22, 0))
    self:SetSkin(1)
    -- Very dark green
    self:SetColor(Color(0, 80, 0, 255))
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:AddRelationship("npc_headcrab_poison D_LI 99")
    self:AddRelationship("npc_headcrab_fast D_LI 99")

    -- Slightly scaled up to look imposing
    self:SetModelScale(1.3, 0)
end

function ENT:Calmaticus_SpawnSpit(sideOffset)
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return end

    local spawnPos = self:GetPos() + self:GetUp() * 80 + self:GetForward() * 15
    local proj = ents.Create(self.RangeAttackEntityToSpawn)
    if not IsValid(proj) then return end
    proj:SetPos(spawnPos)
    proj:SetOwner(self)
    proj:SetPhysicsAttacker(self)
    proj:Spawn()
    proj:Activate()

    local phys = proj:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        -- Aim toward enemy chest with small random scatter
        local targetPos = enemy:GetPos() + Vector(math.random(-30,30), math.random(-30,30), 40)
        local dir = (targetPos - spawnPos):GetNormal()

        -- Apply side spread using the right vector of the aim direction
        if sideOffset ~= 0 then
            local rightVec = dir:Angle():Right()
            dir = (dir + rightVec * sideOffset):GetNormal()
        end

        -- Fixed launch speed + upward boost so gravity makes it arc nicely
        local speed  = 750
        local launch = dir * speed + Vector(0, 0, 180)
        phys:SetVelocity(launch)
        proj:SetAngles(launch:GetNormal():Angle())
    end
end

function ENT:RangeAttackCode_GetShootPos(TheProjectile)
    -- Used by the VJ base for the primary shot — aim toward enemy with a small arc
    local enemy = self:GetEnemy()
    if not IsValid(enemy) then return Vector(0, 0, 1) end
    local spawnPos = self:GetPos() + self:GetUp() * 80 + self:GetForward() * 15
    local targetPos = enemy:GetPos() + Vector(math.random(-30,30), math.random(-30,30), 40)
    local dir = (targetPos - spawnPos):GetNormal()
    return (dir * 750 + Vector(0, 0, 180))
end

function ENT:CustomRangeAttackCode_BeforeProjectileSpawn(projectile2)
    -- Side shots: 0.25 = slight right, -0.25 = slight left
    self:Calmaticus_SpawnSpit(0.28)
    self:Calmaticus_SpawnSpit(-0.28)
    self.RangeAttackCooldown = CurTime() + self.NextRangeAttackTime
    self.HasRangeAttack = false
end

function ENT:CustomOnMeleeAttack_HitEnemy(ent, dmginfo)
    if ent:IsPlayer() then
        ent:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 6, self)
    end
end

function ENT:BleedAttack(delay, dir)
    local id = self:GetCreationID()
    timer.Simple(delay - 0.6, function()
        if not IsValid(self) then return end
        local pos = self:GetPos() + dir
        local e = EffectData()
        e:SetOrigin(pos)
        e:SetScale(1)
        util.Effect("calmaticus_ring", e, true, true)
    end)
    timer.Simple(delay, function()
        if not IsValid(self) then return end
        local pos = self:GetPos() + dir

        local dmg = DamageInfo()
        dmg:SetAttacker(self)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_REMOVENORAGDOLL)
        dmg:SetDamage(70)
        util.BlastDamageInfo(dmg, pos, 200)

        for _, ent in pairs(ents.FindInSphere(pos, 200)) do
            if ent:IsPlayer() then
                ent:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 7, self)
            end
        end

        local e = EffectData()
        e:SetOrigin(pos)
        e:SetScale(1)
        util.Effect("calmaticus_blast", e, true, true)
        sound.Play("horde/gonome/gonome_jumpattack.ogg", pos, 85, math.random(55, 75))
    end)
end

function ENT:Calmaticus_RingAttack()
    if not IsValid(self) then return end
    local players = player.GetAll()
    for _, ply in pairs(players) do
        if IsValid(ply) and ply:Alive() then
            local pos = ply:GetPos()
            -- Warning ring immediately
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetScale(1.8)
            util.Effect("calmaticus_ring", e, true, true)
            sound.Play("weapons/cow_mangler_explode.wav", pos, 70, math.random(40, 55))
            -- Detonate with bleed after 2 seconds
            local capturedSelf = self
            local capturedPos  = pos
            timer.Simple(2, function()
                if not IsValid(capturedSelf) then return end
                -- Second flash before damage
                local e2 = EffectData()
                e2:SetOrigin(capturedPos)
                e2:SetScale(1)
                util.Effect("calmaticus_blast", e2, true, true)

                local dmg = DamageInfo()
                dmg:SetAttacker(capturedSelf)
                dmg:SetInflictor(capturedSelf)
                dmg:SetDamageType(DMG_REMOVENORAGDOLL)
                dmg:SetDamage(60)
                util.BlastDamageInfo(dmg, capturedPos, 160)

                for _, ent in pairs(ents.FindInSphere(capturedPos, 160)) do
                    if ent:IsPlayer() then
                        ent:Horde_AddDebuffBuildup(HORDE.Status_Bleeding, 6, capturedSelf)
                    end
                end
            end)
        end
    end
end

-- Phase 3 (25%): rapid barrage toward all players
function ENT:Calmaticus_Barrage()
    if not IsValid(self) then return end

    -- Klaxon warning before shots fly
    sound.Play("mvm/mvm_cpoint_klaxon.wav", self:GetPos(), 120, 100)
    -- Short delay so players can react to the warning
    timer.Simple(0.8, function()
        if not IsValid(self) then return end

        local shotCount = 36   -- more shots than before

        for i = 1, shotCount do
            timer.Simple(i * 0.1, function()
                if not IsValid(self) then return end

                local validTargets = {}
                for _, ply in pairs(player.GetAll()) do
                    if IsValid(ply) and ply:Alive() then
                        validTargets[#validTargets + 1] = ply
                    end
                end
                if #validTargets == 0 then return end
                local target = validTargets[math.random(#validTargets)]

                local proj = ents.Create("obj_vj_horde_calmaticus_barrage")
                if not IsValid(proj) then return end
                local spawnPos = self:GetPos() + self:GetUp() * 80 + self:GetForward() * 15
                proj:SetPos(spawnPos)
                proj:SetOwner(self)
                proj:SetPhysicsAttacker(self)
                proj:Spawn()
                proj:Activate()

                local phys = proj:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    -- Wide scatter cone — random spread ±120 XY, ±50 Z so shots fan out
                    local scatter = Vector(math.random(-120, 120), math.random(-120, 120), math.random(-20, 50))
                    local targetPos = target:GetPos() + scatter
                    local dir = (targetPos - spawnPos):GetNormal()
                    -- Slower launch + gentle upward boost for arc
                    local speed = 550
                    local launch = dir * speed + Vector(0, 0, 120)
                    phys:SetVelocity(launch)
                    proj:SetAngles(launch:GetNormal():Angle())
                end
            end)
        end
    end)
end

function ENT:Calmaticus_AOEBlast()
    if not IsValid(self) then return end
    sound.Play("npc/strider/striderx_die1.wav", self:GetPos(), 110, 30)
    self:VJ_ACT_PLAYACTIVITY("big_flinch", true, 5, false)

    local fwd   = self:GetForward()
    local rgt   = self:GetRight()

    -- Diagonal unit vectors
    local diag1 = (fwd + rgt);   diag1:Normalize()
    local diag2 = (fwd - rgt);   diag2:Normalize()

    local dirs8 = {fwd, -fwd, rgt, -rgt, diag1, -diag1, diag2, -diag2}

    for i = 1, 20 do
        for _, d in pairs(dirs8) do
            -- Burst 1
            self:BleedAttack(2, d * i * 100)
            -- Burst 2
            self:BleedAttack(4, d * i * 100)
        end
    end
end

function ENT:CustomOnThink()
    -- Range attack cooldown management
    if self.RangeAttackCooldown < CurTime() then
        self.HasRangeAttack = true
    end

    -- Slightly speed-boosted movement like alpha gonome
    if self:IsOnGround() then
        local mult = 1.0
        if self.Calmaticus_Phase3 then mult = 1.6
        elseif self.Calmaticus_Phase2 then mult = 1.4
        end
        if mult > 1.0 then
            self:SetLocalVelocity(self:GetMoveVelocity() * mult)
        end
    end

    -- === PHASE 2: green rings under players every 6 seconds ===
    if self.Calmaticus_Phase2 and CurTime() > self.NextRingTime then
        self.NextRingTime = CurTime() + 6
        self:Calmaticus_RingAttack()
    end

    -- === PHASE 3: barrage every 10 seconds ===
    if self.Calmaticus_Phase3 then
        if CurTime() > self.NextBarrageTime then
            self.NextBarrageTime = CurTime() + 10
            self:Calmaticus_Barrage()
        end

        -- 8-direction 2-burst AOE every 15 seconds
        local enemy = self:GetEnemy()
        if IsValid(enemy) then
            local dist = self.EnemyData and self.EnemyData.Distance or 9999
            if dist < 1200 and CurTime() > self.NextAOEBlastTime then
                self.NextAOEBlastTime = CurTime() + self.AOEBlastCooldown
                self:Calmaticus_AOEBlast()
            end
        end
    end
end

-- Damage resistance flavoring
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)
    if dmginfo:GetAttacker() == self then dmginfo:SetDamage(0) return true end
    -- Resistant to poison (fitting for a bleed boss)
    if HORDE:IsPoisonDamage(dmginfo) then
        dmginfo:ScaleDamage(0.4)
    elseif HORDE:IsFireDamage(dmginfo) then
        dmginfo:ScaleDamage(1.3)
    end
end

-- Phase transitions on damage
function ENT:CustomOnTakeDamage_AfterDamage(dmginfo, hitgroup)
    local hp    = self:Health()
    local maxhp = self:GetMaxHealth()

    -- ---- Phase 2 transition (50%) ----
    if not self.Calmaticus_Phase2 and hp < maxhp * 0.5 then
        self.Calmaticus_Phase2 = true

        -- Visual change: slightly brighter green, pulsing effect
        self:SetColor(Color(0, 130, 0, 255))
        self:SetPlaybackRate(1.2)

        -- Announce with roar + blast at own position
        sound.Play("horde/gonome/gonome_pain4.ogg", self:GetPos(), 120, 60)
        local e = EffectData()
        e:SetOrigin(self:GetPos())
        e:SetScale(2)
        util.Effect("calmaticus_blast", e, true, true)

        -- Enable leaping
        self.HasLeapAttack = true

        -- Immediately do first ring attack with a short delay
        timer.Simple(1.5, function()
            if not IsValid(self) then return end
            self:Calmaticus_RingAttack()
            self.NextRingTime = CurTime() + 6
        end)
    end

    -- ---- Phase 3 transition (25%) ----
    if not self.Calmaticus_Phase3 and hp < maxhp * 0.25 then
        self.Calmaticus_Phase3 = true

        -- Visual: enraged dark + slightly transparent
        self:SetColor(Color(0, 200, 0, 210))
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetPlaybackRate(1.5)

        -- Faster attack rate
        self.NextRangeAttackTime = 2.5
        self.MeleeAttackDamage   = 280    -- Even heavier hits in final phase

        sound.Play("horde/gonome/gonome_jumpattack.ogg", self:GetPos(), 130, 45)
        local e = EffectData()
        e:SetOrigin(self:GetPos())
        e:SetScale(2.5)
        util.Effect("calmaticus_blast", e, true, true)

        -- Start barrage and AOE immediately
        self.NextBarrageTime  = CurTime() + 1
        self.NextAOEBlastTime = CurTime() + 3
    end
end

VJ.AddNPC("Calmaticus", "npc_vj_horde_calmaticus", "Zombies")
