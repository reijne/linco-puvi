module Puzzle::Controller

import IO;
import IDE;
import String;
import Exception;

import Solvey::AbstractSyntax;
import Solvey::ConcreteSyntax;
import Solvey::TypeCheck;
import Solvey::Traverser;
import Tools::NodeExtractor;
import Tools::GenerateTraverser;

import Network::ClientController;

@javaClass{Puzzle.Controller}
public java str startApplication(str os, str appName);

private str os = "windows"; // {"windows", "linux", "macos"}
private loc showeyDef = |project://Puzzle/src/Puzzle/serialised.show|;
private loc solution = |project://Puzzle/src/Puzzle/solution.sly|;

private str showeyBuilder = "ShoweyBuilder";
private str sceney = "Sceney";

private str gameType = "";

// private list[str] skippedCategories = [];
// private bool skipNesting = false;

// Socket
// Solvey file Generator < returns location
// Solvey file loop < parse into AST and create labeled traversal, to send over socket

public str tryTraverse() {
	Program p = sly_build(solution);
	str s = labeledTraverse(p);
	print(s);
	return s;
}

public void createShowey() {
	startApplication(os, showeyBuilder);
	createShowey(getNodes());
}

public void updateShowey() {
	startApplication(os, showeyBuilder);
	updateShowey(readFile(showeyDef));
}

public void createSceney() {
 	str serialised = readFile(showeyDef);
 	if (serialised == "") throw IO("Empty visualisation found, make one using createShowey()");
	createSceney(serialised);
}

public void updateSceney() {
	try {
		//print("\n\nCode ::\n<sly_parse(solution)>\nEnd Code\n\n");
		Program p = sly_build(solution);
		updateSceney(labeledTraverse(p));
	} catch e: print("parse error <e>");	
}

public void updateErrors() {
	str errorstring = getErrorString(checkProgram(solution));
	updateErrors(errorstring);
}

public void setup() {
	sly_register();
	genTraverser();
	//startApplication(os, sceney);
	createSceney();
	print("Sceney created\n");
	updateSceney();
	print("Sceney populated\n");
}

public void updater() {
	str oldContent = readFile(solution);
	while (true) {
		newContent = readFile(solution);
		if (newContent != oldContent) {
			updateSceney();
			
			if (gameType == "shooter") updateErrors();
			else if (gameType == "platformer") print("lol this is not supported yet");
			
			print("TypeChecking\n <checkProgram(solution)>");
			
			if (contains(newContent, "stopnow")) break;
			oldContent = newContent;
		}
	}
	safeStopClient();
}

public void makePuzzle() {
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	setup();
	updater();
}

public void makeShooter() {
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	setup();
	gameType = "shooter";
	updater();
}

// Make multiple choice puzzle
// header :: Uncomment the choice and see what happens
// addChoice("code snippet")

// Make ordering puzzle 
// Order the sections to fix errors / make the visualisation show something

// make addition puzzle
// Add a piece of code such that the output is correct

// make empty puzzle
// Give a general goal and let the solver figure out how to do it completely