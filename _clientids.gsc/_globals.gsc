iprintlnForAll(str) {
	foreach(player in level.players) {
		player iprintln(str);
	}
}

welcomeMessage()
{
	notifyData = spawnstruct();
	notifyData.titleText = "Welcome " + self.name;
	notifyData.notifyText = "Your Status Is VIP";
	notifyData.glowColor = (0.518, 0.012, 0.988);
	notifyData.duration = 8; 
	notifyData.font = "objective"; 
	notifyData.hideWhenInMenu = false;
	self thread maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
	self.HasPlayedWelcome = true;
}