module Network::ClientController

import IO;
import Exception;
import lang::json::IO;

import Network::ServerController;

@javaClass{Network.Client}
public java int startClient(str ip, int port);
@javaClass{Network.Client}
public java str sendMessage(str msg);
@javaClass{Network.Client}
public java void stopClient();

private bool isConnected = false;
private str localhost = "127.0.0.1";
private int showeyPort = 529;
private int sceneyPort = 530;

// Test the Socket Client on the test port (ServerController) by sending Ping
void testClient() {
	startClient(localhost, testport);
	print(sendMessage("ping"));
	stopClient();
}

@doc {
	Stop the Client Socket connection and release it.
}
void safeStopClient() {
	stopClient();
	isConnected = false;
}

@doc {
	Close the Unity Server Socket using close:true
}
void closeServer() {
	sendMessage(remoteCall("", "", true));
}

@doc {
	Start the Client Socket and throw an error if the client already is connected
}
void safeStartClient() {
	if (isConnected) throw IO("Socket connection already exists, close all running apps.");
	startClient(localhost, sceneyPort);
	isConnected = true;
}

@doc {
	Create a Remote Process Call to send over the Socket, using JSON rpc format.
}
str remoteCall(str method, str param, bool close) {
	rpc = ("method": method,
			  "param": param,
			  "close": close);
	return asJSON(rpc);
}

@doc {
	Send a flattened tree representation of a chosen language to create a showey definition.
}
void createShowey(str extractedNodes) {
  	try {
		//safeStartClient();
		startClient(localhost, showeyPort);
		sendMessage(remoteCall("createShowey", extractedNodes, true));
	} catch: {
		createShowey(extractedNodes);
		return;
	}
	safeStopClient();
}

@doc {
	Send an existing showey definition to be loaded into the interface for change.
}
void updateShowey(str serialisedShowDef) {
	try {
		//safeStartClient();
		startClient(localhost, showeyPort);
		sendMessage(remoteCall("updateShowey", serialisedShowDef, true));
	} catch: {
		createShowey(serialisedShowDef);
		return;
	}
	safeStopClient();
}

@doc {
	Send a showeyDefinition to set up the 3D scene
}
void createSceney(str serialisedShowDef) {
	try {
		//safeStartClient();
		startClient(localhost, sceneyPort);
		sendMessage(remoteCall("createSceney", serialisedShowDef, false));
	} catch: {
		createSceney(serialisedShowDef);
		return;
	}
}

@doc {
	Send the current state of the program to the 3D scene.
}
void updateSceney(str labeledTraversal) {
	//if (!isConnected) throw IO("Socket Connection not instantiated but attempting to send the scene");
	sendMessage(remoteCall("updateSceney", labeledTraversal, false));
}

@doc {
	Update all the blocks where an error occurs by spawning an enemy.
}
void updateErrors(str errorline) {
	sendMessage(remoteCall("updateErrors", errorline, false));
}

@doc {
	Update non evaluated branches and spawn collectables at the end.
}
void updateBranches(str branches) {
	sendMessage(remoteCall("updateBranches", branches, false));
}

@doc {
	Update the message in game for a specified duration.
}
void updateMessage(str msg, real duration) {
	str messagePlusDuration = msg + "+<duration>";
	sendMessage(remoteCall("updateMessage", messagePlusDuration, false));
}

@doc {
	Update the specified block to include an enemy.
}
void updateEnemy(int nodeID) {
	sendMessage(remoteCall("updateEnemy", "<nodeID>", false));
}

@doc {
	Update the specified block to fall upon interaction.
}
void updateFalling(int nodeID) {
	sendMessage(remoteCall("updateFalling", "<nodeID>", false));
}

@doc {
	Update the movement type the scene employs. {run, fly}
}
void updateMovement(str movement) {
	sendMessage(remoteCall("updateMovement", "<movement>", false));
}

@doc {
	Update the specified blocky by adding a collectable.
}
void updateCollectable(int nodeID) {
	sendMessage(remoteCall("updateCollectable", "<nodeID>", false));
}

@doc {
	Update the interaction type :: shoot, throw, none.
}
void updateInteraction(str interactionType) {
	sendMessage(remoteCall("updateInteraction", interactionType, false));
}

@doc {
	Update the current highlighted node
}
void updateHighlight(int nodeID) {
	sendMessage(remoteCall("updateHighlight", "<nodeID>", false));
}

@doc {
	Update the sequence of highlighted nodes, with the duration of light.
}
void updateSequence(list[int] sequence, real duration) {
	str s = "";
	for (int id <- sequence) s += "<id>,";
	s = s[..-1] + "+<duration>";
	sendMessage(remoteCall("updateSequence", s, false));
}

@doc {
	Update the path where the highlight file exists.
}
void updateLightfile(str lightfile) {
	sendMessage(remoteCall("updateLightfile", lightfile, false));
}


