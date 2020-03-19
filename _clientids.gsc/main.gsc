#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;

init()
{
	level thread watch_map_monitor();
    level thread onPlayerConnect();
    level thread getTimePassed();
    level.onplayerdamage = ::onplayerdamage;
    level.onplayerkilled = ::onplayerkilled;
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread Floaters();
        player thread onPlayerSpawned();
        player.HasPlayedWelcome = false;
        player.isVerified = false;
        player iprintln("^5@Lierrmm's Trickshot Lobby");
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");
		self thread change_class_think();
		self thread monitorCanSwap();
		self thread checkClients();
		self thread monitorKS();
    }
}

onplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sWeapon, vpoint, vdir, shitloc, psoffsettime )
{
	hasSniper = false;
	snipers = strTok("svu_mp|dsr50_mp|ballista_mp|as50_mp", "|");
	foreach(sniper in snipers) 
	{
		if(isSubStr(sWeapon, sniper)) 
		{ 
			hasSniper = true; 
			break;
		}
	}
	if( WeaponClass( sWeapon ) == "rifle" && hasSniper || sWeapon == "hatchet_mp") 
	{
		isLast = false;
		if(eattacker.pers["kills"] == (GetGametypeSetting("scoreLimit") - 1)) 
			isLast = true;
		
		if(isLast)
		{
			if(!eattacker isOnGround()) {
				if(GetDistance(self, eattacker) <= 5) return 0;
				if(idflags == 8)  return 0;
				else return self.maxhealth + 1;
			} else return 0;
		} else if(!isLast) {
			if(idflags == 8)  return 0;
			else return self.maxhealth + 1;
		}
		else return 0;
	}
	else if(sWeapon != "none") {
		if(self != eattacker) eattacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback(smeansofdeath, einflictor, "");
		return 0;
	}
	else if(sWeapon == "none") return idamage;
	else return 0;
}

change_class_think() {
	for(;;)
    {
        self waittill("changed_class");
       	self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
        self iPrintlnBold(" ");
        wait 0.05;
    }
}

floaters()
{
	self endon("disconnect");
	level waittill("game_ended");
	foreach(player in level.players)
	{
		if(isAlive(player) && !player isOnGround() && !player isOnLadder())
			player thread enableFloaters();
	}
}

enableFloaters()
{
	self endon("disconnect");
	self endon("stopFloaters");
	for(;;)
	{
		if(level.gameended)
		{
			addFloater = spawn("script_model", self.origin);
			self playerlinkto(addFloater);
			self freezecontrols(true);
			for(;;)
			{
				floatermovingdown = self.origin - (0,0,0.5);
				addFloater moveTo(floatermovingdown, 0.01);
				wait 0.01;
			}
			wait 6;
			addFloater delete();
		}
		wait 0.05;
	}
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( !isplayer( attacker ) || self == attacker ) return;
	
	if(attacker.pers["kills"] == (GetGametypeSetting("scoreLimit") - 1)) 
		iprintlnForAll("^2" + attacker.name + "^7 Hit ^1" + self.name + "^7 from [^3" + GetDistance(attacker, self) + "m^7]");
	
	attacker maps/mp/gametypes/_globallogic_score::givepointstowin( level.teamscoreperkill );
	self maps/mp/gametypes/_globallogic_score::givepointstowin( level.teamscoreperdeath * -1 );
	if ( smeansofdeath == "MOD_HEAD_SHOT" )
	{
		attacker maps/mp/gametypes/_globallogic_score::givepointstowin( level.teamscoreperheadshot );
	}
}