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

// Test the Socket Client on the test port (ServerController) by sending Ping
void testClient() {
	startClient("127.0.0.1", testport);
	print(sendMessage("ping"));
	stopClient();
}

void stopper() {
	stopClient();
	isConnected = false;
}

void closeServer() {
	sendMessage(remoteCall("", "", true));
}

void starter() {
	if (Network::ClientController::isConnected) throw IO("Socket connection already exists, close all running apps.");
	startClient("127.0.0.1", 530);
	print("made connection\n");
	isConnected = true;
}

@doc {
	Create a Remote Process Call to send over the Socket, using JSON rpc format.
}
str remoteCall(str method, str param, bool close) {
	rpc = ("method": method,
			  "param": param,
			  "close": close);
	print("created remote call :: <method>\n");
	return asJSON(rpc);
}

@doc {
	Send a flattened tree representation of a chosen language to create a showey definition.
}
void createShowey(str flattenedTree) {
  	try {
		starter();
		sendMessage(remoteCall("createShowey", flattenedTree, true));
	} catch: {
		createShowey(flattenedTree);
		return;
	}
	stopper();
}

@doc {
	Send an existing showey definition to be loaded into the interface for change.
}
void updateShowey(str serialisedShowDef) {
	try {
		starter();
		sendMessage(remoteCall("updateShowey", serialisedShowDef, true));
	} catch: {
		createShowey(serialisedShowDef);
		return;
	}
	stopper();
}

@doc {
	Send a showeyDefinition to set up the 3D scene
}
void createSceney(str serialisedShowDef) {
	try {
		starter();
		sendMessage(remoteCall("createSceney", serialisedShowDef, false));
		print("sent RPC:: createSceney\n");
	} catch: {
		createSceney(serialisedShowDef);
		return;
	}
}

@doc {
	Send the current state of the program to the 3D scene.
}
void updateSceney(str labeledTraversal) {
	if (!isConnected) throw IO("Socket Connection not instantiated but attempting to send the scene");
	sendMessage(remoteCall("updateSceney", labeledTraversal, false));
	print("sent RPC:: updateSceney\n");
}

