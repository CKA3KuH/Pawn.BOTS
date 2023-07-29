#include a_samp
#include ../include/dialogs
#include ../include/foreach
#include ../include/pawnraknet

native PB_RegisterBot(name[]);

#define MAX_NAME 		(4096)
#define MAX_ADMIN 		(32)
#define MAX_LVL 		(128)
#define MAX_PING 		(128)
#define MAX_COLOR 		(128)

new Iterator:fNickC<MAX_NAME>;

new gSlotCount;
new gRealCount;
new gFakeCount;
new gNickCount;
new gPingCount;
new gScoreCount;
new gColorCount;
new gAdminCount;
new gTickCheckSl;
new gTimerDelay;
new gTimerDCount;
new gTimerDLRand;
new gTimerMaxTick;
new gTimerLastTick;

new gSetting;
new gAtHour[24];
new gLvl[MAX_LVL];
new gPing[MAX_PING];
new gColor[MAX_COLOR];
new gNick[MAX_NAME][25];
new gAdmin[MAX_ADMIN][25];
new gNickC[MAX_NAME char];
new gNickCplId[MAX_NAME] = {-1, ...};

new playerLvl[MAX_PLAYERS];
new playerPing[MAX_PLAYERS];
new playerColor[MAX_PLAYERS];
new playerPBot[MAX_PLAYERS];
new playerNick[MAX_PLAYERS][25];
new playerSetList[MAX_PLAYERS char];
new playerRakNetScore[MAX_PLAYERS];
new playerRakNetPing[MAX_PLAYERS];

stock GetTickDiff(newtick, oldtick)
{
	if(oldtick >= 0 && newtick < 0 || oldtick > newtick) return ((cellmax - oldtick + 1) - (cellmin - newtick));
	return (newtick - oldtick);
}

stock CompareText(string1[], string2[])
{
	new id = strcmp(string1, string2);
    if(id != 0) return id;
	if(string1[0] && string2[0]) return 0;
	return 255;
}

stock HexToInt(string[])
{
   	new curent = 1, result = 0;
   	for(new i = (strlen(string) - 1); i >= 0; i--)
 	{
  		if(string[i] < 58) result = (result + curent * (string[i] - 48));
  		else result = (result + curent * (string[i] - 65 + 10));
     	curent = curent*16;
   	}
   	return result;
}

stock ShowSetting0(playerid)
{
    new string0[60] = "{FFFFFF}", string1[70] = "{FFFFFF}Ubacivanje botova: ";
	strcat(string1, (gSetting) ? ("{00CC00}Ukljuceno") : ("{FF6600}Iskljuceno"));
	strcat(string0, (gSetting) ? ("Iskljuci") : ("Ukljuci"));
	strcat(string0, "\nIzbaci sve botove\nBroj botova po satu\nInformacije");
	ShowPlayerDialog(playerid, 4460, DIALOG_STYLE_LIST, string1, string0, !"Odaberi", !"Odustani");
	return 1;
}

stock ShowSetting1(playerid)
{
	new string[320] = "{FFFFFF}";
    for(new i; i < 24; i++) format(string, sizeof(string), "%s%i:00 - %i\n", string, i, gAtHour[i]);
	ShowPlayerDialog(playerid, 4461, DIALOG_STYLE_LIST, "{FFFFFF}Broj botova po satu", string, !"Odaberi", !"Odustani");
	return 1;
}

