module solvey::run

// Rascal imports
import IO;
import ParseTree;

// Custom Imports for solvey language
import solvey::Syntax;
import solvey::AST;
import solvey::IDE;

// Location of folder for output
loc output = |project://puzzley/output|;

// Locations of files for output of parsetrees
loc con = output + "concrete.txt";
loc ast = output + "abstract.txt";

int compare (loc file) {
	solvey::IDE::sly_register();
	Tree c = solvey::Syntax::sly_parse_tree(file);
	print(c);
	//Tree a = solvey::AST::sly_build(file);
	writeFile(con, c);
	//writeFile(ast, a);
	return 0;
}