#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/_scoreevents;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level.tacticalinsertionweapon = "tactical_insertion_mp";
	precachemodel( "t6_wpn_tac_insert_world" );
	loadfx( "misc/fx_equip_tac_insert_light_grn" );
	loadfx( "misc/fx_equip_tac_insert_light_red" );
	level._effect[ "tacticalInsertionFizzle" ] = loadfx( "misc/fx_equip_tac_insert_exp" );
	maps/mp/gametypes/_globallogic_audio::registerdialoggroup( "item_destroyed", 1 );
}

istacspawntouchingcrates( origin, angles )
{
	crate_ents = getentarray( "care_package", "script_noteworthy" );
	mins = ( -17, -17, -40 );
	maxs = ( 17, 17, 40 );
	i = 0;
	while ( i < crate_ents.size )
	{
		if ( crate_ents[ i ] istouchingvolume( origin + vectorScale( ( 0, 0, 1 ), 40 ), mins, maxs ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

overridespawn( ispredictedspawn )
{
	if ( !isDefined( self.tacticalinsertion ) )
	{
		return 0;
	}
	origin = self.tacticalinsertion.origin;
	angles = self.tacticalinsertion.angles;
	team = self.tacticalinsertion.team;
	if ( !ispredictedspawn )
	{
		self.tacticalinsertion destroy_tactical_insertion();
	}
	if ( team != self.team )
	{
		return 0;
	}
	if ( istacspawntouchingcrates( origin ) )
	{
		return 0;
	}
	if ( !ispredictedspawn )
	{
		self.tacticalinsertiontime = getTime();
		self spawn( origin, angles, "tactical insertion" );
		self setspawnclientflag( "SCDFL_DISABLE_LOGGING" );
		self addweaponstat( "tactical_insertion_mp", "used", 1 );
	}
	return 1;
}

waitanddelete( time )
{
	self endon( "death" );
	wait 0.05;
	self delete();
}

watch( player )
{
	if ( isDefined( player.tacticalinsertion ) )
	{
		player.tacticalinsertion destroy_tactical_insertion();
	}
	player thread spawntacticalinsertion();
	self waitanddelete( 0.05 );
}

watchusetrigger( trigger, callback, playersoundonuse, npcsoundonuse )
{
	self endon( "delete" );
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		while ( !isalive( player ) )
		{
			continue;
		}
		while ( !player isonground() )
		{
			continue;
		}
		if ( isDefined( trigger.triggerteam ) && player.team != trigger.triggerteam )
		{
			continue;
		}
		if ( isDefined( trigger.triggerteamignore ) && player.team == trigger.triggerteamignore )
		{
			continue;
		}
		if ( isDefined( trigger.claimedby ) && player != trigger.claimedby )
		{
			continue;
		}
		if ( player usebuttonpressed() && !player.throwinggrenade && !player meleebuttonpressed() )
		{
			if ( isDefined( playersoundonuse ) )
			{
				player playlocalsound( playersoundonuse );
			}
			if ( isDefined( npcsoundonuse ) )
			{
				player playsound( npcsoundonuse );
			}
			self thread [[ callback ]]( player );
		}
	}
}

watchdisconnect()
{
	self.tacticalinsertion endon( "delete" );
	self waittill( "disconnect" );
	self.tacticalinsertion thread destroy_tactical_insertion();
}

destroy_tactical_insertion( attacker )
{
	self.owner.tacticalinsertion = undefined;
	self notify( "delete" );
	self.owner notify( "tactical_insertion_destroyed" );
	self.friendlytrigger delete();
	if ( isDefined( attacker ) && isDefined( attacker.pers[ "team" ] ) && isDefined( self.owner ) && isDefined( self.owner.pers[ "team" ] ) )
	{
		if ( level.teambased )
		{
			if ( attacker.pers[ "team" ] != self.owner.pers[ "team" ] )
			{
				attacker notify( "destroyed_explosive" );
				attacker maps/mp/_challenges::destroyedequipment();
				attacker maps/mp/_challenges::destroyedtacticalinsert();
				maps/mp/_scoreevents::processscoreevent( "destroyed_tac_insert", attacker );
			}
		}
		else
		{
			if ( attacker != self.owner )
			{
				attacker notify( "destroyed_explosive" );
				attacker maps/mp/_challenges::destroyedequipment();
				attacker maps/mp/_challenges::destroyedtacticalinsert();
				maps/mp/_scoreevents::processscoreevent( "destroyed_tac_insert", attacker );
			}
		}
	}
	self delete();
}

fizzle( attacker )
{
	if ( isDefined( self.fizzle ) && self.fizzle )
	{
		return;
	}
	self.fizzle = 1;
	playfx( level._effect[ "tacticalInsertionFizzle" ], self.origin );
	self playsound( "dst_tac_insert_break" );
	if ( isDefined( attacker ) && attacker != self.owner )
	{
		self.owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "tact_destroyed", "item_destroyed" );
	}
	self destroy_tactical_insertion( attacker );
}

pickup( attacker )
{
	player = self.owner;
	self destroy_tactical_insertion();
	player giveweapon( level.tacticalinsertionweapon );
	player setweaponammoclip( level.tacticalinsertionweapon, 1 );
}

spawntacticalinsertion()
{
	self endon( "disconnect" );
	self.tacticalinsertion = spawn( "script_model", self.origin + ( 0, 0, 1 ) );
	self.tacticalinsertion setmodel( "t6_wpn_tac_insert_world" );
	self.tacticalinsertion.origin = self.origin + ( 0, 0, 1 );
	self.tacticalinsertion.angles = self.angles;
	self.tacticalinsertion.team = self.team;
	self.tacticalinsertion setteam( self.team );
	self.tacticalinsertion.owner = self;
	self.tacticalinsertion setowner( self );
	self.tacticalinsertion setweapon( level.tacticalinsertionweapon );
	self.tacticalinsertion thread maps/mp/gametypes/_weaponobjects::attachreconmodel( "t6_wpn_tac_insert_detect", self );
	self.tacticalinsertion endon( "delete" );
	triggerheight = 64;
	triggerradius = 128;
	self.tacticalinsertion.friendlytrigger = spawn( "trigger_radius_use", self.tacticalinsertion.origin + vectorScale( ( 0, 0, 1 ), 3 ) );
	self.tacticalinsertion.friendlytrigger setcursorhint( "HINT_NOICON", self.tacticalinsertion );
	self.tacticalinsertion.friendlytrigger sethintstring( &"MP_TACTICAL_INSERTION_PICKUP" );
	if ( level.teambased )
	{
		self.tacticalinsertion.friendlytrigger setteamfortrigger( self.team );
		self.tacticalinsertion.friendlytrigger.triggerteam = self.team;
	}
	self clientclaimtrigger( self.tacticalinsertion.friendlytrigger );
	self.tacticalinsertion.friendlytrigger.claimedby = self;
	self.tacticalinsertion setclientflag( 2 );
	self thread watchdisconnect();
	watcher = maps/mp/gametypes/_weaponobjects::getweaponobjectwatcherbyweapon( level.tacticalinsertionweapon );
	self.tacticalinsertion thread watchusetrigger( self.tacticalinsertion.friendlytrigger, ::pickup, watcher.pickupsoundplayer, watcher.pickupsound );
	if ( isDefined( self.tacticalinsertioncount ) )
	{
		self.tacticalinsertioncount++;
	}
	else
	{
		self.tacticalinsertioncount = 1;
	}
	self.tacticalinsertion setcandamage( 0 );
	self.tacticalinsertion.health = 1;
	while ( 1 )
	{
		self.tacticalinsertion waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		while ( level.teambased && isDefined( attacker ) && isplayer( attacker ) && attacker.team == self.team && attacker != self )
		{
			continue;
		}
	}
}

cancel_button_think()
{
	if ( !isDefined( self.tacticalinsertion ) )
	{
		return;
	}
	text = cancel_text_create();
	self thread cancel_button_press();
	event = self waittill_any_return( "tactical_insertion_destroyed", "disconnect", "end_killcam", "abort_killcam", "tactical_insertion_canceled", "spawned" );
	if ( event == "tactical_insertion_canceled" )
	{
		self.tacticalinsertion destroy_tactical_insertion();
	}
	if ( isDefined( text ) )
	{
		text destroy();
	}
}

canceltackinsertionbutton()
{
	if ( level.console )
	{
		return self changeseatbuttonpressed();
	}
	else
	{
		return self jumpbuttonpressed();
	}
}

cancel_button_press()
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	self endon( "abort_killcam" );
	while ( 1 )
	{
		wait 0.05;
		if ( self canceltackinsertionbutton() )
		{
			break;
		}
		else
		{
		}
	}
	self notify( "tactical_insertion_canceled" );
}

cancel_text_create()
{
	text = newclienthudelem( self );
	text.archived = 0;
	text.y = -100;
	text.alignx = "center";
	text.aligny = "middle";
	text.horzalign = "center";
	text.vertalign = "bottom";
	text.sort = 10;
	text.font = "small";
	text.foreground = 1;
	text.hidewheninmenu = 1;
	if ( self issplitscreen() )
	{
		text.y = -80;
		text.fontscale = 1.2;
	}
	else
	{
		text.fontscale = 1.6;
	}
	text settext( &"PLATFORM_PRESS_TO_CANCEL_TACTICAL_INSERTION" );
	text.alpha = 1;
	return text;
}

gettacticalinsertions()
{
	tac_inserts = [];
	_a393 = level.players;
	_k393 = getFirstArrayKey( _a393 );
	while ( isDefined( _k393 ) )
	{
		player = _a393[ _k393 ];
		if ( isDefined( player.tacticalinsertion ) )
		{
			tac_inserts[ tac_inserts.size ] = player.tacticalinsertion;
		}
		_k393 = getNextArrayKey( _a393, _k393 );
	}
	return tac_inserts;
}

tacticalinsertiondestroyedbytrophysystem( attacker, trophysystem )
{
	return;
}