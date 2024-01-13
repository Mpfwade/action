hook.Add( "CalcMainActivity", "ActionExtension:CalcMainActivity", function( player, velocity )

    local component = glue:GetComponent( player, "AnimationEvents" );

    if component then

        return component:CalcMainActivity( player, velocity );

    end

end )

hook.Add( "UpdateAnimation", "ActionExtension:UpdateAnimation", function( player, velocity, maxSeqGroundSpeed )

    local component = glue:GetComponent( player, "AnimationEvents" );

    if component then

        return component:UpdateAnimation( player, velocity, maxSeqGroundSpeed );

    end

end )

hook.Add( "Think", "ActionExtension:Think", function()

	if CLIENT then

		if GetConVar( "sv_action_ext_slowmo_bullet" ):GetBool() && ActionExtension.SlowMotion.Active then

			ActionExtension:UpdateBulletSourcePosition();

		end

	end

	if SERVER then

		ActionExtension.SlowMotion:Update();

	end

	ActionExtension.Bullets:Update();
    
end )

if SERVER then

	hook.Add( "SetupMove", "ActionExtension:SetupMove", function( player, moveData )

        local component = glue:GetComponent( player, "AnimationEvents" );

        if component then
            
            if player:Alive() then

                component:SetupMove( player, moveData );

            else

                if component:GetEventID() > -1 then

                    component:StopEvent();
    
                end

            end

        end

	end )

    hook.Add( "Glue:OnCommandPressed", "ActionExtensio:Glue:OnCommandPressed", function( player, command )

        if command == ActionExtension.IN_SLOW_MOTION then

            ActionExtension.SlowMotion:Toggle( player );

        end
        
    end )

    hook.Add( "EntityFireBullets", "ActionExtension:EntityFireBullets", function( entity, data )

        if GetConVar( "sv_action_ext_slowmo_bullet" ):GetBool() && ActionExtension.SlowMotion:IsActive() && !ActionExtension.Bullets.PreventFireBullets then
    
            ActionExtension.Bullets:Fire( entity, data );
            return false;
    
        end
    
    end )

	hook.Add( "EntityEmitSound", "ActionExtension:EntityEmitSound", function( data )

		if GetConVar( "sv_action_ext_slowmo_sound" ):GetBool() then

            local timeScale = game.GetTimeScale();
            
            if GetConVar( "sv_cheats" ):GetBool() then

                timeScale = timeScale * GetConVar( "host_timescale" ):GetFloat();

            end
            
            if engine.GetDemoPlaybackTimeScale then

                timeScale = timeScale * engine.GetDemoPlaybackTimeScale();

            end

            if timeScale ~= 1 then

                data.Pitch = math.Clamp( data.Pitch * timeScale, 0, 255 );
                return true;

            end

            return true;

        end
	
	end )

    hook.Add( "OnPlayerHitGround", "ActionExtension:OnPlayerHitGround", function( player, inWater, onFloater, speed )

        local component = glue:GetComponent( player, "AnimationEvents" );

        if component then

            if component:HasEvent( ActionExtension.EVENT_DIVE ) then
                
                if ViewExtension then 

                    glue:GetComponent( player, "View" ):ShouldAim( 0.7, true );

                end
                
                component:StartEvent( ActionExtension.EVENT_ROLL, ActionExtension.ACTIVITY_ROLL, component:GetEventDirection() );
        
				if GetConVar( "cl_action_ext_dive_slowmo" ):GetBool() && ActionExtension.SlowMotion:IsOwner( player ) && ActionExtension.SlowMotion:IsActive() && !glue.Animations:IsPlaying( "ActionExtension:SlowMotionFadeOut" ) then

					ActionExtension.SlowMotion:Toggle( player );
		
				end

            end

        end

	end )

	hook.Add( "EntityTakeDamage", "ActionExtension:EntityTakeDamage", function( entity, damage )

        if entity:IsNPC() then
            
            local attacker = damage:GetAttacker();

            if attacker:IsPlayer() then

                if ActionExtension.SlowMotion:IsActive() && ActionExtension.Camera:CanStart( entity, attacker ) then

                    if entity:Health() <= ( damage:GetDamage() + damage:GetDamageBonus() ) && !glue:GetData( entity, "ActionExtension:IsCameraTarget", false ) then

                        ActionExtension.Camera:Start( attacker, ActionExtension.CAMERA_BEHIND, entity );

                    end

                end
            
            end

        end

	end )

end

if CLIENT then

	hook.Add( "CreateMove", "ActionExtension:CreateMove", function( cmd )

        local player = LocalPlayer();
        local component = glue:GetComponent( player, "AnimationEvents" );

        if component && player:Alive() then
		
            component:CreateMove( cmd );

        end
		
    end )

    hook.Add( "ShouldDrawLocalPlayer", "ActionExtension:ShouldDrawLocalPlayer", function( player )

		if ActionExtension.Camera.Active then

			return ActionExtension.Camera.ShouldDrawLocalPlayer;

		end

	end )

	hook.Add( "PostDrawTranslucentRenderables" , "ActionExtension:PostDrawTranslucentRenderables" , function()

		ActionExtension.Bullets:Draw();

	end )

	hook.Add( "RenderScreenspaceEffects", "ActionExtension:RenderScreenspaceEffects", function()

		if ActionExtension.Camera.Active then

			ActionExtension.Camera.WindowX = 0;
			ActionExtension.Camera.WindowY = 0;
			ActionExtension.Camera:Draw();

		end

		ActionExtension.SlowMotion:Draw();

	end )

	hook.Add( "ActionExtension:StartSlowMotion" , "ActionExtension:SlowMotionSoundEffects" , function()

		if GetConVar( "cl_action_ext_slowmo_fx_sound" ):GetBool() then

			surface.PlaySound( "action_extension/slow_motion_start.wav" );

		end

		ActionExtension.SlowMotion.Flash = 5;

	end )
	
end