local Event = {};

Event.BoneManipulationCompletionDuration = 0.4;
Event.PreventDefaultMovement = true;
Event.Hull = { Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) };

-- return calculated bone manipulation data
function Event:CalcBoneManipulation( player, component )

    if !player:IsOnGround() then

        local lBoneWiggle = math.sin( CurTime() * 12 ) * 5;
        local rBoneWiggle = math.sin( CurTime() * 8 ) * 5; 

        if math.AngleDifference( component:GetEventDirection():Angle().y, player:GetAimVector():Angle().y ) > 0 then

            return {
                ["ValveBiped.Bip01_L_Calf"] = { angle = Angle( 0, 40, 0 ) },
                ["ValveBiped.Bip01_R_Calf"] = { angle = Angle( 0, rBoneWiggle, 0 ) },
                ["ValveBiped.Bip01_L_Thigh"] = { angle = Angle( -25, lBoneWiggle, 0 ) },
                ["ValveBiped.Bip01_R_Thigh"] = { angle = Angle( 0, rBoneWiggle, 0 ) },
                ["ValveBiped.Bip01_L_Foot"] = { angle = Angle( 0, 0, 0 ) },
                ["ValveBiped.Bip01_R_Foot"] = { angle = Angle( 0, 35, 0 ) }
            }

        else

            return {
                ["ValveBiped.Bip01_L_Calf"] = { angle = Angle( 0, 0, 0 ) },
                ["ValveBiped.Bip01_R_Calf"] = { angle = Angle( 0, 70 + rBoneWiggle, 0 ) },
                ["ValveBiped.Bip01_L_Thigh"] = { angle = Angle( -25, lBoneWiggle, 0 ) },
                ["ValveBiped.Bip01_R_Thigh"] = { angle = Angle( 0, rBoneWiggle - 25, 0 ) },
                ["ValveBiped.Bip01_L_Foot"] = { angle = Angle( 0, 35, 0 ) },
                ["ValveBiped.Bip01_R_Foot"] = { angle = Angle( 0, 0, 0 ) }
            }

        end

    else

        return {
            ["ValveBiped.Bip01_L_Calf"] = { angle = Angle( 0, 0, 0 ) },
            ["ValveBiped.Bip01_R_Calf"] = { angle = Angle( 0, 0, 0 ) },
            ["ValveBiped.Bip01_L_Thigh"] = { angle = Angle( 0, 0, 0 ) },
            ["ValveBiped.Bip01_R_Thigh"] = { angle = Angle( 0, 0, 0 ) },
            ["ValveBiped.Bip01_L_Foot"] = { angle = Angle( 0, 0, 0 ) },
            ["ValveBiped.Bip01_R_Foot"] = { angle = Angle( 0, 0, 0 ) }
        }

    end

end

-- return calculated "move_x" and "move_y" pose parameters
function Event:CalcPose( player, component, velocityAngle, aimAngle )

    return velocityAngle:Forward():Dot( aimAngle:Forward() ) * 2, -velocityAngle:Forward():Dot( aimAngle:Right() );

end

if SERVER then

    function Event:CanUseEvent( player )

        return GetConVar( "sv_action_ext_dive" ):GetBool()    
            && !ActionExtension:IsHitDirection( player, ActionExtension.TRACE_FORWARD ) 
            && player:GetMoveType() != MOVETYPE_NOCLIP && player:WaterLevel() < 2 
            && !player:InVehicle() 
            && player:IsOnGround() 
            && !ActionExtension:IsHitDirection( player, ActionExtension.TRACE_UP )
            && !player:KeyDown( IN_DUCK )

    end

    function Event:CreateJumpVelocity( player, direction )

        local velocity = Vector( direction.x, direction.y, 1 )
        velocity = velocity * 250.01;

        player.OverideVelocity = velocity;

    end

    function Event:CreateSideVelocity( player, component, left )

        local direction = player:EyeAngles():Forward();
        local ang = direction:Angle();
        local sideDirection = Vector( direction.x, direction.y, 1 );

        if left then

            sideDirection:Add( ang:Right() * 1.2 );

        else

            sideDirection:Add( -ang:Right() * 1.2 );

        end


        player.OverideVelocity = sideDirection * 260.01;
        component:SetEventParameters( ActionExtension.ACTIVITY_DIVE, sideDirection, true );

    end

    function Event:EmitSound( player )

        player:EmitSound( "action_extension/dive" .. math.Round( math.random( 1, 3 ) ) ..".wav" );

    end

    function Event:HandleSlowMotion( player )

        if GetConVar( "cl_action_ext_dive_slowmo" ):GetBool() && !ActionExtension.SlowMotion:IsActive() then

            ActionExtension.SlowMotion:Toggle( player );

        end

    end

    function Event:PostStart( player, component )

        player:SetGravity( 0 );

        if ViewExtension then 

            glue:GetComponent( player, "View" ):ShouldAim( 1, true ); 

        end

    end

    function Event:Start( player, component, direction )

        player:SetViewOffset( Vector( 0, 0, 46 ) );
        self:EmitSound( player );

        if GetConVar( "sv_action_ext_dive_wall" ):GetBool() && ActionExtension:IsHitDirection( player, ActionExtension.TRACE_LEFT ) then

            local direction = player:EyeAngles():Forward();

            component:SetEventParameters( ActionExtension.ACTIVITY_DIVE_WALL_R, direction, true );
            player:SetGravity( 1.5 );

            timer.Simple( 0.2, function() 

                self:CreateSideVelocity( player, component, true );
                self:PostStart( player, component );
                self:HandleSlowMotion( player );
                self:EmitSound( player );

            end )

        elseif GetConVar( "sv_action_ext_dive_wall" ):GetBool() && ActionExtension:IsHitDirection( player, ActionExtension.TRACE_RIGHT ) then

            local direction = player:EyeAngles():Forward();

            component:SetEventParameters( ActionExtension.ACTIVITY_DIVE_WALL_L, direction, true );
            player:SetGravity( 1.5 );

            timer.Simple( 0.2, function() 

                self:CreateSideVelocity( player, component, false );
                self:PostStart( player, component );
                self:HandleSlowMotion( player );
                self:EmitSound( player );

            end )

        else

            self:PostStart( player, component );

            timer.Simple( 0.2, function() 

                self:HandleSlowMotion( player );

            end )

        end

        self:CreateJumpVelocity( player, direction );
   
    end

    function Event:SetupMove( player, component, moveData )

        if player.OverideVelocity then

            moveData:SetVelocity( player.OverideVelocity );
            player.OverideVelocity = nil;

        end

        if ( player:IsOnGround() && player:KeyDown( IN_DUCK ) ) || ( player:GetMoveType() == MOVETYPE_NOCLIP || player:WaterLevel() > 0 || player:InVehicle() ) then

            component:StopEvent();

        end

    end

    function Event:Stop( player, component )
        
        player:SetViewOffset( Vector( 0, 0, 64 ) );
            
    end

end

glue:GetSystem( "AnimationEvents" ):DefineAnimationEvent( ActionExtension.EVENT_DIVE, Event );