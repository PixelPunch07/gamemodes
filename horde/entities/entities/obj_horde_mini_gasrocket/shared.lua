ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Gas Rocket Turret Minirocket"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= false


AddCSLuaFile()

ENT.Model = "models/items/ar2_grenade.mdl"
ENT.Ticks = 0
ENT.FuseTime = 10
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.CollisionGroupType = COLLISION_GROUP_PROJECTILE
ENT.Removing = nil

if SERVER then

function ENT:Initialize()
    local pb_vert = 0.5
    local pb_hor = 0.5
    self:SetModel(self.Model)
    self:PhysicsInitBox( Vector(-pb_vert,-pb_hor,-pb_hor), Vector(pb_vert,pb_hor,pb_hor) )
self.exploded = false
self.trueexplode = false
	self.timer = CurTime() + 6
	self.solidify = CurTime() + 1
	self.Bastardgas = nil
	self.Spammed = false
	
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableGravity(false)
    end

    self.SpawnTime = CurTime()

    timer.Simple(0.1, function()
        if !IsValid(self) then return end
        self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    end)

    timer.Simple(5, function ()
        if IsValid(self) then self:Remove() end
    end)
    ParticleEffectAttach("vj_rocket_idle1", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:Think()
    if SERVER then
     
		if self.exploded == true then
		
			self:MakePoison()
	self.Entity:NextThink( CurTime() )
	
		end
		end 
end
end
function ENT:Detonate()
self.exploded = true
if self.trueexplode == false then
self.trueexplode = true
	local gas = EffectData()
	pos = self:GetPos()
		gas:SetOrigin(pos)
		gas:SetEntity(self) //i dunno, just use it!
		gas:SetScale(1)//otherwise you'll get the pinch thing. just leave it as it is for smoke, i'm trying to save on lua files dammit!
	util.Effect("m9k_released_nerve_gas", gas)
	self:SetMoveType(MOVETYPE_NONE)
end
end

function ENT:PhysicsCollide(colData, collider)
    self:Detonate()
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:MakePoison()

	local pos = self.PosToKeep
	if pos == nil then pos = self.Entity:GetPos()end
	local damage = 70
	local radius = 225
	
	if self.Big then
		radius = 600
		damage = 70
	else
		radius = 225
		damage = 15
	end

	local poisonowner
	if IsValid(self) then 
		if IsValid(self.Owner) then 
			poisonowner = self.Owner
		elseif IsValid(self.Entity) then
			poisonowner = self.Entity
		end 
	end
	if not IsValid(poisonowner) then return end
	
	util.BlastDamage(self, poisonowner, pos, radius, damage)
	-- an explosion for making poison. Sure, must be one hell of a nerve agent to light wood on fire
	-- and to shatter windows. Guess i'll just have to deal with it.

end
	
