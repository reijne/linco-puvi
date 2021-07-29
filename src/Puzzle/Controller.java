package Puzzle;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
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
	
//	IWorkspace workspace = ResourcesPlugin.getWorkspace();
//	   IResourceChangeListener listener = new IResourceChangeListener() {
//	      public void resourceChanged(IResourceChangeEvent event) {
//	         System.out.println("Something changed!");
//	      }
//	   };
//	   workspace.addResourceChangeListener(listener);
//
//	   //... some time later one ...
//	   workspace.removeResourceChangeListener(listener);
	
	// File difference worker
	// readFile(IFuncation sendUpdate)
	//	spawn thread
	// while something
	// if (diff != null) sendUpdate.call
//	public void worker(IFunction fun) {
//		fun.call();
//	}
}