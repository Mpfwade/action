function ActionExtension:LerpBoneManipulation( ent, fraction, startData, endData )

	if !IsValid( ent ) then return end
	
	for k, v in pairs( startData ) do
		
		local boneID = ent:LookupBone( k );
		
		if boneID > -1 then

			if v.pos then

				if endData and endData[k] and endData[k].pos then
				
					ent:ManipulateBonePosition( boneID, LerpVector( fraction, v.pos, endData[k].pos ) );
					
				else
				
					ent:ManipulateBonePosition( boneID, LerpVector( fraction, v.pos, Vector( 0, 0, 0 ) ) );
					
				end
					
			end
			
			if v.angle then

				if endData and endData[k] and endData[k].angle then
				
					ent:ManipulateBoneAngles( boneID, LerpAngle( fraction, v.angle, endData[k].angle ) );
					
				else
				
					ent:ManipulateBoneAngles( boneID, LerpAngle( fraction, v.angle, Angle( 0, 0, 0 ) ) );
					
				end
				
			end
			
		end
	end

end

function ActionExtension:GetBoneManipulationByMap( ent, map )

	if !IsValid( ent ) then return end

	local boneData = {}

	for k, v in pairs( map ) do

		local boneID = ent:LookupBone( k );

		if boneID > -1 then

			boneData[k] = {};

			if v.angle then

				boneData[k].angle = ent:GetManipulateBoneAngles( boneID );

			end

			if v.pos then

				boneData[k].pos = ent:GetManipulateBonePosition( boneID );

			end

		end
	end

	return boneData;

end

-- reset manipulation only mapped bones
function ActionExtension:ResetBoneManipulationByMap( ent, map )

	if !IsValid( ent ) then return end

	for k, v in pairs( map ) do

		local boneID = ent:LookupBone( k );

		if boneID > -1 then

			if v.angle then

				ent:ManipulateBoneAngles( boneID, Angle() );

			end

			if v.pos then

				ent:ManipulateBonePosition( boneID, Vector() );

			end

		end
	end

end

function ActionExtension:GetDirectionTrace( entity, direction )

	local origin = entity:LocalToWorld( entity:OBBCenter() );
	local mins = entity:OBBMins();
	local maxs = entity:OBBMaxs();

	maxs.z = 1;

	local angles = entity:GetAngles();
	local _direction;
	local offset = 30;
	
	if direction == self.TRACE_LEFT then

		_direction = -angles:Right()
		mins = Vector( 0, 0, 0 )
		maxs = Vector( 2, 2, 2 )

	elseif direction == self.TRACE_RIGHT then

		_direction = angles:Right()
		mins = Vector( 0, 0, 0 )
		maxs = Vector( 2, 2, 2 )

	elseif direction == self.TRACE_FORWARD then

		_direction = angles:Forward()
		mins = Vector( 0, 0, 0 )
		maxs = Vector( 2, 2, 2 )

	elseif direction == self.TRACE_BACK then

		_direction = -angles:Forward()

	elseif direction == self.TRACE_UP then

		_direction = angles:Up()
		offset = 50

	elseif direction == self.TRACE_BOTTOM then

		_direction = -angles:Up()

	end

	return util.TraceHull( {

		start = origin,
		endpos =  origin + ( _direction * offset ),
		maxs = maxs,
		mins = mins,
		filter = entity

	} )

end

function ActionExtension:IsHitDirection( entity, direction )

	local trace = self:GetDirectionTrace( entity, direction );

	return trace.Hit;

end

if CLIENT then

	function ActionExtension:GetBulletSourcePosition( entity )

		return glue:GetData( entity, "ActionExtension:BulletSourcePosition", Vector() );
	
	end

	function ActionExtension:UpdateBulletSourcePosition()

		for className, entity in pairs( ents.GetAll() ) do
	
			if entity:IsPlayer() or entity:IsNPC() then
	
				local weapon = entity:GetActiveWeapon();
	
				if IsValid( weapon ) then
	
					local attachmentID = 1;
	
					if weapon.IsTFAWeapon then
	
						attachmentID = weapon:GetMuzzleAttachment();
	
					end
	
					if entity:IsPlayer() && !entity:ShouldDrawLocalPlayer() then
	
						local pos = entity:EyePos();
						local angles = entity:EyeAngles();
	
						pos = pos + angles:Right() * 3;
						pos = pos + angles:Forward() * 15;
	
						glue:SetData( entity, "ActionExtension:BulletSourcePosition", pos );
	
					else
	
						local data = weapon:GetAttachment( attachmentID );
	
						if data then
	
							glue:SetData( entity, "ActionExtension:BulletSourcePosition", data.Pos );
	
						end
	
					end
				
				end
	
			end
	
		end
	
	end
	
end