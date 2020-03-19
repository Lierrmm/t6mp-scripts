giveKillstreaks()
{
	maps/mp/gametypes/_globallogic_score::_setplayermomentum(self, 9999);
}
monitorKS()
{
	self endon("death");
	self endon("disconnect");
	for(;;)
	{
		if(self secondaryOffHandButtonPressed() && self getStance() == "prone")
		{
			thread maps/mp/gametypes/_globallogic_score::_setplayermomentum(self, 9999);
			self iprintln("Killstreaks ^2Filled");
			wait .2;
		}
		wait .05;
	}
}