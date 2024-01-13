local Extension = {};

Extension.Name = "Action Extension";
Extension.Version = "2.0"
Extension.Author = "Isaac Macgill";
Extension.Includes = {

	"constants.lua",
	"commands.lua",
	"util.lua",
	"slow_motion/main.lua",
	"slow_motion/bullet_physics.lua",
	"slow_motion/camera.lua",
	
	"animation_events/*",

	"hooks.lua",
	"net.lua"

};

Extension.Commands = {

	action_ext_slow_motion =	{ Bind = "x", 			Network = true, 	PreventDefault = true, InVehicle = false, InSpawnMenu = false },
	action_ext_dive = 			{ Bind = "space", 		Network = true,  	PreventDefault = true, InVehicle = false, InSpawnMenu = false },
	action_ext_roll = 			{ Bind = "alt", 		Network = true, 	PreventDefault = true, InVehicle = false, InSpawnMenu = false },
	action_ext_slide = 			{ Bind = "capslock",	Network = true, 	PreventDefault = true, InVehicle = false, InSpawnMenu = false }

}

Extension.Menu = {};

Extension.Menu[ "slow_motion" ] = {

	Name = "#action_extension.slow_motion",
	Presets = {
		[ "#preset.default" ] = {
			sv_action_ext_slowmo = 1,
			sv_action_ext_slowmo_adminonly = 0,
			sv_action_ext_slowmo_strength = 0.7,
			sv_action_ext_slowmo_fadein = 0.2,
			sv_action_ext_slowmo_fadeout = 0.5,
			sv_action_ext_slowmo_duration = 0,
			sv_action_ext_slowmo_camera = 1,
			sv_action_ext_slowmo_sound = 1,
			sv_action_ext_slowmo_bullet = 1,
			sv_action_ext_slowmo_bullet_speed = 2000,
			cl_action_ext_slowmo_bullet_tracer_length = 220,
			cl_action_ext_slowmo_fx_color_correction = 1,
			cl_action_ext_slowmo_fx_flash = 1,
			cl_action_ext_slowmo_fx_sound = 1
		}
	},
	ConVars = {
		"sv_action_ext_slowmo",
		"sv_action_ext_slowmo_adminonly",
		"sv_action_ext_slowmo_strength",
		"sv_action_ext_slowmo_fadein",
		"sv_action_ext_slowmo_fadeout",
		"sv_action_ext_slowmo_duration",
		"sv_action_ext_slowmo_camera",
		"sv_action_ext_slowmo_sound",
		"sv_action_ext_slowmo_bullet",
		"sv_action_ext_slowmo_bullet_speed",
		"cl_action_ext_slowmo_bullet_tracer_length",
		"cl_action_ext_slowmo_fx_color_correction",
		"cl_action_ext_slowmo_fx_flash",
		"cl_action_ext_slowmo_fx_sound"
	},
	Layout = {
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.enabled",
			convar = "sv_action_ext_slowmo"
		},
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.adminonly",
			convar = "sv_action_ext_slowmo_adminonly" 
		},
		{
			type = "Slider",
			label = "#action_extension.slow_motion.strength",
			convar = "sv_action_ext_slowmo_strength",
			min = 0,
			max = 0.99
		},
		{ type = "Help", label = "#action_extension.slow_motion.strength.help" },
		{
			type = "Slider",
			label = "#action_extension.slow_motion.fadein",
			convar = "sv_action_ext_slowmo_fadein",
			min = 0,
			max = 1
		},
		{
			type = "Slider",
			label = "#action_extension.slow_motion.fadeout",
			convar = "sv_action_ext_slowmo_fadeout",
			min = 0,
			max = 1
		},
		{
			type = "Slider",
			label = "#action_extension.slow_motion.duration",
			convar = "sv_action_ext_slowmo_duration",
			min = 0,
			max = 20
		},
		{ type = "Help", label = "#action_extension.slow_motion.duration.help" },
		{ 
			type = "ComboBox",
			label = "#action_extension.slow_motion.camera",
			convar = "sv_action_ext_slowmo_camera",
			options = {
				{ "#action_extension.slow_motion.camera.option1", 0 },
				{ "#action_extension.slow_motion.camera.option2", 1 },
				{ "#action_extension.slow_motion.camera.option3", 2 }
			}
		},
		{ type = "Help", label = "#action_extension.slow_motion.camera.help" },
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.sound",
			convar = "sv_action_ext_slowmo_sound"
		},
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.bullet",
			convar = "sv_action_ext_slowmo_bullet"
		},
		{
			type = "Slider",
			label = "#action_extension.slow_motion.bullet_speed",
			convar = "sv_action_ext_slowmo_bullet_speed",
			min = 600,
			max = 5000
		},
		{
			type = "Slider",
			label = "#action_extension.slow_motion.bullet_tracer_length",
			convar = "cl_action_ext_slowmo_bullet_tracer_length",
			min = 0,
			max = 1000
		},
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.fx_color_correction",
			convar = "cl_action_ext_slowmo_fx_color_correction"
		},
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.fx_flash",
			convar = "cl_action_ext_slowmo_fx_flash"
		},
		{
			type = "CheckBox",
			label = "#action_extension.slow_motion.fx_sound",
			convar = "cl_action_ext_slowmo_fx_sound"
		}
	}

}

