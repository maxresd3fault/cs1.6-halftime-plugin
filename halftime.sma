#include <amxmodx>
#include <cstrike>
#include <fun>
#include <orpheu>
#include <orpheu_memory>

#define PLUGIN "Halftime"
#define VERSION "1.0"
#define AUTHOR "maxresdefault"

#define SCORE_T 0
#define SCORE_CT 1

#define set_mp_pdata(%1,%2)  ( OrpheuMemorySetAtAddress( g_pGameRules, %1, 1, %2 ) )

new roundNumber = 0;
new cvar_swapAtRound;
new cvar_announceSwap;

new g_pGameRules;
new g_TeamScore[2];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_logevent( "roundEnd", 2, "1=Round_End" );
	register_event("TeamScore", "eventTeamScore", "a");
	cvar_swapAtRound = register_cvar( "amx_halftime_at_round", "16" ); // The swap will occur on the start of the round number specified here. Ex. set to 16 for a 30 round game.
	cvar_announceSwap = register_cvar("amx_announce_swap", "1"); // Enable or disable last round of half message.
}

public plugin_precache()
{
	OrpheuRegisterHook( OrpheuGetFunction( "InstallGameRules" ), "onInstallGameRules", OrpheuHookPost );
}

public onInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
}

public roundEnd()
{
	new players[32], num;
	get_players( players, num );
	
	if( num >= 2 || roundNumber > 0 ) // Don't start counting rounds until at least 2 people join and the game starts.
	{
		roundNumber++;
	}
	
	if( roundNumber == get_pcvar_num( cvar_swapAtRound ) )
	{	
		for( new i; i < num; i++ )
		{
			addDelay( players[i] );
		}
		set_task( 4.5, "swapTeamScore", roundNumber);
	}
	if( get_pcvar_num( cvar_announceSwap ) == 1 && roundNumber == get_pcvar_num( cvar_swapAtRound ) - 1 )
	{
		set_task( 5.0, "announceSwap", roundNumber); // Wait 5 seconds until the next round starts to send the annoucement.
	}
}

public announceSwap()
{
	client_print(0, print_chat, "[AMX Mod X Halftime]: Last round in the half.");
}

public addDelay( id ) // Prevent server crash with lots of clients.
{
	switch( id )
	{
		case 1..7: set_task( 0.1, "changeTeam", id );
		case 8..15: set_task( 0.2, "changeTeam", id );
		case 16..23: set_task( 0.3, "changeTeam", id );
		case 24..32: set_task( 0.4, "changeTeam", id );
	}
	set_task( 4.6, "resetWeapons", id ); // The 4.6 second delay is just enough time to kill still alive players before the next round of the new half starts.
	set_task( 5.0, "resetMoney", id );
}

public changeTeam( id )
{
	switch( cs_get_user_team( id ) )
	{
		case CS_TEAM_CT: cs_set_user_team( id, CS_TEAM_T );
		
		case CS_TEAM_T: cs_set_user_team( id, CS_TEAM_CT );
	}
}

public resetMoney()
{
	new players[32], num;
	get_players( players, num );
	
	for( new i; i < num; i++ )
	{
		cs_set_user_money( players[i], get_cvar_num("mp_startmoney") );
	}
}

public resetWeapons()
{
	new players[32], num;
	get_players( players, num );
	
	for( new i; i < num; i++ )
	{
		if( is_user_alive(players[i]) == 1 )
		{
			cs_set_user_deaths( players[i], ( get_user_deaths(players[i]) - 1 ) );
			set_user_frags( players[i], ( get_user_frags(players[i]) + 1 ) ); // Add a frag because the kill counts as a suicide and will remove a frag.
			user_kill( players[i] ); // Best way to reset player weapons without more Orpheu tomfuckery is to kill them.
		}
	}
}

public eventTeamScore() // Using stock AMX to read current team scores after each round.
{
	new sTeam[2];
	read_data(1, sTeam, 1);
	if( sTeam[0] == 'T' )
	{
		g_TeamScore[SCORE_T] = read_data(2);
	}
	else
	{
		g_TeamScore[SCORE_CT] = read_data(2);
	}
    
	return PLUGIN_CONTINUE;
}

public swapTeamScore() // Using Orpheu to update memory values for team scores.
{                
	set_mp_pdata( "m_iNumCTWins", g_TeamScore[SCORE_T] );
	set_mp_pdata( "m_iNumTerroristWins", g_TeamScore[SCORE_CT] );
}
