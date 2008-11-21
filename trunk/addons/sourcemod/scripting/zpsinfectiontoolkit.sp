/***********************************************
** Zombie Panic:Source Infection Tool Kit
** 	by DR RAMBONE MURDOCH PHD
**
**  Visit the West Coast Zombie Hideout
**
*
Adds the following natives for use in your plugins:
	Float:ZIT_InfectPlayerInXSeconds(ent, Float:seconds)
	ZIT_DisinfectPlayer(ent)
	bool:ZIT_PlayerIsInfected(player)
	Float:ZIT_GetPlayerTurnTime(player)

Provides the following console commands:
	zie_infectplayer <playerid> <time to infection in seconds>
	zie_disinfectplayer <playerid>
	zie_checkup <playerid>
*/
#include <logging>
#include <helpers>
#include <zpsinfectiontoolkit>

#define LIN_INFECTION_TIME_OFFSET_V13 5036
#define WIN_INFECTION_TIME_OFFSET_V13 4960
#define LIN_INFECTION_TIME_OFFSET 5052
#define WIN_INFECTION_TIME_OFFSET 4976
#define INFECTION_TIME_OFFSET LIN_INFECTION_TIME_OFFSET

new g_InfectionTimeOffset = 0;


public Plugin:myinfo = {
	name = "Zombie Panic:Source Infection Toolkit",
	author = "Dr. Rambone Murdoch PhD",
	description = "Basic infection controls",
	version = "1.4.1",
	url = "http://rambonemurdoch.blogspot.com/"
}	

public bool:AskPluginLoad(Handle:myself, bool:late, String:error[], err_max) {
	CreateNative("ZIT_InfectPlayerInXSeconds", Native_InfectPlayerInXSeconds);
	CreateNative("ZIT_DisinfectPlayer", Native_DisinfectPlayer);
	CreateNative("ZIT_PlayerIsInfected", Native_PlayerIsInfected);
	CreateNative("ZIT_GetPlayerTurnTime", Native_GetPlayerTurnTime);
	return true;
}

public OnPluginStart() {
	LoadTranslations("common.phrases")
	if(!LoadConfig())
		LogError("Couldn't load ZIT config!");
	// zie_infectplayer <playerid> <time to infection in seconds>
	RegAdminCmd(
		"zit_infectplayer", onCmdInfectPlayer, ADMFLAG_GENERIC,
		"Infect a player in x seconds"
	);
	// zie_disinfectplayer <playerid>
	RegAdminCmd(
		"zit_disinfectplayer", onCmdDisinfectPlayer, ADMFLAG_GENERIC,
		"Disinfect a player"
	);
	RegAdminCmd(
		"zit_checkup", onCmdCheckup, ADMFLAG_GENERIC,
		"See if a player is infected, and how long until they turn. Output is to your chat."
	);
}

bool:LoadConfig() {
	new Handle:hKv = CreateKeyValues("ZIT");
	decl String:filename[PLATFORM_MAX_PATH];
	decl String:platform[16];
	BuildPath(Path_SM, filename, sizeof(filename), "configs/zpsinfectiontoolkit.cfg");
	if(!FileToKeyValues(hKv, filename))
		return false;

	if(!KvGotoFirstSubKey(hKv))
		return false;
	
	// TODO: Is there some more sourcemod-y way to get platform?
	KvGetString(hKv, "platform", platform, sizeof(platform));
	if(StrEqual(platform, ""))
		return false;
	g_InfectionTimeOffset = KvGetNum(hKv, platform);
	CloseHandle(hKv);
	
	return g_InfectionTimeOffset > 0;
}

/** Console Commands **********************************************/

public Action:onCmdCheckup(client, args) {
	new String:buf[3];
	new ent;
	GetCmdArg(1, buf, sizeof(buf));
	ent = FindTarget(client, buf);
	if(ent == -1)
		return Plugin_Handled;
	if(!(IsClientInGame(ent) && IsPlayerAlive(ent)))
		return Plugin_Handled;
	if(ZIT_PlayerIsInfected(ent)) {
		new Float:countdown = ZIT_GetPlayerTurnTime(ent) - GetGameTime();
		PrintToConsole(client, "Player is infected, turning in %f seconds", countdown);
	} else {
		PrintToConsole(client, "Player is not infected");
	}
	return Plugin_Handled;
}

public Action:onCmdDisinfectPlayer(client, args) {
	new String:buf[3];
	new ent;
	GetCmdArg(1, buf, sizeof(buf));
	ent = FindTarget(client, buf);
	if(ent == -1)
		return Plugin_Handled;
	ZIT_DisinfectPlayer(ent);
	return Plugin_Handled;
}

public Action:onCmdInfectPlayer(client, args) {
	new String:buf[10];
	new ent;
	new Float:seconds;
	GetCmdArg(1, buf, sizeof(buf));
	ent = FindTarget(client, buf);
	if(ent == -1) 
		return Plugin_Handled;
	PrintToChat(client, "Infecting %d", ent);
	if(args == 2) {
		GetCmdArg(2, buf, sizeof(buf));
		seconds = StringToFloat(buf);
	} else { 
		PrintToChat(client, "No time set, infection takes hold immediately", buf);
		seconds = 0.0;
	}
	ZIT_InfectPlayerInXSeconds(ent, seconds);
	return Plugin_Handled;
}

/** Natives ********************************************************/

// Player will immediately become infected, turning into a zombie after <seconds> time
public Native_InfectPlayerInXSeconds(Handle:plugin, numParams) {
	new playerEnt = GetNativeCell(1);
	new Float:seconds = Float:GetNativeCell(2)
	if(!(IsClientInGame(playerEnt) && IsPlayerAlive(playerEnt)))
		return _:0.0;

	new Float:turnTime = GetGameTime() + seconds; // time of zombification
	SetEntData(playerEnt, g_InfectionTimeOffset, turnTime)
	SetEntData(
		playerEnt, 
		FindSendPropInfo("CHL2MP_Player","m_IsInfected"), 
		1
	); 
	return _:turnTime;
}

public Native_DisinfectPlayer(Handle:plugin, numParams) {
	new playerEnt = GetNativeCell(1);
	if(!(IsClientInGame(playerEnt) && IsPlayerAlive(playerEnt)))
		return;
	SetEntData(
		playerEnt, 
		FindSendPropInfo("CHL2MP_Player","m_IsInfected"),
		0
	);
}

public Native_PlayerIsInfected(Handle:plugin, numParams) {
	new playerEnt = GetNativeCell(1);
	return _:(
		0 < GetEntData(
			playerEnt, 
			FindSendPropInfo("CHL2MP_Player","m_IsInfected")
		)
	);
}

public Native_GetPlayerTurnTime(Handle:plugin, numParams) { 
	new playerEnt = GetNativeCell(1);
	return _:GetEntDataFloat(playerEnt, g_InfectionTimeOffset);
}