Extension.Menu[ "player" ] = {

	Name = "#action_extension.player",
	Presets = {
		[ "#preset.default" ] = {
			sv_action_ext_dive = 1,
			sv_action_ext_dive_wall = 1,
			sv_action_ext_roll = 1,
			sv_action_ext_slide = 1,
			cl_action_ext_dive_slowmo = 1,
			cl_action_ext_roll_slowmo = 0,
			cl_action_ext_slide_slowmo = 0,
			sv_action_ext_sprint = 1
		}
	},
	ConVars = {
		"sv_action_ext_dive",
		"sv_action_ext_dive_wall",
		"sv_action_ext_roll",
		"sv_action_ext_slide",
		"cl_action_ext_dive_slowmo",
		"cl_action_ext_roll_slowmo",
		"cl_action_ext_slide_slowmo",
		"sv_action_ext_sprint"
	},
	Layout = {
		{
			type = "CheckBox",
			label = "#action_extension.dive",
			convar = "sv_action_ext_dive"
		},
		{
			type = "CheckBox",
			label = "#action_extension.dive_wall",
			convar = "sv_action_ext_dive_wall"
		},
		{
			type = "CheckBox",
			label = "#action_extension.roll",
			convar = "sv_action_ext_roll"
		},
		{
			type = "CheckBox",
			label = "#action_extension.slide",
			convar = "sv_action_ext_slide"
		},
		{
			type = "CheckBox",
			label = "#action_extension.dive_slowmo",
			convar = "cl_action_ext_dive_slowmo"
		},
		{
			type = "CheckBox",
			label = "#action_extension.roll_slowmo",
			convar = "cl_action_ext_roll_slowmo"
		},
		{
			type = "CheckBox",
			label = "#action_extension.slide_slowmo",
			convar = "cl_action_ext_slide_slowmo"
		},
		{
			type = "CheckBox",
			label = "#action_extension.sprint",
			convar = "sv_action_ext_sprint"
		}
	}

}

Extension.Menu[ "keybinds" ] = {

	Name = "#action_extension.keybinds",
	Layout = {
		{ 
			type = "Bind",
			label = "#action_extension.keybinds.slow_motion",
			command = "action_ext_slow_motion"
		},
		{ 
			type = "Bind",
			label = "#action_extension.keybinds.dive",
			command = "action_ext_dive"
		},
		{ 
			type = "Bind",
			label = "#action_extension.keybinds.roll",
			command = "action_ext_roll"
		},
		{ 
			type = "Bind",
			label = "#action_extension.keybinds.slide",
			command = "action_ext_slide"
		}
	}

}

ActionExtension = {};
glue:Mount( "action_extension", Extension );