module IDE

import ParseTree;

import Solvey::ConcreteSyntax;
import Solvey::AbstractSyntax;
import Solvey::TypeCheck;
import Solvey::Evaluate;

import util::IDE;


public str SLY_NAME = "Solvey Language";
public str SLY_EXT = "sly";

// Register Solvey as a language in Eclipse o-o
public void sly_register() {
  registerLanguage(SLY_NAME, SLY_EXT, sly_parse);
}

public Tree errorAnnotator(Tree t) {
	Program pro = implode(#Program, t); 
	TENV types = checkProgram(pro);
	VENV values = evalProgram(pro);
	errors = {};
	
	for (tuple[loc l, int i, str msg] te <-  types.errors) errors += error(te.msg, te.l);
	for (e <- values.errors) errors += error(getErrorTuple(e)[2], getErrorTuple(e)[0]);
	return t[@messages = errors];
}

public void sly_annotate(Tree(Tree t) annotator) {
	registerAnnotator(SLY_NAME, annotator);
}

public void sly_init() {
	sly_register();
	sly_annotate(errorAnnotator);
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