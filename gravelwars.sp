#include <sourcemod>
#include <tf2_stocks>
#include <socket>
// ^ tf2_stocks.inc itself includes sdktools.inc and tf2.inc

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

Handle socket;

public Plugin myinfo = 
{
	name = "Gravel Wars",
	author = "Hagvan",
	description = "Gravel Wars plugin for servers",
	version = PLUGIN_VERSION,
	url = "gravelwars.tf"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// No need for the old GetGameFolderName setup.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("This plugin was made for use with Team Fortress 2 only.");
	}
} 

public void OnPluginStart()
{
	/**
	 * @note For the love of god, please stop using FCVAR_PLUGIN.
	 * Console.inc even explains this above the entry for the FCVAR_PLUGIN define.
	 * "No logic using this flag ever existed in a released game. It only ever appeared in the first hl2sdk."
	 */
	CreateConVar("sm_pluginnamehere_version", PLUGIN_VERSION, "Standard plugin version ConVar. Please don't change me!", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "127.0.0.1", 8000);
	RegServerCmd("sendtest", SendTest);
	RegServerCmd("shorttest", ShortTest);
	RegServerCmd("longtest", LongTest);
}

public void OnMapStart()
{
	/**
	 * @note Precache your models, sounds, etc. here!
	 * Not in OnConfigsExecuted! Doing so leads to issues.
	 */
}

public void OnSocketConnected(Handle s, any arg) {
	PrintToServer("Socket connected!");
}

public void OnSocketError(Handle s, int errorType, int errorNum, any arg) {
    PrintToServer("Socket error: %d %d", errorType, errorNum);
}

public void OnSocketDisconnected(Handle s, any data) {
    PrintToServer("Socket disconnected.");
}

public void OnSocketReceive(Handle s, char[] receiveData, int sz, any hFile)
{
    PrintToServer("Received from socket:\n%s", receiveData);
    /*if (StrContains(receiveData, "HTTP/1.1 101 Switching Protocols", true) == 0)
    {
        char acceptKey[29];
        Format(acceptKey, 29, "%s", receiveData[StrContains(receiveData, "Sec-WebSocket-Accept: ", true) + 22]);
        PrintToServer("ACCEPT-KEY: %s", acceptKey);
    }*/
}

public Action SendTest(int args) {
    char full[2048];
    GetCmdArgString(full, sizeof(full));
    int length = strlen(full);
    full[length] = '\n';
    SocketSend(socket, full, strlen(full));
}

public Action ShortTest(int args) {
    SocketSend(socket, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
}

public Action LongTest(int args) {
    SocketSend(socket, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
}
//SocketSend(socket, sendBuffer);