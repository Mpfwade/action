local Class = glue.Class;

local BulletPhysics = glue.Class {

	Constructor = function( self )

		self.Bullets = {};

		if CLIENT then

			self.SmokeMaterial = Material( 'trails/smoke' );

		end

		if SERVER then

			self.PreventFireBullets = false;

		end

	end;

	Remove = function( self, uuid )

		local bullet = self.Bullets[ uuid ];

		if bullet then
	
			if CLIENT then
	
				-- remove client models
				if IsValid( bullet.Models[0] ) then
	
					bullet.Models[0]:Remove();
	
				end
	
				if IsValid( bullet.Models[1] ) then
	
					bullet.Models[1]:Remove();
	
				end
	
			end
	
			if SERVER then
	
				-- remove bullet from all clients
				net.Start( "ActionExtension:RemoveBullet");
				net.WriteString( uuid );
				net.Broadcast();

			end

			-- remove bullet from table
			self.Bullets[ uuid ] = nil;
	
		end

	end;

	Release = function( self, uuid )

		if SERVER then

			local bullet = self.Bullets[ uuid ];

			if bullet then

				local entity = bullet.Owner;
			
				if IsValid( entity ) then
					
					-- hide bullet tracer
					bullet.Data.TracerName = "nil";
					bullet.Data.Tracer = 0;
			
					-- prevent recusive calling FireBullets
					self.PreventFireBullets = true;
			
					entity:FireBullets( bullet.Data );
			
					self.PreventFireBullets = false;
			
				end

				-- remove bullet on server side
				self:Remove( uuid );

			end

		end

	end;

	Fire = function( self, entity, data )

		if SERVER then

			-- get bullet ammo type
			local weapon = nil;

			if entity:IsWeapon() then

				weapon = entity;
				entity = data.Attacker;

			elseif entity.GetActiveWeapon then

				weapon = entity:GetActiveWeapon();

			end

			local ammoType = -1;
	
			if data.AmmoType != "" then
	
				ammoType = game.GetAmmoID( data.AmmoType );
	
			elseif weapon then
				
				ammoType = weapon:GetPrimaryAmmoType();
	
			end

			local shootPosition = Vector();

			if entity.GetShootPos then

				shootPosition = entity:GetShootPos();

			else

				shootPosition = data.Src;

			end
	
			-- create single bullets according bullets num from bullet structure
			for i = 1, data.Num do
	
				local bullet = {};
	
				bullet.Owner = entity;
				bullet.Position = shootPosition;
	
				local spread = data.Spread;
				local angle = data.Dir:Angle();
	
				angle:RotateAroundAxis( angle:Up(), math.random( -spread.x * 45, spread.x * 45, 0 + i ) );
				angle:RotateAroundAxis( angle:Right(), math.random( -spread.y * 45, spread.y * 45, 1 + i ) );
	
				local direction = angle:Forward();
	
				-- calc end bullet position
				local trace = util.TraceLine( {
	
					start = shootPosition,
					endpos =  shootPosition + ( direction * 10000 ),
					filter = entity
	
				} )
	
				-- copy & modify bullet structure
				bullet.Data = table.Copy( data );

				bullet.Data.Dir = direction;
				bullet.Data.Spread = Vector();
				bullet.Data.Num = 1;
	
				-- generate bullet uuid
				local uuid = glue.UUID();
				
				-- handle camera
				local victum = trace.Entity;

				if IsValid( victum ) && entity:IsPlayer() && victum:IsNPC() then

					--[[
					local damage = bullet.Data.Damage;
		
					if damage == 0 then
		
						damage = game.GetAmmoNPCDamage( ammoType );
		
					end
					]]

					local damage = self:GetPredictedBulletDamage( entity, data );

					-- health prediction
					local health = glue:GetData( victum, "ActionExtension:PredictedHealth", victum:Health() );

					health = health - damage;

					if ActionExtension.Camera:CanStart( entity, victum ) && health <= damage && !glue:GetData( victum, "ActionExtension:IsCameraTarget", false ) then
	
						local flyTime = CurTime() + ( ( shootPosition:Distance( trace.HitPos ) - 15 ) / GetConVar( "sv_action_ext_slowmo_bullet_speed" ):GetInt() );

						ActionExtension.Camera:Start( entity, ActionExtension.CAMERA_BULLET, victum, uuid, victum:WorldToLocal( trace.HitPos ) );

						bullet.CameraData = {
							Target = victum,
							TargetHitPosition = victum:WorldToLocal( trace.HitPos ),
							Time = flyTime,
							AmmoType = ammoType,
							TraceResult = trace
						}

						glue:SetData( victum, "ActionExtension:IsCameraTarget", true );
	
					end

					glue:SetData( victum, "ActionExtension:PredictedHealth", health );
	
				end
	
				self.Bullets[ uuid ] = bullet;
	
				-- fire bullet for all clients
				net.Start( "ActionExtension:FireBullet" );
	
				net.WriteString( uuid );
				net.WriteEntity( entity );
				net.WriteInt( ammoType, 16 );
				net.WriteVector( trace.HitPos );
				net.WriteEntity( trace.Entity );
				
				net.Broadcast();
	
			end
	
		end;
	
		if CLIENT then
	
			local bullet = data;
			local position = ActionExtension:GetBulletSourcePosition( entity );

			bullet.Owner = entity;
			bullet.PositionStart = position;
			bullet.Position = position;
			bullet.Dir = bullet.PositionEnd - position;
			bullet.Dir:Normalize();
		
			local angle = bullet.Dir:Angle();
			bullet.Type = ActionExtension.BulletTypes[ bullet.AmmoType ] or ActionExtension.BULLET_PISTOL;
			bullet.Models = {};

			bullet.Models[0] = ents.CreateClientProp();
			bullet.Models[0]:SetModel( "models/bullets/bullet_" .. bullet.Type  .. ".mdl" );
			bullet.Models[0]:SetAngles( Angle( angle.x + 90, angle.y, angle.z ) );
		
			bullet.Models[1] = ents.CreateClientProp();
			bullet.Models[1]:SetModel( "models/bullets/trace_" .. bullet.Type  .. ".mdl" );
			bullet.Models[1]:SetAngles( Angle( angle.x + 90, angle.y, angle.z ) );
	
			self.Bullets[ bullet.uuid ] = bullet;
	
		end

	end;

	-- this solution is total cringe, but this works
	
	-- different damage implementations in other weapons addons makes bullet structure is useless for prediction.
	-- the same applies to game.GetAmmoNPCDamage and game.GetAmmoPlayerDamage, since the functions do not take into account damage modifiers
	GetPredictedBulletDamage = function( self, player, data )

		if IsValid( self.DamageCatcher ) then

			self.PreventFireBullets = true;

			local temp = table.Copy( data );

			temp.Src = self.DamageCatcher:GetPos() + Vector( 0, 0, 25 );
			temp.Dir = self.DamageCatcher:GetPos() - temp.Src;
			temp.Num = 1;
			temp.Spread = Vector();

			player:FireBullets( temp );

			self.PreventFireBullets = false;

			return self.DamageCatcher.CurrentDamage;

		end

	end;

	Update = function( self, uuid, bullet )

		if SERVER then

			if !IsValid( self.DamageCatcher ) then

				self.DamageCatcher = ents.Create( "action_extension_damage_catcher" );
				self.DamageCatcher:SetPos( Vector( 0, 0, -9999 ) );
				self.DamageCatcher:Spawn();

			end

		end

		for uuid, bullet in pairs( self.Bullets ) do
			
			if CLIENT then

				if IsValid( bullet.Models[0] ) && IsValid( bullet.Models[1] ) then

					bullet.Position = bullet.Position + ( bullet.Dir * ( FrameTime() * GetConVar( "sv_action_ext_slowmo_bullet_speed" ):GetInt() ) );
					bullet.Models[0]:SetPos( bullet.Position );
					bullet.Models[1]:SetPos( bullet.Position );

					-- animate bullet twist
					local angle = bullet.Models[0]:GetAngles();
					angle:RotateAroundAxis( angle:Up(), FrameTime() * 20000 );

					bullet.Models[0]:SetAngles( angle );
				
				else

					self:Remove( uuid );

				end
		
			end
		
			if SERVER then

				local cameraData = bullet.CameraData;

				if cameraData && IsValid( cameraData.Target ) then

					if CurTime() > cameraData.Time then

						local damage = DamageInfo();

						damage:SetDamage( cameraData.Target:Health() );
						damage:SetDamageType( DMG_BULLET );
						damage:SetAmmoType( cameraData.AmmoType );
						damage:SetAttacker( bullet.Owner );
						damage:SetInflictor( bullet.Owner );
						damage:SetReportedPosition( cameraData.Target:GetPos() );
						damage:SetDamagePosition( cameraData.Target:GetPos() );

						cameraData.TraceResult.HitPos = cameraData.Target:LocalToWorld( cameraData.TargetHitPosition );

						cameraData.Target:SetHealth( 1 );
						cameraData.Target:DispatchTraceAttack( damage, cameraData.TraceResult );

						self:Remove( uuid );

					end

				else

					-- collision detection by trace
					local trace = util.TraceLine( {
			
						start = bullet.Position,
						endpos = bullet.Position + ( bullet.Data.Dir * ( FrameTime() * GetConVar( "sv_action_ext_slowmo_bullet_speed" ):GetInt() ) ),
						filter = bullet.Owner
			
					} )
			
					if trace.Hit then
			
						-- set bullet source to previous bullet position & release
						bullet.Data.Src = bullet.Position;
						self:Release( uuid );
			
					else
			
						-- apply new bullet position
						bullet.Position = trace.HitPos;
			
					end

				end
		
			end
	
		end

	end;

	Draw = function( self )

		if CLIENT then

			-- draw bullet tracer
			if !ActionExtension.Camera.Active || ActionExtension.Camera.Type != ActionExtension.CAMERA_BULLET then

				local length = GetConVar( "cl_action_ext_slowmo_bullet_tracer_length" ):GetFloat();

				if length > 0 then 

					local color = Color( 255, 255, 255, 90 );

					for uuid, bullet in pairs( self.Bullets ) do
		
						render.SetMaterial( self.SmokeMaterial );
						render.StartBeam( 2 );
						render.AddBeam( bullet.Position, 1.2, 0.5, color );
						render.AddBeam( bullet.Position - ( bullet.Dir * math.Clamp( bullet.PositionStart:Distance( bullet.Position ), 0, length ) ), 0.1, 0, color );
						render.EndBeam();
		
					end
				
				end

			end

		end

	end

}

ActionExtension.Bullets = BulletPhysics();