stock LoadSetting()
{
	new File:id, count, string[25];
	id = fopen("pawnbots/setting.ini", io_read);
	if(!id)
	{
		print("[PB] fajl 'setting.ini' greska");
		return 0;
	}
	fread(id, string, sizeof(string));
	gSetting = strval(string);
	fclose(id);

	id = fopen("pawnbots/online.ini", io_read);
	if(!id)
	{
		print("[PB] fajl 'online.ini' greska");
		return 0;
	}
	count = 0;
	while(fread(id, string, sizeof(string)))
	{
		if(++count > 24) break;
		gAtHour[count - 1] = (strval(string) > (gSlotCount - 1)) ? (gSlotCount - 1) : strval(string);
	}
	fclose(id);
	
	id = fopen("pawnbots/score.ini", io_read);
	if(!id)
	{
		print("[PB] fajl 'score.ini' greska");
		return 0;
	}
	count = 0;
	while(fread(id, string, sizeof(string)))
	{
	    if(++count > MAX_LVL) break;
		gLvl[count - 1] = strval(string);
	}
	gScoreCount = count;
	fclose(id);

	id = fopen("pawnbots/ping.ini", io_read);
	count = 0;
	if(!id)
	{
		print("[PB] fajl 'ping.ini' greska");
		return 0;
	}
	while(fread(id, string, sizeof(string)))
	{
		if(++count > MAX_PING) break;
		gPing[count - 1] = strval(string);
	}
	gPingCount = count;
	fclose(id);

	id = fopen("pawnbots/color.ini", io_read);
	if(!id)
	{
		print("[PB] fajl 'color.ini' greska");
		return 0;
	}
	count = 0;
	while(fread(id, string, sizeof(string)))
	{
	    if(++count > MAX_COLOR) break;
	    for(new i = (strlen(string) - 1); i >= 0; i--) switch(string[i])
	    {
	        case 'A'..'Z', 'a'..'z', '0'..'9': {}
	        default: strdel(string, i, (i + 1));
	    }
		gColor[count - 1] = HexToInt(string[2]);
	}
	gColorCount = count;
	fclose(id);

	id = fopen("pawnbots/nick.ini", io_read);
	if(!id)
	{
		print("[PB] fajl 'nick.ini' greska");
		return 0;
	}
	count = 0;
	while(fread(id, string, sizeof(string)))
	{
	    if(++count > MAX_NAME) break;
	    for(new i = (strlen(string) - 1); i >= 0; i--) switch(string[i])
	    {
	        case 'A'..'Z', 'a'..'z', '0'..'9', '_': {}
	        default: strdel(string, i, (i + 1));
	    }
		strmid(gNick[count - 1], string, 0, strlen(string), 25);
	}
	gNickCount = count;
	fclose(id);

	id = fopen("pawnbots/admin.ini", io_read);
	if(!id)
	{
		print("[PB] fajl 'admin.ini' greska");
		return 0;
	}
	count = 0;
	while(fread(id, string, sizeof(string)))
	{
	    if(++count > MAX_ADMIN) break;
	    for(new i = (strlen(string) - 1); i >= 0; i--) switch(string[i])
	    {
	        case 'A'..'Z', 'a'..'z', '0'..'9', '_': {}
	        default: strdel(string, i, (i + 1));
	    }
		strmid(gAdmin[count - 1], string, 0, strlen(string), 25);
	}
	gAdminCount = count;
	fclose(id);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(!CompareText(text, ".pbots")) { switch(GetPlayerState(playerid))
 	{
	    case PLAYER_STATE_NONE, PLAYER_STATE_WASTED, PLAYER_STATE_SPECTATING: {}
		default: { for(new i = (gAdminCount - 1); i >= 0; i--) if(!CompareText(playerNick[playerid], gAdmin[i]))
		{
			ShowSetting0(playerid);
			return 0;
		}}
	}}
	return 1;
}

