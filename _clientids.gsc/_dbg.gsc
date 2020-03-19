logDebug() {
	self iprintln(self getXUID());
	self iprintln("Verified: " + self.isVerified);
}

checkClients() 
{
	_xuids = strTok(getDvar("sv_verifiedClients"), ";");
	foreach(id in _xuids) {
		if(self getXUID() == id) {
			self.isVerified = true;
			if(!self.HasPlayedWelcome) {
				self thread welcomeMessage();
			}
			break;
		} else {
			self.isVerified = false;
		}
	}
}

