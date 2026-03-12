
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin()
	local normal = Vector(0,0,1)
	local scale = effectdata:GetScale() or 1

	local particle

	local emitter = ParticleEmitter(pos)
	local emitter2 = ParticleEmitter(pos, true)
	emitter:SetNearClip(24, 32)
	emitter2:SetNearClip(24, 32)

	-- Expanding green rings
	local ringstart = pos + normal * 10
	for i=1, 4 do
		particle = emitter2:Add("effects/select_ring", ringstart)
		particle:SetDieTime(0.1 + i * 0.1)
		particle:SetColor(0, 200, 40)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(280 * scale)
		particle:SetAngles(normal:Angle())

		particle = emitter2:Add("effects/select_ring", ringstart)
		particle:SetDieTime(0.2 + i * 0.1)
		particle:SetColor(0, 160, 20)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(280 * scale)
		particle:SetAngles(normal:Angle())
	end

	-- Green sparks burst
	for i=1, math.random(130, 170) do
		local heading = VectorRand()
		heading:Normalize()

		particle = emitter:Add("effects/blueflare1", pos + heading * 8)
		particle:SetVelocity(900 * heading)
		particle:SetDieTime(math.Rand(0.5, 0.9))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(3, 5))
		particle:SetEndSize(0)
		particle:SetAirResistance(250)
		particle:SetColor(0, 220, 50)
	end

	-- Dark green smoke billow
	for i=1, 3 do
		local smoke = emitter:Add("particles/smokey", pos)
		smoke:SetGravity(Vector(0, 0, 800))
		smoke:SetDieTime(math.Rand(0.6, 1.1))
		smoke:SetStartAlpha(220)
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(15)
		smoke:SetEndSize(320 * scale)
		smoke:SetRoll(math.Rand(-180, 180))
		smoke:SetRollDelta(math.Rand(-0.2, 0.2))
		smoke:SetColor(0, 140, 20)
		smoke:SetAirResistance(800)
		smoke:SetLighting(false)
		smoke:SetCollide(true)
		smoke:SetBounce(0)
	end

	emitter:Finish()
	emitter2:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
