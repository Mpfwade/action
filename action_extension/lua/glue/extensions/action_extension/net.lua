if SERVER then

	util.AddNetworkString( "ActionExtension:SetupCameraEvent" );
	util.AddNetworkString( "ActionExtension:SetupPlayerEvent" );
	util.AddNetworkString( "ActionExtension:SetupPlayerEventParameters" );
	util.AddNetworkString( "ActionExtension:SetupSlowMotion" );
	util.AddNetworkString( "ActionExtension:FireBullet" );
	util.AddNetworkString( "ActionExtension:RemoveBullet" );
    
end

if CLIENT then

	net.Receive( "ActionExtension:SetupPlayerEvent", function()

		local player = net.ReadEntity();
		local id = net.ReadInt( 6 );
		local act = net.ReadInt( 6 );
		local direction = net.ReadVector();

		local component = glue:GetComponent( player, "AnimationEvents" );
		
		if IsValid( player ) && component then

			component.EventID = id;
			component.Activity = act;
			component.EventDirection = direction;

			player:AnimRestartMainSequence();
			
		end
		
	end )

	net.Receive( "ActionExtension:SetupPlayerEventParameters", function()

		local player = net.ReadEntity();
		local act = net.ReadInt( 6 );
		local direction = net.ReadVector();
		local restart = net.ReadBool();

		local component = glue:GetComponent( player, "AnimationEvents" );
		
		if IsValid( player ) && component then

			component.Activity = act;
			component.EventDirection = direction;

			if restart then

				player:AnimRestartMainSequence();

			end
			
		end
		
	end )

    net.Receive( "ActionExtension:SetupCameraEvent", function()

		local type = net.ReadInt( 16 );
		local target = net.ReadEntity();
		local uuid = net.ReadString();

		ActionExtension.Camera:Start( LocalPlayer(), type, target, uuid );
		ActionExtension.SlowMotion.Flash = 9.0;

	end )
	
	net.Receive( "ActionExtension:FireBullet", function()

		local uuid = net.ReadString();
		local entity = net.ReadEntity();
		local ammoType = net.ReadInt( 16 );
		local endPos = net.ReadVector();
		local target = net.ReadEntity();

		if IsValid( entity ) then

			ActionExtension.Bullets:Fire( entity, {

				uuid = uuid,
				AmmoType = ammoType,
				PositionEnd = endPos,
				Target = target

			})

		end

	end )

	net.Receive( "ActionExtension:RemoveBullet", function()

		local uuid = net.ReadString();
		ActionExtension.Bullets:Remove( uuid );

	end )

	net.Receive( "ActionExtension:SetupSlowMotion", function()

		local state = net.ReadBool();
		local charge = net.ReadInt( 16 );

		ActionExtension.SlowMotion:Setup( state, charge );

	end )
	
end