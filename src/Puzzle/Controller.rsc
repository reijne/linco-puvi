module Puzzle::Controller

import IO;
import IDE;
import String;
import Exception;
import Prelude;

import util::IDE;

import Solvey::AbstractSyntax;
import Solvey::ConcreteSyntax;
import Solvey::TypeCheck;
import Solvey::Evaluate;
import Solvey::Traverser;

import util::IDEServices;
import util::Benchmark;

// Language independent tools
import Tools::NodeExtractor;
import Tools::GenerateTraverser;

// API calls
import Network::ClientController;

@javaClass{Apps.Controller}
public java str startApplication(str os, str appName);

// Operating System
private str os = "windows"; // {"windows", "linux", "macos"}

// Puzzle Templates
private loc emptyPuzzle = |project://Puzzle/src/Puzzle/Exercises/Empty_Puzzle.sly|;
private loc branchJumper = |project://Puzzle/src/Puzzle/Exercises/BranchJumper.sly|;
private loc errorEnemies = |project://Puzzle/src/Puzzle/Exercises/ErrorEnemies.sly|;

// Set these variables to change the visualisation and which file the solver will program in.
private loc showeyDef = |project://Puzzle/src/Puzzle/Shows/Progress.show|;
private loc solution = |project://Puzzle/src/Puzzle/solution.sly|;

// Application names
private str showeyBuilder = "ShoweyBuilder";
private str sceney = "Sceney";

// Puzzle specifics
private str gameType = "";
private list[value] input = []; // only accepts: bool, int, string
private list[value] expectedOutput = []; // only accepts: bool, int, string

// Data collections
private str labeled = "";
private TENV tenv = <(),(),[]>;
private VENV venv = <(), [], (), [], [], []>;
private map[loc, int] nodeLocations = ();
private int id = 0;
private list[int] executedPath = [];

@doc {
	Create a fresh visualisation of the Solvey language.
}
public void createShowey() {
	startApplication(os, showeyBuilder);
	createShowey(getNodes());
}

@doc {
	Initialise the Sceney instance using the specified showey definition.
}
public void createSceney() {
 	str serialised = readFile(showeyDef);
 	if (serialised == "") throw IO("Empty visualisation found, make one using createShowey()");
 	startApplication(os, sceney);
	createSceney(serialised);
}

@doc {
	Update the scene by spawning a collectable using a source code location.
}
public void updateCollectable(loc src) {
	try {updateCollectable(nodeLocations[src]);} catch: ;
}

@doc {
	Update the scene by highlighting a node using a source code location.
}
public void updateHighlight(loc src) {
	try {updateHighlight(nodeLocations[src]);} catch: ;
}

@doc {
	Update the scene to spawn error enemies for all found errors.
}
public void updateErrors() {
	str typeerrorstring = getErrorString(tenv, nodeLocs=nodeLocations);
	str evalerrorstring = getErrorString(venv, nodeLocs=nodeLocations);
	if (typeerrorstring == "" || evalerrorstring == "") updateErrors(typeerrorstring + evalerrorstring);
	else updateErrors(typeerrorstring + "\n" + evalerrorstring);
}

@doc {
	Update the scene by making non-executed branches fall, and spawning collectables at every branch.
}
public void updateBranches() {
	str branchstring = getBranchString(venv, nodeLocations);
	updateBranches(branchstring);
}

