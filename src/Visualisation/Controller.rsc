module Visualisation::Controller

import Prelude;
import util::IDE;

// Language definition
import Visualisation::Syntax;
import Visualisation::Traverser;

// Language independent tools
import Tools::NodeExtractor;
import Tools::GenerateTraverser;

// API calls
import Network::ClientController;

@javaClass{Apps.Controller}
public java str startApplication(str os, str appName);

// Location for generating the labeled traverser.
private loc traverserLocation = |project://Puzzle/src/Visualisation/Traverser.rsc|;
// Location for live visualising
private loc file = |project://Puzzle/src/Visualisation/image.txt|;

// Language name used to register contributions.
private str IMG_NAME = "Image Lang";
private str folder = "Visualisation";

// Application names
private str showeyBuilder = "ShoweyBuilder";
private str sceney = "Sceney";

// Operating System
private str os = "windows"; // {"windows", "linux", "macos"}

// Created Visualisation
private loc showeyDefinition = |project://Puzzle/src/Visualisation/showdef.show|;

@doc {
	Create a new visualisation of the desired language.
}
void createShowey() {
	extractedNodes = getNodes(#Image);
	startApplication(os, showeyBuilder);
	createShowey(extractedNodes);
}

@doc {
	Launch Sceney and set it up using the showey visualisation.
}
void createSceney() {
	reset();
	genTraverser(#Image, "module <folder>::Traverser", "import <folder>::Syntax;", dest=traverserLocation);
	
	startApplication(os, sceney);
	createSceney(readFile(showeyDefinition));
	
	Contribution build = builder(updater);
	registerLanguage(IMG_NAME, "txt", img_parse);
	registerContributions(IMG_NAME, {build});
	println("Visualising current file: <file>");
}

@doc {
	Update the Sceney instance using the current labeled traversal.
}
public set[Message] updater(Tree t) {
	println("updateing");
	Image i = implode(#Image, img_parse(file));
	println("image: <i>");
	labeled = labeledTraverse(i);
	println("labeled: <labeled>");
	updateSceney(labeled);
	return {};
}

@doc {
	Clear the contributions, to stop the sceney instance from updating.
}
void reset() {
	clearNonRascalContribution(IMG_NAME);
}