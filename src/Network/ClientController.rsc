module Network::ClientController

import IO;
import DateTime;
import Exception;

import Network::ServerController;

@javaClass{Network.Client}
public java int startClient(str ip, int port);
@javaClass{Network.Client}
public java str sendMessage(str msg);
@javaClass{Network.Client}
public java void stopClient();
@javaClass{Network.Client}
public java tuple[int, int] tester();

void testClient() {
	startClient("127.0.0.1", testport);
	print(sendMessage("ping"));
	stopClient();
}