@doc {
	Annotate the tree with found errors from typchecking and evaluating.
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

@doc {
	Create the mapping from source code locations to node locations.
}
public void nodeLocator(Program pro) {
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

@doc {
	On save file - Build all data necessary for API calls.
}
public set[Message] dataBuilder(Tree t) {
	Program pro = implode(#Program, t);
	nodeLocator(pro);
	labeled = labeledTraverse(pro);
	tenv = checkProgram(pro);
	venv = evalProgram(pro, input=input);
	list[int] nonExecuted = [nodeLocations[n] | n <- venv.nonBranches]; 
	executedPath = [0..id] - nonExecuted;
	updater();
	return {};
}

@doc {
	Get the node source location based on the id.
}
public loc getNodeLoc(int id) {
	for (<loca, nodeid> <- toList(nodeLocations)) {
		print("current loc <loca>, <id>, <nodeid>");
		if (nodeid == id) {
			print("found loc <loca>");
			return loca;
		}
	}
	return solution;
}

@doc {
	Set up Solvey, Sceney and the annotator + builder	
}
public void setup(list[value] ins, list[value] eout) {
	genTraverser();
	reset();
	sly_init();
	input = ins;
	expectedOutput = eout;
	
	createSceney();
	sly_annotate(errorAnnotator);
	sly_build(dataBuilder);
	sly_register();
	
	println("Click here to code! :: <solution>");
}

@doc {
	Update the scene using live data, display the current state of errors, variables and output.
}
public void updater() {
	updateSceney(labeled);
			
	if (gameType == "platformer") { 
		updateBranches();
	} else {
		if (gameType == "shooter") updateErrors();
		manualSequence();
		updateSequence(executedPath, 1.0);	
	}
	printPuzzleInformation();
}

@doc {
	Highlight the code and visualisation both, however block until the animation is complete.
}
private void manualSequence() {
	for (nodeIdentifier <- [0] + executedPath) {
		updateHighlight(nodeIdentifier);
		loc codeloc = getNodeLoc(nodeIdentifier);
		//println(typeOf(util::IDEServices::edit));
		//edit(codeloc);
		print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
					'<codeloc>");
		int starter = realTime();
		while(starter + 2000 > realTime()) {
			print("");
		}
	}
}

@doc {
	Print the current information of the code puzzle to the terminal.
}
private void printPuzzleInformation() {
	print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			'Click here to code! :: <solution>
			'====================Puzzle Info");
	checkState();
	printVariables();
	checkOutputs();
}

@doc {
	Display and Check if the outputs are equal to the expected out. 
}
public void checkOutputs() {
	list[value] actualOutput = venv.outputs;
	if (actualOutput != []) print("\n==========Outputs\n<actualOutput>");
	
	if (actualOutput == expectedOutput) println("\nThe output is expected!");
	else 	println("\nThe output is not quite what was expected");
}

@doc {
	Check if errors exist and display them, can be expanded to check more.
}
public void checkState() {
	if (tenv.errors != [] || venv.errors != []) {
		println("\n==========Errors");
		for (e <- tenv.errors) println("-<e.msg>@<e.l>");
		for (e <- venv.errors) println("-<getErrorTuple(e)[2]>@<getErrorTuple(e)[0]>");
	}
	// Example to check if the number variable x is declared.
	//tenv.symbols.contains(x, type=number)
}

@doc {
	Print all existing variables with their value after evaluating the solution program.
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

@doc {
	Make a code puzzle, using a template, input and expected output.
}
public void makePuzzle(loc template=emptyPuzzle, loc show=showeyDef, 
										list[value] ins=[], list[value] eout=[]) {
	writeFile(solution, readFile(template));
	showeyDef = show;
	setup(ins, eout);
	updateMessage("Fly around and look for clues... \n Then solve the coding puzzle.\n", 4.0);
}

@doc {
	Reset the connection and Solvey language.
}
public void reset() {
	try {stopClient(); } catch:;
	gameType = "";
	input = [];
	expectedOutput = [];
	sly_reset();
}

@doc {
	Set up the app as a shooter type game, where errors show up as enemies and launch.
}
public void makeShooter(loc template=errorEnemies, loc show=|project://Puzzle/src/Puzzle/Shows/ErrorEnemies.show|,
											list[value] ins=[], list[value] eout=[]) {
	expectedOut = eout;
	showeyDef = show;
	writeFile(solution, readFile(template));
	setup(ins, eout);
	updateMessage("The errors in the code spawn enemies.\nFix them before they fix you!\n", 4.0);
	gameType = "shooter";
}

@doc {
	Set up the game scene as a platformer with falling branches and collectables and launch.
}
public void makePlatformer(loc template=branchJumper, loc show=|project://Puzzle/src/Puzzle/Shows/BranchJumper.show|, 
												list[value] ins=[], list[value] eout=[]) {
	writeFile(solution, readFile(template));
	showeyDef = show;
	setup(ins, eout);
	updateMessage("Collect all the shiny gold orbs spawned at every branch, but beware of non-executed branches!!!\n", 4.0);
	gameType = "platformer";
}

// Make multiple choice puzzle
public void multipleChoicePuzzle() {
	ins = [1, 2];
	eout = ["B"];
	showeyDef = |project://Puzzle/src/Puzzle/Shows/Puzzle.show|;
	writeFile(solution, readFile(|project://Puzzle/src/Puzzle/Exercises/Choice.sly|));
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
	showeyDef = |project://Puzzle/src/Puzzle/Shows/Puzzle.show|;
	writeFile(solution, readFile(|project://Puzzle/src/Puzzle/Exercises/Order.sly|));
	setup(ins, eout);
	updateMessage("Fly around and look for clues... \n Then solve the coding puzzle.\n", 4.0);
}


// make addition puzzle
// Add a piece of code such that the output is correct

// make empty puzzle
// Give a general goal and let the solver figure out how to do it completely