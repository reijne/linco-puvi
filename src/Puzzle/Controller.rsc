module Puzzle::Controller

import IO;
import IDE;
import Exception;

import Solvey::AbstractSyntax;
import Solvey::ConcreteSyntax;
import Solvey::Traverser;
import Solvey::NodeExtractor;

import Network::ClientController;

@javaClass{Puzzle.Controller}
public java str startApplication(str os, str appName);

private str os = "windows"; // {"windows", "linux", "macos"}
private loc showeyDef = |project://Puzzle/src/Puzzle/serialised.show|;
private loc solution = |project://Puzzle/src/Puzzle/solution.sly|;

private str showeyBuilder = "ShoweyBuilder";
private str sceney = "Sceney";

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

public void makePuzzle() {
	sly_register();
	startApplication(os, sceney);
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	createSceney();
	print("Sceney created\n");
	updateSceney();
	print("Sceney populated\n");
	str oldContent = readFile(solution);
	while (true) {
		newContent = readFile(solution);
		if (newContent != oldContent) {
			updateSceney();
			oldContent = newContent;
		}
	}
	safeStopClient();
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