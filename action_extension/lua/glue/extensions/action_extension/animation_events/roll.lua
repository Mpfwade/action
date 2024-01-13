local Event = {};

Event.PreventDefaultMovement = true;
Event.ActivityPlaybackRate = 1.5;
Event.Hull = { Vector( -16, -16, 0 ), Vector( 16, 16, 32 ) };
Event.Velocity = 450;
Event.Deceleration = 2;

-- return calculated "move_x" and "move_y" pose parameters
function Event:CalcPose( player, component, velocityAngle, aimAngle )

    return velocityAngle:Forward():Dot( aimAngle:Forward() ) * 2, -velocityAngle:Forward():Dot( aimAngle:Right() );

end

if SERVER then

    function Event:CanUseEvent( player )

        return GetConVar( "sv_action_ext_roll" ):GetBool() 
            && player:GetMoveType() != MOVETYPE_NOCLIP 
            && player:WaterLevel() < 2 && player:IsOnGround() 
            && !player:InVehicle();

    end

    function Event:Start( player, component, moveData )

        player:SetViewOffset( Vector( 0, 0, 24 ) );
        player:EmitSound( "action_extension/land" .. math.Round( math.random( 1, 3 ) ) ..".wav" );

        timer.Simple( 0.6, function()

            component:StopEvent();

        end );

        if GetConVar( "cl_action_ext_roll_slowmo" ):GetBool() and !ActionExtension.SlowMotion:IsActive() then

            ActionExtension.SlowMotion:Toggle( player );

        end
                
    end

    function Event:SetupMove( player, component, moveData )

        if player:IsOnGround() then

            local ang = component:GetEventDirection():Angle();
            ang.p = 0;

            vel = ang:Forward() * component:GetVelocity();
            
            moveData:SetVelocity( vel );

        end
                
    end

    function Event:Stop( player, component )

        if ActionExtension:IsHitDirection( player, ActionExtension.TRACE_UP ) then

            player:ConCommand( "+duck" );

            timer.Simple( 0.1, function() 

                player:SetViewOffset( Vector( 0, 0, 64 ) );
                player:ConCommand( "-duck" );

            end )

        else

            player:SetViewOffset( Vector( 0, 0, 64 ) );

        end

    end

end

glue:GetSystem( "AnimationEvents" ):DefineAnimationEvent( ActionExtension.EVENT_ROLL, Event );