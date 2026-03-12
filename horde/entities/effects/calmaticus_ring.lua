
function EFFECT:Init(effect_data)
	self.effect_data = effect_data
	local pos = effect_data:GetOrigin()
	local scale = effect_data:GetScale() or 1
	local normal = Vector(0, 0, 1)
	self.emitter = ParticleEmitter(pos, true)
	local ringstart = pos + Vector(0, 0, 5)
	local particle

	-- Pulsing warning rings expanding outward
	for i=1, 5 do
		particle = self.emitter:Add("effects/select_ring", ringstart)
		particle:SetDieTime(0.4 + i * 0.35)
		particle:SetColor(0, 200, 40)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(240 * scale)
		particle:SetAngles(normal:Angle())

		particle = self.emitter:Add("effects/select_ring", ringstart)
		particle:SetDieTime(0.6 + i * 0.3)
		particle:SetColor(0, 100, 10)
		particle:SetStartAlpha(180)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10 * scale)
		particle:SetEndSize(260 * scale)
		particle:SetAngles(normal:Angle())
	end

	-- Rising green embers
	for i=1, 30 do
		local offset = VectorRand()
		offset.z = 0
		offset:Normalize()
		offset = offset * math.random(20, 80)

		particle = self.emitter:Add("effects/blueflare1", pos + offset + Vector(0, 0, 5))
		particle:SetVelocity(Vector(0, 0, math.random(60, 150)))
		particle:SetDieTime(math.Rand(1.2, 2.0))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 5))
		particle:SetEndSize(0)
		particle:SetColor(0, 220, 50)
		particle:SetAirResistance(50)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
