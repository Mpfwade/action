local Component = {}

function Component:Initialize()

	self.EventID = -1;
	self.Activity = -1;
	self.EventDirection = Vector();

	if SERVER then

		self.Velocity = 0;
		self.Deceleration = 2;

	end
	
end

function Component:GetActivity()

    return self.Activity;

end

function Component:CalcEventDirection( player, moveData )

    local velocity = moveData:GetVelocity();

    -- Check if velocity is zero (player stationary)
    if velocity:Length() == 0 then

        local viewAngles;

        -- Check for View Extension
        if ViewExtension then
            viewAngles = glue:GetComponent( player, "View" ):GetCameraAngles();
        else
            viewAngles = player:GetRenderAngles();
        end

        local sideMove = 0;
        local forwardMove = 0;

        -- Determine forward and side movement based on player input
        if player:KeyDown( IN_MOVERIGHT ) then
            sideMove = 1;
        elseif player:KeyDown( IN_MOVELEFT ) then
            sideMove = -1;
        end

        if player:KeyDown( IN_FORWARD ) then
            forwardMove = 1;
        elseif player:KeyDown( IN_BACK ) then
            forwardMove = -1;
        end

        -- Calculate new movement direction based on view angles and player input
        local direction = (viewAngles:Forward() * forwardMove) + (viewAngles:Right() * sideMove);
        direction:Normalize(); -- Normalize to get direction only
        return direction;

    else
        -- Normalize velocity to get direction only if player is moving
        velocity:Normalize();
        return velocity;
    end

end

function Component:GetEventDirection()

    return self.EventDirection;

end

function Component:GetEventID()

    return self.EventID;

end

function Component:GetEvent()

    return self.System.AnimationEvents[ self:GetEventID() ];

end

function Component:HasEvent( id )

	return self:GetEventID() == id;

end

function Component:CanUseEvent( id )

	local event = self.System.AnimationEvents[ id ];

	if event then

		if event.CanUseEvent then

			return event:CanUseEvent( self:GetOwner() );

		else

			return true;

		end

	else

		return false;

	end

end

-- return the sequence name a depend on hold-type of active player weapon
function Component:GetMainActivity()

	local act = self:GetActivity();

	if ActionExtension.AnimationActivity[ act ] then

		return ActionExtension.AnimationActivity[ act ][ glue.GetHoldType( self:GetOwner() ) || "normal" ];

	else

		return false;

	end

end

function Component:CalcMainActivity( player, velocity )

	if self:GetActivity() > -1 then

		local seq = self:GetMainActivity();
		local seqid = player:LookupSequence( seq || "" );

		if seqid < 0 then
			
			return;

		end

		return 1, seqid || nil;

	else

		if GetConVar( "sv_action_ext_sprint" ):GetBool() && !player:InVehicle() && player:IsSprinting() && player:IsOnGround() then

			return 1, player:LookupSequence( "run_all_02" );

		end

	end

end

function Component:UpdateAnimation( player, velocity, maxSeqGroundSpeed )

	-- bone manipulations
	local event = self:GetEvent();

	if event && event.CalcBoneManipulation then

		-- calculate bone manipulation of event
		local boneData = event:CalcBoneManipulation( player, self );
		local startData = ActionExtension:GetBoneManipulationByMap( player, boneData );

		-- reset completion
		if self.ActionExtensionCompletionStart then

			self.ActionExtensionCompletionStart = nil;
			
		end

		-- store completion duration and bone manipulation map of current event for smooth completion after event or bone manipulation is lost
		self.ActionExtensionBoneManipulation = boneData;
		self.ActionExtensionCompletionDuration = event.BoneManipulationCompletionDuration || ActionExtension.DefaultBoneManipulationCompletionDuration;

		ActionExtension:LerpBoneManipulation( player, FrameTime() * 12, startData, boneData );

	elseif self.ActionExtensionBoneManipulation then

		-- start completion
		if !self.ActionExtensionCompletionStart then

			self.ActionExtensionCompletionStart = CurTime();

		end

		if ( self.ActionExtensionCompletionStart + self.ActionExtensionCompletionDuration ) > CurTime() then

			-- calculate completion of bone manipulation
			local fraction = ( ( CurTime() - self.ActionExtensionCompletionStart ) / self.ActionExtensionCompletionDuration ) * 1;
			ActionExtension:LerpBoneManipulation( player, fraction, self.ActionExtensionBoneManipulation );

		else

			-- reset bone manipulation to defaults
			ActionExtension:ResetBoneManipulationByMap( player, self.ActionExtensionBoneManipulation );

			self.ActionExtensionBoneManipulation = nil;
			self.ActionExtensionCompletionStart = nil;
			self.ActionExtensionCompletionDuration = nil;

		end

	end

	-- pose & playback rate of activiy and break
	if self:GetActivity() > -1 then

		local event = self:GetEvent();

		if event then

			-- calc pose
			if event.CalcPose then
				
				local eventAngles = self:GetEventDirection():Angle();
				eventAngles.p = 0;
				
				local renderAngles;

				if ViewExtension then

					renderAngles = glue:GetComponent( player, "View" ):GetRenderAngles();
				
				else

					renderAngles = player:GetAimVector():Angle();
					renderAngles.p = 0;

				end

				local moveX, moveY = event:CalcPose( player, self, eventAngles, renderAngles );

				player:SetPoseParameter( "move_x", moveX );
				player:SetPoseParameter( "move_y", moveY );
				
			end

			-- activity playback rate
			if event.ActivityPlaybackRate then

				player:SetPlaybackRate( event.ActivityPlaybackRate );

			end

		end

		return true;

	else

		if GetConVar( "sv_action_ext_sprint" ):GetBool() then

			if player:IsSprinting() then

				player:SetPlaybackRate( 1.2 );

			else

				player:SetPlaybackRate( 0.9 );

			end

			return true;

		end

	end

