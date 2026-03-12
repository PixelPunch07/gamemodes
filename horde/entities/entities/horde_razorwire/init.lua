AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/props_street/concertinawire64.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_BSP )         -- Toolbox
	self:SetHealth(250)
	self.planted = false
	self.localpos = nil
	self:SetTrigger(true)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(50)
	end
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 32
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	local ent = ents.Create("horde_razorwire")
		ent:SetPos(SpawnPos)
		ent:SetAngles(SpawnAng)
	ent:Spawn()
ent:SetOwner(ply)
	ent:Activate()
	--ent:SetName("Barricade")
	return ent
end

function ENT:Use( activator, caller )
if timer.TimeLeft( "usecd"..self:EntIndex() ) == nil then


if self.planted == false then

self.planted = true
    self:SetMoveType(MOVETYPE_NONE)
activator:PrintMessage(HUD_PRINTCENTER, "Planted.")
self.localpos = self:GetPos()
else
self.planted = false
    self:SetMoveType(MOVETYPE_VPHYSICS)
activator:PrintMessage(HUD_PRINTCENTER, "Unplanted.")
self:SetPos(self.localpos)
self.localpos = nil
end
timer.Create( "usecd"..self:EntIndex(), 2, 1, function() end )	
end

end

function ENT:OnTakeDamage( damage )
	self:SetHealth(self:Health() - damage:GetDamage())
	if self:Health() <= 0 then
		self:EmitSound( "physics/metal/metal_box_break".. math.random( 1, 2 ) .. ".wav" )
				local eff = EffectData()
				eff:SetOrigin( self:GetPos() )
				eff:SetNormal( self:GetPos() )
				eff:SetMagnitude( 5 )
				eff:SetRadius( 7 )
				eff:SetScale( 5 )
				util.Effect( "Sparks", eff )
		self:Remove()
	end
end

function ENT:Touch( entity )
	if entity:IsNPC() or entity.Type == "nextbot" then
		if timer.TimeLeft( "barb_damage"..self:EntIndex() ) == nil then
			entity:EmitSound( "physics/metal/metal_chainlink_impact_hard".. math.random( 1, 3 ) .. ".wav" )
			local dmgInfo = DamageInfo()
			dmgInfo:SetAttacker(self)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamageType(DMG_SLASH)
			dmgInfo:SetDamage(math.random(15,25))
			self:TakeDamage(5)
			print("type shit")
			dmgInfo:SetDamagePosition(self:GetPos())
			entity:TakeDamageInfo(dmgInfo)
			
			timer.Create( "barb_damage"..self:EntIndex(), 0.15, 1, function() end )	
		end
	end
end

function ENT:Think()
			if SERVER then 
  local entities = ents.FindInSphere(self:GetPos(), 9.5)

            for _, ent in ipairs(entities) do
                if ent:IsValid() and ( ent:IsNPC() or ent:IsNextBot() or ent:GetClass() == "prop_physics" or ent:IsVehicle() ) then

                    if IsValid( ent:GetPhysicsObject() ) then
                        if ( ent:GetClass() == "prop_physics" ) then
                            constraint.RemoveAll(ent)
                            ent:GetPhysicsObject():EnableMotion(true)
                        end
                    end
                    
                   
 

                    if IsValid(phys) then phys:SetVelocity(dir * force) end
					

			
                    if SERVER then
				
			local dmgInfo = DamageInfo()
			dmgInfo:SetAttacker(self)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamageType(DMG_SLASH)
			dmgInfo:SetDamage(math.random(4.5,8.5))
			self:TakeDamage(5)
		
			self:EmitSound( "physics/metal/metal_chainlink_impact_hard".. math.random( 1, 3 ) .. ".wav" )
			dmgInfo:SetDamagePosition(self:GetPos())
			ent:TakeDamageInfo(dmgInfo)
				if timer.TimeLeft( "npcslow"..ent:EntIndex() ) == nil then
				local original = ent:GetMoveDelay()
				ent:SetMoveDelay( 4.1 )
			
timer.Simple( 0.25, function() if ent:IsValid() then ent:SetMoveDelay( original ) end end )
				timer.Create( "npcslow"..ent:EntIndex(), 0.85, 1, function() end )	
				
				
				end
					else
            

			  
			 
                    end
                 end



                    end
							timer.Create( "flowercd1"..self:EntIndex(), 3, 1, function() end )	
                end
end
function ENT:PhysicsCollide(data, phys)

	if data.DeltaTime > 0.2 then
		self:EmitSound("physics/metal/metal_chainlink_impact_hard" .. math.random(1, 3) .. ".wav")

	end
	

	
	if data.Speed > 1500 and not self:IsPlayerHolding() then
		local phys = data.HitEntity:GetPhysicsObject()
		if (IsValid(phys)) then
			self:TakeDamage((data.Speed/100)*phys:GetMass())
			if data.HitEntity:GetClass():find("vehicle") or data.HitEntity:GetClass():find("simf") then
				
	
				timer.Simple(0.01, function() if IsValid(phys) then phys:SetVelocity(data.TheirOldVelocity) end end)
			end
		end
	elseif (data.HitEntity:GetVelocity():IsEqualTol(Vector(0,0,0),500) == false and not data.HitEntity:IsRagdoll()) then
		local phys = data.HitEntity:GetPhysicsObject()
		if (IsValid(phys)) then
			self:TakeDamage(phys:GetMass())
			if data.HitEntity:GetClass():find("vehicle") or data.HitEntity:GetClass():find("simf") then
				
			
				timer.Simple(0.01, function() if IsValid(phys) then phys:SetVelocity(data.TheirOldVelocity) end end)
			end
		end
	elseif (data.HitObject:GetAngleVelocity():IsEqualTol(Vector(0,0,0),250) == false and not data.HitEntity:IsRagdoll()) then
		local phys = data.HitEntity:GetPhysicsObject()
		if (IsValid(phys)) then
			self:TakeDamage(phys:GetMass())
			if data.HitEntity:GetClass():find("vehicle") or data.HitEntity:GetClass():find("simf") then
			
				timer.Simple(0.01, function() if IsValid(phys) then phys:AddAngleVelocity(data.TheirOldAngularVelocity) end end)
			end
		end
	end
end