DLG(4463, playerid, response, listitem, inputtext[])
{
	ShowSetting0(playerid);
	return 1;
}
DLG(4460, playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
	switch(listitem)
	{
	    case 0:
	    {
	        gSetting = !gSetting;
	        new File:id = fopen("pawnbots/setting.ini", io_write);
			if(!id)
			{
				print("[PB] fajl 'setting.ini' greska");
				return 1;
			}
		 	new string[4];
		 	valstr(string, gSetting);
			fwrite(id, string);
			fclose(id);
			ShowSetting0(playerid);
	    }
	    case 1:
	    {
	        gSetting = 0;
	        for(new i = (gSlotCount - 1); i >= 0; i--) { if(playerPBot[i] != -1) Kick(i); }
         	LoadSetting();
         	gSetting = 1;
         	ShowSetting0(playerid);
	    }
	    case 2: ShowSetting1(playerid);
		case 3:
		{
			new string[136];
			format(string, sizeof(string), "Last tick: %ims.\nMax tick: %ims.\nBroj igraca: %i\nBroj botova: %i", gTimerLastTick, gTimerMaxTick, gRealCount, gFakeCount);
		    ShowPlayerDialog(playerid, 4463, DIALOG_STYLE_MSGBOX, !"Informacije", string, !"OK", "");
		}
	}
	return 1;
}
DLG(4461, playerid, response, listitem, inputtext[])
{
    if(!response || listitem < 0 || listitem > 24)
	{
		ShowSetting0(playerid);
		return 1;
	}
    playerSetList{playerid} = listitem;
    new string[14] = "{FFFFFF}";
	valstr(string, listitem);
	strcat(string, ":00");
    ShowPlayerDialog(playerid, 4462, DIALOG_STYLE_INPUT, string, "{FFFFFF}", !"Odaberi", !"Odustani");
    return 1;
}
		
DLG(4462, playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		ShowSetting1(playerid);
		return 1;
	}
	new list = playerSetList{playerid}, vall = strval(inputtext);
	if(!strlen(inputtext) || vall < 0 || vall > (gSlotCount - 1))
	{
	    new string[14] = "{FFFFFF}";
		valstr(string, list);
		strcat(string, ":00");
		ShowPlayerDialog(playerid, 4462, DIALOG_STYLE_INPUT, string, "{FFFFFF}", !"Odaberi", !"Odustani");
		return 1;
	}
	for(new i = (strlen(inputtext) - 1); i >= 0; i--) if(inputtext[i] < '0' || inputtext[i] > '9')
    {
        new string[14] = "{FFFFFF}";
		valstr(string, list);
		strcat(string, ":00");
		ShowPlayerDialog(playerid, 4462, DIALOG_STYLE_INPUT, string, "{FFFFFF}", !"Odaberi", !"Odustani");
		return 1;
	}
	gAtHour[list] = vall;
	ShowSetting1(playerid);
	new File:id = fopen("pawnbots/online.ini", io_write);
	if(!id)
	{
		print("[PB] fajl 'online.ini' greska");
		return 1;
	}
 	new string[122];
    for(new i; i < 24; i++) format(string, sizeof(string), "%s%i\n", string, gAtHour[i]);
	fwrite(id, string);
	fclose(id);
	return 1;
}

public OnPlayerConnect(playerid)
{
    playerPBot[playerid] = -1;
    GetPlayerName(playerid, playerNick[playerid], 25);
    
    new id = -1;
    foreach(fNickC, slot) if(!CompareText(playerNick[playerid], gNick[slot])) { id = slot; break; }
    if(id != -1)
	{
	    gNickCplId[id] = playerid;
	    playerPBot[playerid] = id;
		playerLvl[playerid] = gLvl[random(gScoreCount)];
		playerPing[playerid] = gPing[random(gPingCount)];
		playerColor[playerid] = gColor[random(gColorCount)];
	}
	else gRealCount++;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new id = playerPBot[playerid];
	if(id != -1)
	{
	    gFakeCount--;
		gNickC{id} = 0;
		gNickCplId[id] = -1;
		Iter_Remove(fNickC, id);
	}
	else gRealCount--;
	return 1;
}

public OnFilterScriptInit()
{
    gSlotCount = GetMaxPlayers();
    Iter_Clear(fNickC);
    if(LoadSetting()) SetTimer("OnPBotUpdate", 2000, 1);
 	return 1;
}

public OnFilterScriptExit()
{
    for(new i = (gSlotCount - 1); i >= 0; i--) { if(playerPBot[i] != -1) Kick(i); }
	return 1;
}

forward IsPlayerPBot(playerid);
public IsPlayerPBot(playerid) return (playerPBot[playerid] != -1);

forward OnPBotCheckNick(s, nick[]);
public OnPBotCheckNick(s, nick[])
{
	if(!IsPlayerConnected(gNickCplId[s]) || CompareText(playerNick[gNickCplId[s]], gNick[s])) { if(Iter_Contains(fNickC, s))
	{
	    gFakeCount--;
		gNickC{s} = 0;
		gNickCplId[s] = -1;
		Iter_Remove(fNickC, s);
		printf("[PB] greska busy nick '%s'", gNick[s]);
	}}
	return 1;
}

