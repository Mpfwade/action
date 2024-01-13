ActionExtension.IN_DIVE					= "action_ext_dive";
ActionExtension.IN_ROLL 				= "action_ext_roll";
ActionExtension.IN_SLIDE 				= "action_ext_slide";
ActionExtension.IN_SLOW_MOTION 			= "action_ext_slow_motion";

ActionExtension.TRACE_LEFT 				= 0;
ActionExtension.TRACE_RIGHT 			= 1;
ActionExtension.TRACE_FORWARD 			= 2;
ActionExtension.TRACE_BACK 				= 3;
ActionExtension.TRACE_UP 				= 4;
ActionExtension.TRACE_BOTTOM 			= 5;

ActionExtension.EVENT_DIVE 				= 1;
ActionExtension.EVENT_DIVE_WALL 		= 2;
ActionExtension.EVENT_SLIDE 			= 3;
ActionExtension.EVENT_ROLL 				= 4;

ActionExtension.ACTIVITY_DIVE 			= 1;
ActionExtension.ACTIVITY_DIVE_WALL_R 	= 2;
ActionExtension.ACTIVITY_DIVE_WALL_L 	= 3;
ActionExtension.ACTIVITY_ROLL 			= 4;
ActionExtension.ACTIVITY_WALL_JUMP 		= 5;

ActionExtension.CAMERA_BEHIND			= 0;
ActionExtension.CAMERA_FACE				= 1;
ActionExtension.CAMERA_BULLET 			= 2;

ActionExtension.BULLET_PISTOL 			= "pistol";
ActionExtension.BULLET_RIFLE 			= "rifle";
ActionExtension.BULLET_BUCKSHOT 		= "buckshot";
ActionExtension.BULLET_357 				= "357";

ActionExtension.BulletTypes = {
	
	[1] 	= ActionExtension.BULLET_RIFLE,
	[3] 	= ActionExtension.BULLET_PISTOL,
	[4] 	= ActionExtension.BULLET_PISTOL,
	[5] 	= ActionExtension.BULLET_357,
	[7] 	= ActionExtension.BULLET_BUCKSHOT,
	[14] 	= ActionExtension.BULLET_RIFLE,
	[23] 	= ActionExtension.BULLET_PISTOL

}

ActionExtension.DefaultBoneManipulationCompletionDuration = 1;
ActionExtension.DefaultBoneManipulationTransitionDuration = 12;

ActionExtension.AnimationActivity = {};

ActionExtension.AnimationActivity[ ActionExtension.ACTIVITY_DIVE ] = {

	crowbar		= "dive_knife",
	knife		= "dive_knife",
	fist		= "dive_pistol",
	melee		= "dive_knife",
	melee2		= "dive_knife",
	normal		= "dive_ar",
	passive		= "dive_ar",
	pistol		= "dive_pistol",
	revolver	= "dive_revolver",
	duel		= "dive_akimbo",
	smg			= "dive_smg",
	ar2			= "dive_ar",
	shotgun		= "dive_sniper",
	crossbow	= "dive_shotgun",
	rpg			= "dive_ar",
	grenade		= "dive_grenade",
	slam		= "dive_grenade",
	physgun		= "dive_ar",
	camera		= "dive_pistol",
	magic		= "dive_pistol"

};

ActionExtension.AnimationActivity[ ActionExtension.ACTIVITY_DIVE_WALL_R ] = {

	crowbar		= "walldive_knife",
	knife		= "walldive_knife",
	fist		= "walldive_pistol",
	melee		= "walldive_knife",
	melee2		= "walldive_knife",
	normal		= "walldive_ar",
	passive		= "walldive_ar",
	pistol		= "walldive_pistol",
	revolver	= "walldive_revolver",
	duel		= "walldive_akimbo",
	smg			= "walldive_smg",
	ar2			= "walldive_ar",
	shotgun		= "walldive_sniper",
	crossbow	= "walldive_shotgun",
	rpg			= "walldive_ar",
	grenade		= "walldive_gren_frag",
	slam		= "walldive_gren_frag",
	physgun		= "walldive_ar",
	camera		= "walldive_pistol",
	magic		= "walldive_pistol"

};

ActionExtension.AnimationActivity[ ActionExtension.ACTIVITY_DIVE_WALL_L ] = {

	crowbar		= "walldivel_knife",
	knife		= "walldivel_knife",
	fist		= "walldivel_pistol",
	melee		= "walldivel_knife",
	melee2		= "walldivel_knife",
	normal		= "walldivel_ar",
	passive		= "walldivel_ar",
	pistol		= "walldivel_pistol",
	revolver	= "walldivel_revolver",
	duel		= "walldivel_akimbo",
	smg			= "walldivel_smg",
	ar2			= "walldivel_ar",
	shotgun		= "walldivel_sniper",
	crossbow	= "walldivel_shotgun",
	rpg			= "walldivel_ar",
	grenade		= "walldivel_gren_frag",
	slam		= "walldivel_gren_frag",
	physgun		= "walldivel_ar",
	camera		= "walldivel_pistol",
	magic		= "walldivel_pistol"

};

ActionExtension.AnimationActivity[ ActionExtension.ACTIVITY_ROLL ] = {

	crowbar		= "roll_knife",
	knife		= "roll_knife",
	fist		= "roll_pistol",
	melee		= "roll_knife",
	melee2		= "roll_knife",
	normal		= "roll_ar",
	passive		= "roll_ar",
	pistol		= "roll_pistol",
	revolver	= "roll_revolver",
	duel		= "roll_akimbo",
	smg			= "roll_smg",
	ar2			= "roll_ar",
	shotgun		= "roll_sniper",
	crossbow	= "roll_shotgun",
	rpg			= "roll_ar",
	grenade		= "roll_gren_frag",
	slam		= "roll_gren_frag",
	physgun		= "roll_ar",
	camera		= "roll_pistol",
	magic		= "roll_pistol"

};

ActionExtension.AnimationActivity[ ActionExtension.ACTIVITY_WALL_JUMP ] = {

	crowbar		= "walljump_knife",
	knife		= "walljump_knife",
	fist		= "walljump_pistol",
	melee		= "walljump_knife",
	melee2		= "walljump_knife",
	normal		= "walljump_ar",
	passive		= "walljump_ar",
	pistol		= "walljump_pistol",
	revolver	= "walljump_revolver",
	duel		= "walljump_akimbo",
	smg			= "walljump_smg",
	ar2			= "walljump_ar",
	shotgun		= "walljump_sniper",
	crossbow	= "walljump_shotgun",
	rpg			= "walljump_ar",
	grenade		= "walljump_gren_frag",
	slam		= "walljump_gren_frag",
	physgun		= "walljump_ar",
	camera		= "walljump_pistol",
	magic		= "walljump_pistol"

};