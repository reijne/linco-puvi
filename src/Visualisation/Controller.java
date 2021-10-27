package Visualisation;

import java.io.IOException;
import java.net.URL;

import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValueFactory;
//import org.rascalmpl.values.functions.IFunction;

public class Controller {
		private final IValueFactory values;
		// Initialise the controller class using the IValueFactory (linking Rascal).
	    public Controller(IValueFactory values){
	    	this.values = values;
	    }
	
	// Start the desired application for the given operating system.
	public void startApplication(IString os, IString appName) throws IOException {
		URL location = Controller.class.getProtectionDomain().getCodeSource().getLocation();
		String app = appName.getValue(); 
		String relativePath = "";
		
		switch (os.getValue()) {
			case "windows": relativePath = "Puzzle/Apps/"+app+"/Windows/"+app+".exe"; break; 
			case "linux": break; 
			case "macos": break; 
		}

		String appPath = location.getPath() + relativePath;
		Runtime.getRuntime().exec(appPath);
	}
}