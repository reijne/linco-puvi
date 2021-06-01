module solvey::tests::ast_test

import IO;
import Boolean;
import Exception;

import solvey::syntax_concrete;
import solvey::ast;

loc testDir = |project://puzzley/src/solvey/tests|;
loc testFile;
bool isSetup = false;

void setupTestFile() {
	testFile = testDir + "astTest.sly";
	writeFile(testFile, "");
	isSetup = true;
}

@doc {
	Write the line to a file and attempt to build the AST, return if its has succeeded.
}
bool buildLine(str line) {
	bool success = true;
	try {
		writeFile(testFile, line);
		Program ast = sly_build(testFile);
	} catch RuntimeException(): {
		success = false;
	};
	return success;
}

bool buildLines(str testName, list[str] lines) {
	print("\n" + testName+"\n---------------------------------------------------------------");
	if (!isSetup) setupTestFile();
	bool success = true;
	for (line <- lines) {
		print("\n" + line);
		success = success && buildLine(line);
		print("\n|^|^| success = " + toString(success) + "\n");		
	}
	print("\n======================================");
	return success;
}

@doc{
	.Synopsis 
	Write declarations to a file and check to see if building an AST succeeds.
}
test bool declarations() {
	return buildLines("Declarations", ["string myString", 
															  "number myNumber", 
															  "bool myBool",
															  "list myList"]);
															
}

test bool listCreation() {
	return buildLines("listCreation", ["x = []", "x = [1,2]", "x = [1+1]"]);
}

test bool arithmetics() {
	return buildLines("Arithmetic and Assignment", ["2+2",
															"x = 1 ** 2",
															"x = num1 ^ num2",
															"x = num1 * num2",
															"x = num1 / num2",
															"x = num1 % num2",
															"x = num1 + num2",
															"x = num1 - num2"]);
}

test bool stringConcat() {
	return buildLines("String Concatenation", ["string myString\nmyString = \"some\" + \"thing\""]);
}

test bool boolOperators() {
	return buildLines("Boolean Operators", ["bool bol\nbol = false || true",
																			"bool bol2\nbol2 = false or true",
																			"bol bol3\nbool3 = false && true",
																			"bol bol4\nbool4 = false and true",
																			"bol bol5\nbool5 = !true"]);
}

test bool boolComparison() {
	return buildLines("Boolean Comparison", ["bool comp\ncomp = 1 \> 2",
																				"bool comp2\ncomp2 = 1 \>= 2",
																				"bool comp3\ncomp3 = 1 \< 2",
																				"bool comp4\ncomp4 = 1 \>= 2"]);
}

test bool ifStatement() {
	return buildLines("If statement", ["if (comp == comp2)\n\tcomp2 = !comp\nend if"]);
}

test bool ifelseStatement() {
	return buildLines("If Else statement", ["if (bolletje)\n\tsomething\nelse\n\tsomething2\nend if"]);
}

test bool repeatStatement() {
	return buildLines("Repeat statement", ["repeat (9)\n\tx = x+1\nend repeat"]);
}

test bool whileStatement() {
	return buildLines("While statement", ["while (succ)\n\tx = x + 1\nend while"]);
}

test bool functionDefinition() {
	return buildLines("Function definition", ["bool function isDivisiblebyThree(number x)\n\treturn x % 3 == 0\nend function"]);
}

test bool functionCall() {
	return buildLines("Function call", ["\nfunc()","func(x)","func(2)","func(3+3)","func(4\>2)"]);
}

test bool inoutput() {
	return buildLines("IO time", ["input()", "output(\"hello world\""]);
}
