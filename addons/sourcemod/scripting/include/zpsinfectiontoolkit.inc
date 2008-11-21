/********************************************** 
** ZPS Infection Toolkit
** by Dr Rambone Murdoch PhD
**
** Visit the West Coast Zombie Hideout
**
*/
#if defined _zpsinfectiontoolkit_included
 #endinput
#endif
#define _zpsinfectiontoolkit_included

native Float:ZIT_InfectPlayerInXSeconds(ent, Float:seconds);
native ZIT_DisinfectPlayer(ent);
native bool:ZIT_PlayerIsInfected(player);
native Float:ZIT_GetPlayerTurnTime(player);
