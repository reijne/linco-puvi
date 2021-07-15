package Network;

import java.net.*;
import java.io.*;

import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValueFactory;

// Insipiration:: https://www.baeldung.com/a-guide-to-java-sockets
public class Client {
	private final IValueFactory values;
	private Socket clientSocket;
    private PrintWriter out;
    private BufferedReader in;

    // Initialise the Client with the valuefactory (link to Rascal).
    public Client(IValueFactory values){
        this.values = values;
    }
    
    // Start the client by connecting to the ip+port.
    public void  startClient(IString ip, IInteger port) throws IOException {
    	String ipString = ip.getValue();
    	int portInteger = port.intValue();
    	clientSocket = new Socket(ipString, portInteger);
    	out = new PrintWriter(clientSocket.getOutputStream(), true);
    	in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));        
    }
    
    // Send a message to the connected server and return the response.
    public IString sendMessage(IString msg) throws IOException {
		String msgString = msg.getValue();
		out.println(msgString);
//		String resp = in.readLine();
//		return values.string(resp); 
		return values.string("");
    }
    
    // Stop the client by closing the streams and connection.
    public void stopClient() throws IOException {
		in.close();
		out.close();
		clientSocket.close();    		
    }
}