module Solvey::tests::TypeTest

import IO;
import List;

import Solvey::TypeCheck;

import Solvey::tests::Setup;

@doc {
	Write the line to a file and check to see if the typechecker detected the error.
}
bool testLine(str line) {
	writeFile(Solvey::tests::Setup::testFile, line);
	TENV env = checkProgram(Solvey::tests::Setup::testFile);
	return size(env.errors) != 0;
}

@doc {
	Loop over the faulty code lines and test them using testline.
}
bool testLines(list[str] lines) {
	if (!Solvey::tests::Setup::isSetup) Solvey::tests::Setup::setupTestFile();
	bool success = true;
	for (line <- lines) {
		if (!testLine(line)) {
			success = false;
			print("No error detected within line: \n<line>\n");
		}
	}
	return success;
}

// Undeclared variable or function used
test bool undeclared() {
	return testLines(["someVar", "someFunc()", "someVar := 2"]);
}

//test bool 