forward OnPBotUpdate();
public OnPBotUpdate()
{
	new tick = GetTickCount();
	if(++gTickCheckSl >= 5)
	{
	    gTickCheckSl = 0;
		foreach(fNickC, slot) { if(!IsPlayerConnected(gNickCplId[slot])) SetTimerEx("OnPBotCheckNick", 15000, 0, "is", slot, gNick[slot]); }
	}
	new string[136];
	foreach(Player, playerid)
	{
		if(playerPBot[playerid] != -1)
		{
			SetPlayerScore(playerid, playerLvl[playerid]);
			SetPlayerColor(playerid, playerColor[playerid]);
			continue;
		}
		if(IsDialogOpen(playerid, 4463))
		{
			format(string, sizeof(string), "Last tick: %ims.\nMax tick: %ims.\nBroj igraca: %i\nBroj botova: %i", gTimerLastTick, gTimerMaxTick, gRealCount, gFakeCount);
		    ShowPlayerDialog(playerid, 4463, DIALOG_STYLE_MSGBOX, "{FFFFFF}Informacije", string, !"OK", "");
   		}
	}
	if(gTimerDelay) gTimerDelay--;
	else { if(gSetting)
	{
		new hour, count, id = -1, botcount = Iter_Count(fNickC);
		gettime(hour);
		if(gAtHour[hour] < botcount && botcount)
		{
			while(!gNickC{(id = random(gNickCount))}) if(++count >= 20)
			{
				for(new i = (gNickCount - 1); i >= 0; i--) if(gNickC{i}) { id = i; break; }
				break;
			}
			if(id != -1) { for(new i = (gSlotCount - 1); i >= 0; i--) if(playerPBot[id] != -1) { if(!CompareText(gNick[id], playerNick[i])) Kick(i); }}
		}
		if(gAtHour[hour] > botcount && botcount < gNickCount && (gFakeCount + gRealCount) < (gSlotCount - 1))
		{
			while(gNickC{(id = random(gNickCount))}) if(++count >= 20)
			{
				for(new i = (gNickCount - 1); i >= 0; i--) if(!gNickC{i}) { id = i; break; }
				break;
			}
			if(id != -1)
			{
			    gFakeCount++;
			    gNickC{id} = 1;
			    Iter_Add(fNickC, id);
				PB_RegisterBot(gNick[id]);
				ConnectNPC(gNick[id], "pawnbots");
			}
		}
		if(++gTimerDCount >= gTimerDLRand)
	    {
	        gTimerDelay = (5 + random(6));
	        gTimerDLRand = (2 + random(3));
	        gTimerDCount = 0;
		}
	}}
	new diff = GetTickDiff(GetTickCount(), tick);
	gTimerLastTick = diff;
	if(diff > gTimerMaxTick) gTimerMaxTick = diff;
	return 1;
}

ORPC:155(playerid, BitStream:bs)
{
	new bytes;
	BS_GetNumberOfBytesUsed(bs, bytes);
	for(new i = (bytes / 10) - 1; i >= 0; i--)
	{
	    new otherid, score, ping;
		BS_ReadValue(bs, PR_UINT16, otherid, PR_INT32, score, PR_UINT32, ping);
		if(!IsPlayerConnected(otherid)) continue;
		playerRakNetScore[otherid] = score;
		playerRakNetPing[otherid] = ping;
	}
	new BitStream:stream = BS_New();
	foreach(Player, otherid)
	{
		if(playerPBot[otherid] == -1) BS_WriteValue(stream, PR_UINT16, otherid, PR_INT32, playerRakNetScore[otherid], PR_UINT32, playerRakNetPing[otherid]);
		else BS_WriteValue(stream, PR_UINT16, otherid, PR_INT32, playerLvl[otherid], PR_UINT32, (playerPing[otherid] + random(10)));
	}
	BS_RPC(stream, playerid, 155, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(stream);
	return 0;
}
