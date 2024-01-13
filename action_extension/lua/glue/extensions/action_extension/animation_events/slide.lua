local Event = {};

Event.BoneManipulationCompletionDuration = 0.3;
Event.PreventDefaultMovement = true;
Event.ActivityPlaybackRate = 3.5;
Event.Hull = { Vector( -16, -16, 0 ), Vector( 16, 16, 2 ) };
Event.Velocity = 950;
Event.Deceleration = 2;

-- return updated bone manipulation data
function Event:CalcBoneManipulation( player, component )

    return {
        ["ValveBiped.Bip01_L_Calf"] = { angle = Angle( 0, 0, 0 ) },
        ["ValveBiped.Bip01_R_Calf"] = { angle = Angle( 0, 90, 0 ) },
        ["ValveBiped.Bip01_L_Thigh"] = { angle = Angle( -25, 0, 0 ) },
        ["ValveBiped.Bip01_R_Thigh"] = { angle = Angle( 25, -45, 25 ) }
    }

end

-- return view angles
function Event:CalcViewAngles( player, component, viewAngles )

    local velocityAngles = component:GetEventDirection():Angle();
    return Angle( viewAngles.p, glue.ClampAngle180( viewAngles.y, velocityAngles.y - 30, velocityAngles.y + 30 ), viewAngles.r );

end

-- return calculated "move_x" and "move_y" pose parameters
function Event:CalcPose( player, component, velocityAngle, aimAngle )

    local my = velocityAngle:Forward():Dot( aimAngle:Right() );
    return -1, math.Clamp( my, -0.5, 0.4 );

end

if SERVER then

    function Event:CanUseEvent( player )

        return GetConVar( "sv_action_ext_slide" ):GetBool() 
            && player:GetMoveType() != MOVETYPE_NOCLIP 
            && player:WaterLevel() < 2 
            && player:IsOnGround() 
            && !player:InVehicle() 
            && !player:KeyDown( IN_DUCK );

    end

    function Event:Start( player, component, moveData )

        player:SetViewOffset( Vector( 0, 0, 24 ) );
        player:SetViewOffsetDucked( Vector( 0, 0, 24 ) );

        -- view extesion integration
        if ViewExtension then glue:GetComponent( player, "View" ):ShouldAim( 3, true ); end

        timer.Simple( 0.2, function() 

            player:EmitSound( "action_extension/land" .. math.Round( math.random( 1, 3 ) ) ..".wav" );

            if GetConVar( "cl_action_ext_slide_slowmo" ):GetBool() && !ActionExtension.SlowMotion:IsActive() then

                ActionExtension.SlowMotion:Toggle( player );
    
            end

        end )

        timer.Simple( 1.9, function()

            component:StopEvent();

            if GetConVar( "cl_action_ext_dive_slowmo" ):GetBool() && ActionExtension.SlowMotion:IsOwner( player ) && ActionExtension.SlowMotion:IsActive() then

                ActionExtension.SlowMotion:Toggle( player );
    
            end

        end )

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
        
        player:SetViewOffset( Vector( 0, 0, 64 ) );
            
    end

end

glue:GetSystem( "AnimationEvents" ):DefineAnimationEvent( ActionExtension.EVENT_SLIDE, Event );