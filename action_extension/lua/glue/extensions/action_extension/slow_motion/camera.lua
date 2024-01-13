local Сlass = glue.Class;

if SERVER then

	local Camera = Сlass {

		Start = function( self, player, type, target, uuid )

			net.Start( "ActionExtension:SetupCameraEvent" );
			net.WriteInt( type, 16 );
			net.WriteEntity( target || nil );
			net.WriteString( uuid || "" );
			net.Send( player );

		end;

		CanStart = function( self, player, victum )

			local trigger = GetConVar( "sv_action_ext_slowmo_camera" ):GetInt();

			if trigger == 0 then

				return false;

			elseif trigger == 1 then

				return true;

			elseif trigger == 2 then

				local count = 0;
				local entityList = ents.FindInPVS( player:GetPos() );

				for _, entity in pairs( entityList ) do

					if IsValid( entity ) && entity:IsNPC() && entity:Health() > 0 then

						count = count + 1;

					end

				end
				
				if count == 1 then

					return true;

				end

			end

		end

	}

	ActionExtension.Camera = Camera();

end

if CLIENT then

	local Camera = Сlass {

		Constructor = function( self )
		
			self.RenderBuffer = GetRenderTarget( "ActionExtensionCameraBuffer", ScrW(), ScrH(), false );
			self.MaterialRenderBuffer = CreateMaterial( "ActionExtensionCameraBuffer", "UnlitGeneric", { ['$basetexture'] = self.RenderBuffer, });
			self.ShouldDrawLocalPlayer = nil;
			self.Active = false;
			self.Type = ActionExtension.CAMERA_FACE;
			self.Target = nil;
			self.Variant = 0;
			self.StartTime = 0;
			self.LastPos = Vector( 0, 0, 0 );
			self.Fov = 45;
			self.Position = Vector( 0, 0, 0 );
			self.Angle = Vector( 0, 0, 0 );
			self.AngleOffset = Angle();
			self.AngleOffsetSpeed = 0.5;
			
		end;

		Start = function( self, player, type, target, uuid )
	
			self.UUID = uuid;
			self.Type = type;
			self.Target = target;
			self.Active = true;
			self.StartTime = CurTime();
			self.Variant = math.Round( math.random( 0, 3 ) );
	
			if self.Variant == 3 then
	
				self.AngleOffset = Angle( 0, 160, 0 );
	
			end

		end;

		Stop = function( self )

			self.Active = false;
			self.AngleOffset = Angle();

		end;

		Draw = function( self )

			self:Update();

			local screenWidth = ScrW();
			local screenHeight = ScrH();

			render.PushRenderTarget( self.RenderBuffer );
			render.ClearDepth();
			render.ClearStencil();
			
			cam.Start3D( EyePos(), EyeAngles() );

			self.ShouldDrawLocalPlayer = true;

			cam.End3D();
			
			render.RenderView({

				x = 0, 
				y = 0,
				w = screenWidth, 
				h = screenHeight,
				fov = self.Fov,
				origin = self.Position,
				angles = self.Angle,
				drawhud = false,
				drawviewmodel = false,
				dopostProcess = true

			})
			
			self.ShouldDrawLocalPlayer = nil;
			
			render.PopRenderTarget();

			self.MaterialRenderBuffer:SetTexture( '$basetexture', self.RenderBuffer );
			
			-- draw camera materail on screen
			render.SetMaterial( self.MaterialRenderBuffer );
			render.DrawScreenQuadEx( 0, 0, screenWidth, screenHeight );

		end;

		Update = function( self )

			local direction, ang, pos
			local target = self.Target;
			local type = self.Type;
			local player = LocalPlayer();

			if IsValid( target ) then
				
				self.LastPos = target:GetPos();
	
			end

			if ( self.StartTime + 2 ) > CurTime() then 
			
				if type == ActionExtension.CAMERA_BEHIND then
					
					local npcPos;
					
					if IsValid( target ) then

						npcPos = target:GetPos();

					else

						npcPos = self.LastPos;

					end
					
					local npcPos = self.LastPos;
					
					direction = player:GetPos() - npcPos;
					ang = direction:Angle();
					pos = Vector( npcPos.x, npcPos.y, npcPos.z + 50 ) + ang:Forward() * -75 + ang:Right() * -20;
					
					local trace = util.TraceLine( {

						start = npcPos,
						endpos = pos,
						filter = target

					} )
					
					if trace.Hit then

						if !IsValid( target ) then

							self.Target = player

						end
						
						self.Type = ActionExtension.CAMERA_FACE;

					else

						self.Position = pos;

					end
					
					self.Angle = ang;
					
				elseif type == ActionExtension.CAMERA_FACE then
				
					if IsValid( target ) then

						local headBone = target:LookupBone( "ValveBiped.Bip01_Head1" );
						
						if headBone == nil then 

							self.Target = player;
							return

						end;
							
						local headPos, headAngle = target:GetBonePosition( headBone );
						
						if headPos && headAngle then

							pos = headPos + headAngle:Right() * 80
							direction = headPos - pos
							ang = direction:Angle()
							
							local trace = util.TraceLine( {
								start = headPos,
								endpos = pos,
								filter = target
							} )
							
							if trace.Hit then

								self.Position = trace.HitPos

							else

								self.Position = pos

							end
							
							self.Angle = ang

						end

					end
					
				elseif type == ActionExtension.CAMERA_BULLET then
					
					local bullet = ActionExtension.Bullets.Bullets[ self.UUID ];

					if bullet then

						local angleOffset = Angle( 0, 20, 0 );

						if ( bullet.Type == ActionExtension.BULLET_RIFLE ) then

							angleOffset = Angle( -30, 90, 0 );

						end

						local cameraOffset = 70;

						if ( bullet.Type == ActionExtension.BULLET_BUCKSHOT ) then

							cameraOffset = 290;

						end

						local offsetSpeed = 2;

						if self.Variant == 2 then

							offsetSpeed = 0.1;

						end

						self.Fov = 15 + ( math.sin( self.StartTime - RealTime() ) * 10 );
						self.AngleOffset = LerpAngle( FrameTime() * offsetSpeed, self.AngleOffset, angleOffset );

						local bulletAngle = bullet.Dir:Angle();
						local cameraAngle = bulletAngle + self.AngleOffset;
						local bulletPosition = bullet.Models[0]:GetPos();

						local cameraPosition = bulletPosition + ( cameraAngle:Forward() * cameraOffset );
						local direction = bulletPosition - cameraPosition;

						local trace = util.TraceLine( {

							start = cameraPosition,
							endpos =  cameraPosition - ( cameraPosition:Angle():Forward() * 20 ),
							filter = player
				
						} )

						if trace.Hit then

							if self.Variant == 1 then

								self.Type = ActionExtension.CAMERA_FACE;

							elseif self.Variant == 2 then

								self.Type = ActionExtension.CAMERA_BEHIND;
								
							end

							if self.Variant > 0 then

								self.Fov = 70;

							end

						else

							self.Position = cameraPosition;
							self.Angle = direction:Angle();

						end
						
					else

						self.Type = ActionExtension.CAMERA_BEHIND;
						self.Fov = 70;

					end
					
				end

			else

				self:Stop();

			end

		end

	}

	ActionExtension.Camera = Camera();

end