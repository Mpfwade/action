local Сlass = glue.Class;

if SERVER then

	local SlowMotion = Сlass {

		Constructor = function( self )

			self.Active = false;
			self.Charge = 100;
			self.Owner = nil;

		end;

		IsActive = function( self )

			return self.Active;

		end;

		IsOwner = function( self, player )

			return self.Owner == player;

		end;

		Send = function( self )

			net.Start( "ActionExtension:SetupSlowMotion" );
			net.WriteBool( self.Active );
			net.WriteInt( math.floor( self.Charge ), 16 );
			net.Broadcast();

		end;

		Update = function( self )

			local duration = GetConVar( "sv_action_ext_slowmo_duration" ):GetFloat();

			if duration > 0 then

				local scale = ( 100 / duration );

				if self.Active then

					if !glue.Animations:IsPlaying( "ActionExtension:SlowMotionFadeOut" ) then
						
						local next = self.Charge - ( glue.RealFrameTime() * scale );

						if next > 0 then

							self.Charge = next;

						else

							self:Toggle( self.Owner );

						end

					end

				else

					if self.Charge < 100 then

						self.Charge = self.Charge + ( glue.RealFrameTime() * scale );
		
					else
		
						self.Charge = 100;
						self:Send();
		
					end

				end

			end

			if self.Active || self.Charge != 100 then

				self:Send();

			end

		end;

		CanUse = function( self, player )

			if GetConVar( "sv_action_ext_slowmo_duration" ):GetFloat() > 0 then

				if self.Charge <= 0 then

					return false;

				end

			end

			if GetConVar( "sv_action_ext_slowmo_adminonly" ):GetBool() then

				return GetConVar( "sv_action_ext_slowmo" ):GetBool() && ( player:IsAdmin() || player:IsSuperAdmin() );

			else

				return GetConVar( "sv_action_ext_slowmo" ):GetBool();

			end

		end;

		Toggle = function( self, player )

			if self.Active then

				if self.Owner == player || player:IsAdmin() || player:IsSuperAdmin() then
					
					glue.Animations:Stop( "ActionExtension:SlowMotionFadeIn" );
		
					if !glue.Animations:IsPlaying( "ActionExtension:SlowMotionFadeOut" ) then
					
						local timeScale = game.GetTimeScale();
		
						glue.Animations:Play( "ActionExtension:SlowMotionFadeOut", {
		
							RealTime = true,
							Duration = GetConVar( "sv_action_ext_slowmo_fadeout" ):GetFloat(),
							OnUpdate = function( fraction )
		
								game.SetTimeScale( Lerp( fraction, timeScale, 1 ) );
		
							end;
		
							OnEnd = function()
		
								ActionExtension.SlowMotion.Active = false;
								ActionExtension.SlowMotion.Owner = nil;

								-- Send not will be called in next tick if bullet time is not active, so using forced calling
								ActionExtension.SlowMotion:Send();
		
								-- reset time scale to default value
								game.SetTimeScale( 1 );
		
								hook.Call( "ActionExtension:StopSlowMotion", nil );
		
							end
		
						})

					else
		
						-- stopping the animation will call OnEnd function, this make bullet time inactive, so ToggleBulleTime called again
						glue.Animations:Stop( "ActionExtension:SlowMotionFadeOut" );
						self:Toggle( player );
		
					end

				end
	
			else

				if self:CanUse( player ) then

					glue.Animations:Stop( "ActionExtension:SlowMotionFadeOut" );
					glue.Animations:Play( "ActionExtension:SlowMotionFadeIn", {
		
						RealTime = true,
						Duration = GetConVar( "sv_action_ext_slowmo_fadein" ):GetFloat(),
						OnUpdate = function( fraction )
		
							game.SetTimeScale( Lerp( fraction, 1, 1 - GetConVar( "sv_action_ext_slowmo_strength" ):GetFloat() ) );
		
						end;
		
					})
		
					self.Active = true;
					self.Owner = player;

					hook.Call( "ActionExtension:StartSlowMotion", nil );

				end
				
			end

		end

	}

	ActionExtension.SlowMotion = SlowMotion();

end

if CLIENT then

	local SlowMotion = Сlass {

		Constructor = function( self )

			self.Charge = 100;
			self.ChargeView = 0;
			self.Active = false;
			self.Flash = 1.0;

		end;

		Draw = function( self )

			if GetConVar( "cl_action_ext_slowmo_fx_color_correction" ):GetBool() || GetConVar( "cl_action_ext_slowmo_fx_flash" ):GetBool() then

				if GetConVar( "cl_action_ext_slowmo_fx_flash" ):GetBool() then

					self.Flash = Lerp( RealFrameTime() * 4, self.Flash, 1 );

				else

					self.Flash = 1;

				end

				local data = {
					[ "$pp_colour_addr" ] = 0,
					[ "$pp_colour_addg" ] = 0,
					[ "$pp_colour_addb" ] = 0,
					[ "$pp_colour_brightness" ] = 0,
					[ "$pp_colour_contrast" ] = self.Flash,
					[ "$pp_colour_colour" ] = 1,
					[ "$pp_colour_mulr" ] = 0,
					[ "$pp_colour_mulg" ] = 0,
					[ "$pp_colour_mulb" ] = 0
				}

				if GetConVar( "cl_action_ext_slowmo_fx_color_correction" ):GetBool() then

					data["$pp_colour_colour"] = game.GetTimeScale();

				else

					data["$pp_colour_colour"] = 1;

				end

				DrawColorModify( data );

			end

			local duration = GetConVar( "sv_action_ext_slowmo_duration" ):GetFloat();

			if duration > 0 then

				if self.Charge < 100 then

					local width = 164;
					local heigth = 10;

					local x = ( ScrW() / 2 ) - width / 2;
					local y = ( ScrH() / 2 ) + 350;

					local corner = 5;
					
					self.ChargeView = Lerp( RealFrameTime() * 5, self.ChargeView, ( self.Charge / 100 ) * width );
					
					draw.RoundedBox( corner, x, y, width, heigth, Color( 0, 0, 0, 150 ) );
					draw.RoundedBox( corner, x, y, self.ChargeView, heigth, Color( 255, 220, 50, 255 ) );

				end

			end

		end;

		Setup = function( self, state, charge )

			if ActionExtension.SlowMotion.Active then

				if !state then
	
					hook.Call( "ActionExtension:StopSlowMotion", nil );
	
				end
	
			else
	
				if state then
	
					hook.Call( "ActionExtension:StartSlowMotion", nil );
	
				end
	
			end
	
			ActionExtension.SlowMotion.Active = state;
			ActionExtension.SlowMotion.Charge = charge;

		end

	}

	ActionExtension.SlowMotion = SlowMotion();

end