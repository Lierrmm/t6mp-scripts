monitorCanSwap() {
	self endon("disconnect");
	self endon("death");
	for(;;) {
		if(self actionslottwobuttonpressed()) {
			self thread dropCanSwap();
		}
		wait 0.05;
	}
	wait 0.05;
}

dropCanSwap()
{
	weapon = randomGun();
	self giveWeapon(weapon, 0, true);
	self dropItem(weapon);
}

randomGun()
{
	self.gun = "";
	while(self.gun == "")
	{
		id = random(level.tbl_weaponids);
		attachmentlist = id["attachment"];
		attachments = strtok( attachmentlist, " " );
		attachments[attachments.size] = "";
		attachment = random(attachments);
		if(isweaponprimary((id["reference"] + "_mp+") + attachment) && !checkGun(id["reference"] + "_mp+" + attachment))
			self.gun = (id["reference"] + "_mp+") + attachment;
		wait 0.1;
		return self.gun;
	}
   wait 0.1;
}

checkGun(weap)
{
	self.allWeaps = [];
	self.allWeaps = self getWeaponsList();
	foreach(weapon in self.allWeaps)
	{
		if(isSubStr(weapon, weap))
			return true;
	}
	return false;
}

getTimePassed() {
	self.timePassed = 0;
	self endon("disconnect");
	level endon( "game_ended" );
	for(;;)
	{
		self.timePassed++;
		updateMatchBonus();
		wait 1;
	}
}

updateMatchBonus()
{
	timeLimit = getDvar("scr_" + getDvar("g_gametype") + "_timelimit");
	maxMatchBonus = timeLimit * (61 / 12);
	if (getDvar("g_gametype") == "sd")
	{
		level.timeLeft = timeLimit - timePassed;
		self.MBAmmount = floor((self.timePassed)*(((self.pers["rank"] + 1)+6)/12));
		if(self.MBAmmount > maxMatchBonus)
		self.MBAmmount = maxMatchBonus;
	}
	foreach(player in level.players)
		player.matchbonus = level.MBAmmount;
}