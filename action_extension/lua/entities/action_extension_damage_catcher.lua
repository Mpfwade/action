AddCSLuaFile();

DEFINE_BASECLASS( "base_entity" );

ENT.Author	= "Satan";
ENT.AdminOnly = false;
ENT.Spawnable = false;

function ENT:Initialize()

    self:SetModel( "models/maxofs2d/companion_doll.mdl" );
    self:SetMoveType( MOVETYPE_VPHYSICS );
    self:SetSolid( SOLID_VPHYSICS );

    self.CurrentDamage = 0;

end

if SERVER then

    function ENT:OnTakeDamage( damage )
        
        self.CurrentDamage = damage:GetDamage() + damage:GetDamageBonus();

    end

end