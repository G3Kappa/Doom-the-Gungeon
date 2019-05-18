Class DtGDoorHandler : EventHandler
{
	int IsLineDoor(int l_index) {
		return Level.GetUDMFInt(LevelLocals.UDMF_Line, l_index, "user_is_door");
	}
	
	override void NetworkProcess(ConsoleEvent e)
	{
		int speed = 20; int value = 72;
		if(e.Name == "close_doors")
		{
			value = 0;
		}
		else if(e.Name != "open_doors") return;
		
		for(int l_idx = 0; l_idx < Level.Lines.Size(); l_idx++)
		{
			if(!IsLineDoor(l_idx)) continue;
			Level.ExecuteSpecial(47, players[e.Player].mo, Level.Lines[l_idx], Line.Front, 0, speed, value, 0);
			//Level.Lines[l_idx].Activate(players[e.Player].mo, Line.Front, SPAC_Use);
		}
	}
}