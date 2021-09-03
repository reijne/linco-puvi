module IDE

import ParseTree;

import Solvey::ConcreteSyntax;
import Solvey::AbstractSyntax;
import Solvey::TypeCheck;
import Solvey::Evaluate;

import util::IDE;
import vis::Figure;


public str SLY_NAME = "Solvey Language";
public str SLY_EXT = "sly";

private set[Contribution] conset = {};

// Register Solvey as a language in Eclipse o-o
public void sly_lang() {
  registerLanguage(SLY_NAME, SLY_EXT, sly_parse);
}

public void sly_annotate(Tree(Tree t) annotator) {
	registerAnnotator(SLY_NAME, annotator);
}

// Pallete
Color pansyPurple				= rgb(123, 0, 82, 1.0); // Standard Rascal Colour
Color mediumSlateBlue		= rgb(100, 100, 220, 1.0);
Color redGray						= rgb(150, 127, 127, 1.0);
Color hunterGreen				= rgb(62, 105, 75, 1.0);
Color pastelGreen				= rgb(76, 185, 68, 1.0);
Color burgundy					= rgb(170, 6, 32, 1.0);

public void sly_style() {
	Contribution style = categories(
		(
			"Comment": {foregroundColor(hunterGreen), italic()},
			"Literatus": {foregroundColor(redGray)},
			"TypeKeyword": {foregroundColor(mediumSlateBlue), bold()},
			"ID": {foregroundColor(mediumSlateBlue)},
			"Truth": {foregroundColor(pastelGreen), bold(), italic()},
			"FalseHood": {foregroundColor(burgundy), bold(), italic()}
		)
	);
	conset += style;
}

public void sly_build(set[Message](Tree t) mes) {
	Contribution build = builder(mes);
	conset += build;
}	

public void sly_init() {
	sly_lang();
	sly_style();
	sly_register();
}

public void sly_reset() {
	clearNonRascalContribution(SLY_NAME);
	conset = {};
	sly_init();
}

public void sly_register() {
	registerContributions(SLY_NAME, conset);
}

//public str SHO_NAME = "Showey Language";
//public str SHO_EXT = "sho";
//
//public void sho_register() {
//	registerLanguage(SHO_NAME, SHO_EXT, showey::syntax_concrete::sho_parse);
//}
//
//public void register_langs() {
//	sly_register();
//	sho_register();
//}