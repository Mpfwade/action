CreateConVar( "sv_action_ext_dive",							1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_dive_wall",					1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_roll",							1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slide",						1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_sprint",						1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo",						1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_adminonly",				1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_strength",				0.7, 		{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_fadein",				0.5, 		{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_fadeout",				0.5, 		{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_duration",				0, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_camera",				1,			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_bullet",				1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_bullet_speed",			2000, 		{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );
CreateConVar( "sv_action_ext_slowmo_sound",					1, 			{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE },	"" );

if SERVER then

	cvars.AddChangeCallback( "sv_action_ext_slowmo", function( name, value_old, value_new )

		if value_new == "0" && ActionExtension.SlowMotion:IsActive() then

			ActionExtension.SlowMotion:Toggle( ActionExtension.SlowMotion.Owner );

		end

	end )

end

if CLIENT then

	CreateClientConVar( "cl_action_ext_dive_slowmo",					1,		true, true, 	"" );
	CreateClientConVar( "cl_action_ext_roll_slowmo",					0,		true, true, 	"" );
	CreateClientConVar( "cl_action_ext_slide_slowmo",					0,		true, true, 	"" );
	CreateClientConVar( "cl_action_ext_slowmo_bullet_tracer_length",	220, 	true, true, 	"" );
	CreateClientConVar( "cl_action_ext_slowmo_fx_color_correction",		1,		true, true, 	"" );
	CreateClientConVar( "cl_action_ext_slowmo_fx_flash",				1,		true, true, 	"" );
	CreateClientConVar( "cl_action_ext_slowmo_fx_sound",				1,		true, true, 	"" );

end