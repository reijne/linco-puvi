package Network;

import java.net.*;
import java.io.*;

import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IValueFactory;

// Inspiration:: https://www.baeldung.com/a-guide-to-java-sockets
public class Server {
//	private final IValueFactory values;
	private ServerSocket serverSocket;
    private Socket clientSocket;
    private PrintWriter out;
    private BufferedReader in;

    // Initialise the server class using the IValueFactory (linking Rascal).
    public Server(IValueFactory values){
//        this.values = values;
    }

    // Start the server on port, listening for "ping"  to send back "pong".
    public void startServer(IInteger port) throws IOException {
    	int portInteger = port.intValue();
        serverSocket = new ServerSocket(portInteger);
        clientSocket = serverSocket.accept();
        out = new PrintWriter(clientSocket.getOutputStream(), true);
        in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
        String incom = in.readLine();
        String response = incom.equals("ping") ? "pong" : "noPong" ;
        out.println(response);
    }

    // Stop the server by closing the streams and the connection.
    public void stopServer() throws IOException {
        in.close();
        out.close();
        clientSocket.close();
        serverSocket.close();
    }
}