lowestBarriers() {
    hurt_triggers = getentarray( "trigger_hurt", "classname" );
    foreach(thurt in hurt_triggers)
	{
		if(thurt.origin[2] < 180) thurt.origin = (thurt.origin[0], thurt.origin[1], thurt.origin[2] - 980);
	}
}

mediumBarriers() {
	hurt_triggers = getentarray( "trigger_hurt", "classname" );
    foreach(thurt in hurt_triggers)
	{
		if(thurt.origin[2] < 180) thurt.origin = (thurt.origin[0], thurt.origin[1], thurt.origin[2] - 540);
	}
}

moveSkyBarrier() {
hurt_triggers = getentarray( "trigger_hurt", "classname" );
    foreach(thurt in hurt_triggers)
	{
		if(thurt.origin[2] > 180) thurt.origin = (thurt.origin[0], thurt.origin[1], thurt.origin[2] + 9999);
	}
}

watch_map_monitor() {
	mapName = getDvar("mapname");
	switch(mapName) {
		case "mp_bridge":
		case "mp_uplink":
		case "mp_vertigo":
			thread lowestBarriers();
			thread moveSkyBarrier(); 
			break;
		case "mp_socotra":
			thread mediumBarriers();
			thread moveSkyBarrier();
			break;
		default:
			thread moveSkyBarrier();
			break;
	}
}












