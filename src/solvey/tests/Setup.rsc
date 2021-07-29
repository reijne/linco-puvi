module Solvey::tests::Setup

import IO;

import Solvey::tests::AbstractTest;

public loc testDir = |project://Puzzle/src/Solvey/tests|;
public loc testFile;
public bool isSetup = false;

void setupTestFile() {
	testFile = testDir + "auto_test.sly";
	writeFile(testFile, "");
	isSetup = true;
}