end

if CLIENT then

	function Component:CreateMove( cmd )

		local event = self:GetEvent();

		if event then

			-- prevent movement
			if event.PreventDefaultMovement then

				cmd:ClearMovement();
				cmd:RemoveKey( IN_DUCK );

			end

			-- calculation view angles
			if event.CalcViewAngles then

				cmd:SetViewAngles( event:CalcViewAngles( self:GetOwner(), self, cmd:GetViewAngles() ) );

			end

		end

	end

end

if SERVER then

	function Component:GetVelocity()

		return self.Velocity;

	end

	function Component:SetupMove( player, moveData )

		-- bind events
		if self:GetEventID() == -1 then

			if glue:IsCommandDown( ActionExtension.IN_DIVE, player ) && glue.MoveKeysDown( player ) && self:CanUseEvent( ActionExtension.EVENT_DIVE ) then

				moveData:SetVelocity( Vector() );
				self:StartEvent( ActionExtension.EVENT_DIVE, ActionExtension.ACTIVITY_DIVE, self:CalcEventDirection( player, moveData ) );

			end

			if glue:IsCommandDown( ActionExtension.IN_ROLL, player ) && glue.MoveKeysDown( player ) && self:CanUseEvent( ActionExtension.EVENT_ROLL ) then

				moveData:SetVelocity( Vector() );
				self:StartEvent( ActionExtension.EVENT_ROLL, ActionExtension.ACTIVITY_ROLL, self:CalcEventDirection( player, moveData ) );

			end

			if glue:IsCommandDown( ActionExtension.IN_SLIDE, player ) && glue.MoveKeysDown( player ) && self:CanUseEvent( ActionExtension.EVENT_SLIDE ) then

				local ang = player:EyeAngles();
				self:StartEvent( ActionExtension.EVENT_SLIDE, ActionExtension.ACTIVITY_DIVE, ang:Forward() );

			end

		end

		local event = self:GetEvent();

		if event then

			if event.Velocity then
				
				self.Velocity = Lerp( FrameTime() * event.Deceleration, self.Velocity, 0 );

			end

			if event.SetupMove then

				event:SetupMove( player, self, moveData );

			end

		end

	end

    function Component:SetEvent( id, act, direction )

		local player = self:GetOwner();

		self.EventID = id;
		self.Activity = act;
		self.EventDirection = direction || Vector();

		player:AnimRestartMainSequence();

		-- to prevent uncorrect animation update, event and activity data should be sent in one packet
		net.Start( "ActionExtension:SetupPlayerEvent" );
		net.WriteEntity( player );
		net.WriteInt( id, 6 );
		net.WriteInt( act, 6 );
		net.WriteVector( direction || Vector() );
		net.Broadcast();

	end

	function Component:SetEventParameters( act, direction, restart )

		local player = self:GetOwner();

		self.Activity = act;
		self.EventDirection = direction || Vector();

		if restart then

			player:AnimRestartMainSequence();
			
		end

		-- switch event parameters in one packet
		net.Start( "ActionExtension:SetupPlayerEventParameters" );
		net.WriteEntity( player );
		net.WriteInt( act, 6 );
		net.WriteVector( direction || Vector() );
		net.WriteBool( restart );
		net.Broadcast();

	end

	function Component:StartEvent( id, act, direction )

		local event = self.System.AnimationEvents[id];
	
		if event then
	
			local player = self:GetOwner();
	
			-- Debugging: Log the event ID and direction vector
			print("Starting Event:", id, "Direction:", direction)
	
			self.Velocity = event.Velocity;
	
			if event.Hull then
				player:SetHull( event.Hull[1], event.Hull[2] );
			end
	
			self:SetEvent( id, act, direction );
	
			if event.Start then
				event:Start( player, self, self:GetEventDirection() );
			end
	
		end
		
	end
	

	function Component:StopEvent()

		local event = self:GetEvent();

		if event then

			local player = self:GetOwner();

			-- reset current event
			self:SetEvent( -1, -1 );

			if event.Hull then

				player:ResetHull();

			end

			if event.Stop then

				event:Stop( player, self );

			end

		end

	end

end

local ComponentSystem = {};

function ComponentSystem:Initialize()

	self.AnimationEvents = {};

end

function ComponentSystem:DefineAnimationEvent( id, event )

	self.AnimationEvents[ id ] = event;

end

glue:DefineComponent( "AnimationEvents", ComponentSystem, Component, { "player" } );