include('shared.lua')

killicon.Add("barricade_concertinawire_64", "effects/killicons/ent_razorwire", color_white )

function ENT:Draw()
    self:DrawModel() -- Draws Model Client Side
end