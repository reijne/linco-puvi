module Puzzle::Controller

import IO;
import IDE;
import String;
import Exception;
import Prelude;
import Type;

import util::IDE;
//import util::ValueUI;


import Solvey::AbstractSyntax;
import Solvey::ConcreteSyntax;
import Solvey::TypeCheck;
import Solvey::Evaluate;
import Solvey::Traverser;
import Tools::NodeExtractor;
import Tools::GenerateTraverser;

import Network::ClientController;

@javaClass{Puzzle.Controller}
public java str startApplication(str os, str appName);

private str os = "windows"; // {"windows", "linux", "macos"}
//private loc showeyDef = |project://Puzzle/src/Puzzle/serialised.show|;
// Set these variables to change the visualisation and which file the solver will program in.
private loc showeyDef = |project://Puzzle/src/Puzzle/Shows/serialised_paper.show|;
private loc solution = |project://Puzzle/src/Puzzle/solution.sly|;

private str showeyBuilder = "ShoweyBuilder";
private str sceney = "Sceney";

private str gameType = "";
private list[value] input = [];
private list[value] expectedOutput = [];

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

// TODO make this update the running scene instead
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
	str typeerrorstring = getErrorString(checkProgram(solution));
	str evalerrorstring = getErrorString(evalProgram(solution));
	if (typeerrorstring == "" || evalerrorstring == "") updateErrors(typeerrorstring + evalerrorstring);
	else updateErrors(typeerrorstring + "\n" + evalerrorstring);
}

public void updateBranches() {
	str branchstring = getBranchString(evalProgram(solution));
	//print("BranchString::<branchstring>\n");
	updateBranches(branchstring);
}

public Tree errorAnnotator(Tree t) {
	Program pro = implode(#Program, t); 
	TENV types = checkProgram(pro);
	VENV values = evalProgram(pro, input=input);
	errors = {};
	
	for (tuple[loc l, int i, str msg] te <-  types.errors) errors += error(te.msg, te.l);
	for (e <- values.errors) errors += error(getErrorTuple(e)[2], getErrorTuple(e)[0]);
	return t[@messages = errors];
}

public void setup(list[value] ins, list[value] eout) {
	sly_init();
	input = ins;
	sly_annotate(errorAnnotator);
	expectedOutput = eout;
	genTraverser();
	startApplication(os, sceney);
	createSceney();
	updateSceney();
}

public void updater() {
	str oldContent = readFile(solution);
	print("Click here to start! :: <solution>");
	while (true) {
		newContent = readFile(solution);
		if (newContent != oldContent) {
			updateSceney();
			
			if (gameType == "shooter") updateErrors();
			else if (gameType == "platformer") updateBranches();
			checkOutputs();
			
			if (contains(newContent, "stopnow")) break;
			oldContent = newContent;
		}
	}
	safeStopClient();
}

public void checkOutputs() {
	list[value] actualOutput = evalProgram(solution).outputs;
	print("\n\nOutputs :: <actualOutput>");
	
	if (actualOutput == expectedOutput) {
		print("Congratulations you have solved the Puzzle!\n");
	} else {
		print("The puzzle is not quite solved yet\n");
	}
}

public void makePuzzle(list[value] ins=[], list[value] eout=[]) {
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	setup(ins, eout);
	updateMessage("Fly around and look for clues... \n Then solve the coding puzzle.\n", 4.0);
	updater();
	closeServer();
	stopClient();
}

@doc {
	Set up the app as a shooter type game, where errors show up as enemies.
}
public void makeShooter(list[value] ins=[], list[value] eout=[]) {
	expectedOut = eout;
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	setup(ins, eout);
	updateMessage("The errors in the code spawn enemies.\nFix them before they fix you!\n", 4.0);
	gameType = "shooter";
	updater();
	closeServer();
	stopClient();
}

@doc {
	Set up the game scene as a platformer with falling branches and collectables.
}
public void makePlatformer(list[value] ins=[], list[value] eout=[]) {
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	setup(ins, eout);
	gameType = "platformer";
	updater();
	closeServer();
	stopClient();
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