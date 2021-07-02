module PuzzleController

import solvey::AST;
import solvey::Traverser;

import IO;
// private loc showeyDef = ;
// private list[str] skippedCategories = [];
// private bool skipNesting = false;

// Socket
// Solvey file Generator < returns location
// Solvey file loop < parse into AST and create labeled traversal, to send over socket

public str tryTraverse() {
	Program p = sly_build(|project://puzzley/src/solvey/solutions/smoll.sly|);
	str s = startLabeledTraverse(p);
	print(s);
	return s;
}
