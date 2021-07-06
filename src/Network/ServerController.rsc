module Network::ServerController

import IO;
import Exception;

@javaClass{Network.Server}
public java void startServer(int port);
@javaClass{Network.Server}
public java void stopServer();

public int testport = 9999;

void  testServer() {
	try {
		startServer(testport);
	} catch RuntimeException re:  {
		print(re);
		stopServer();
	}
}

void stop() {
	stopServer();
}
