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
private loc showeyDef = |project://Puzzle/src/Puzzle/Shows/showdef.show|;
private loc solution = |project://Puzzle/src/Puzzle/solution.sly|;

private str showeyBuilder = "ShoweyBuilder";
private str sceney = "Sceney";

private str gameType = "";
private list[value] input = [];
private list[value] expectedOutput = [];

private str labeled = "";
private TENV tenv = <(),(),[]>;
private VENV venv = <(), [], (), [], [], []>;
private map[loc, int] nodeLocations = ();
private int id = 0;

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

public void updateCollectable(loc src) {
	try {updateCollectable(nodeLocations[src]);} catch: ;
}

public void updateHighlight(loc src) {
	try {updateHighlight(nodeLocations[src]);} catch: ;
}

public void updateErrors() {
	str typeerrorstring = getErrorString(tenv, nodeLocs=nodeLocations);
	str evalerrorstring = getErrorString(venv, nodeLocs=nodeLocations);
	if (typeerrorstring == "" || evalerrorstring == "") updateErrors(typeerrorstring + evalerrorstring);
	else updateErrors(typeerrorstring + "\n" + evalerrorstring);
}

public void updateBranches() {
	str branchstring = getBranchString(venv, nodeLocations);
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

public void createNodeLocations(Program pro) {
	nodeLocations = ();
	id = 1;
	top-down visit(pro) {
		case Boolean b: {
			nodeLocations[b@location] = id;
			id += 1;
		}
		case Type t: {
			nodeLocations[t@location] = id;
			id += 1;
		}
		case Expr e: {
			nodeLocations[e@location] = id;
			id += 1;
		}
		case Stmt s: {
			nodeLocations[s@location] = id;
			id += 1;
		}
	}
}

public set[Message] dataBuilder(Tree t) {
	Program pro = implode(#Program, t);
	println("in the builder");
	createNodeLocations(pro);
	println("AFTER LOCATIONS MADE");
	labeled = labeledTraverse(pro);
	tenv = checkProgram(pro);
	venv = evalProgram(pro, input=input);
	updater();
	return {};
}

public void setup(list[value] ins, list[value] eout) {
	genTraverser();
	reset();
	sly_init();
	input = ins;
	
	expectedOutput = eout;
	startApplication(os, sceney);
	createSceney();
	
	sly_annotate(errorAnnotator);
	sly_build(dataBuilder);
	sly_register();
	print("Click here to start! :: <solution>");
}

public void updater() {
	
	updateSceney(labeled);
			
	if (gameType == "shooter") updateErrors();
	else if (gameType == "platformer") updateBranches();
	
	print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			'====================Puzzle Info");
	checkState();
	printVariables();
	checkOutputs();
	print("====================END Puzzle Info");
}

public void checkOutputs() {
	list[value] actualOutput = venv.outputs;
	if (actualOutput != []) print("\n==========Outputs\n<actualOutput>");
	
	if (actualOutput == expectedOutput) println("\nThe output is expected!");
	else 	println("\nThe output is not quite what was expected");
}

@doc {
	Check any desired state of the solution.
}
public void checkState() {
	if (tenv.errors != [] || venv.errors != []) {
		println("\n==========Errors");
		for (e <- tenv.errors) println(e);
		for (e <- venv.errors) println(e);
	}
	//tenv.symbols.contains(x, type=number)
}

public void printVariables() {
	map[Name, SolveyVal] values = venv.values;
	str vars = "";
	for (name <- values) {
		vars += "<name> = <unwrap(values[name])>\n";
	}
	if (vars != "") {
		println("\n==========Variables\n<vars[..-1]>");
	}
}

public void makePuzzle(list[value] ins=[], list[value] eout=[]) {
	writeFile(solution, readFile(|project://Puzzle/src/Puzzle/Exercises/Empty_Puzzle.sly|));
	setup(ins, eout);
	updateMessage("Fly around and look for clues... \n Then solve the coding puzzle.\n", 4.0);
}

public void reset() {
	try {stopClient(); } catch:;
	sly_reset();
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
}

@doc {
	Set up the game scene as a platformer with falling branches and collectables.
}
public void makePlatformer(list[value] ins=[], list[value] eout=[]) {
	writeFile(solution, "// Type some code here and pray to the gods it shows in the scene :)\n");
	setup(ins, eout);
	updateMessage("Collect all the shiny gold orbs spawned at every branch, but beware of non-executed branches!!!\n", 4.0);
	gameType = "platformer";
}

// Make multiple choice puzzle
public void multipleChoicePuzzle() {
	ins = [1, 2];
	eout = ["A"];
	writeFile(solution, readFile(|project://Puzzle/src/Puzzle/Exercises/Choice_Fibonnaci.sly|));
	setup(ins, eout);
	updateMessage("Fly around and look for clues... \n Then solve the coding puzzle.\n", 4.0);
}
// header :: Uncomment the choice and see what happens
// addChoice("code snippet")

// Make ordering puzzle 
// Order the sections to fix errors / make the visualisation show something
// Make multiple choice puzzle
public void orderingPuzzle() {
	ins = [8, 13];
	eout = [5, 3, 2, 1, 1, 0];
	writeFile(solution, readFile(|project://Puzzle/src/Puzzle/Exercises/Order_Fibonnaci.sly|));
	setup(ins, eout);
	updateMessage("Fly around and look for clues... \n Then solve the coding puzzle.\n", 4.0);
}


// make addition puzzle
// Add a piece of code such that the output is correct

// make empty puzzle
// Give a general goal and let the solver figure out how to do it completely