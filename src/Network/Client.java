package Network;

import java.net.*;
import java.io.*;

import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.ITuple;
import io.usethesource.vallang.IValueFactory;

// Insipiration:: https://www.baeldung.com/a-guide-to-java-sockets
public class Client {
	private final IValueFactory values;
	private Socket clientSocket;
    private PrintWriter out;
    private BufferedReader in;

    public Client(IValueFactory values){
        this.values = values;
    }

    public ITuple tester() {
        return values.tuple(values.integer(2), values.integer(2));
    }
    
    public void  startClient(IString ip, IInteger port) throws IOException {
    	String ipString = ip.getValue();
    	int portInteger = port.intValue();
    	clientSocket = new Socket(ipString, portInteger);
    	out = new PrintWriter(clientSocket.getOutputStream(), true);
    	in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));        
    }
    
    public IString sendMessage(IString msg) throws IOException {
		String msgString = msg.getValue();
		out.println(msgString);
		String resp = in.readLine();
		return values.string(resp);    		
    }
    
    public void stopClient() throws IOException {
		in.close();
		out.close();
		clientSocket.close();    		
    }
}