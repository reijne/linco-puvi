module Solvey::tests::AbstractTest

import IO;
import String;
import Boolean;

import Solvey::ConcreteSyntax;
import Solvey::AbstractSyntax;

import Solvey::tests::Setup;

private loc thisFile = |project://Puzzle/src/Solvey/tests/AbstractTest.rsc|;

public bool doPrint = true;

@doc {
	Gather a list of all the existing test bool functions without parameters and append them to this file, overwriting the last line.
}
public void updateTestList() {
	list[str] lines = readFileLines(thisFile);
	list[str] tests = [];
	str writer = "";
	for (line <- lines[0..-1]) {
		writer += "<line>\n";
		if (contains(line, "test bool") && contains(line, "()") && !contains(line, "waba")) 
			tests += getTestName(line);
	}
	inner = "<for(tes<-tests){><tes>,<}>"[..-1];
	writer += "public list[bool()] currentAbstractTests = [<inner>];"; 
	writeFile(thisFile, writer);
}

@doc {
	Get the function name of a test.
}
str getTestName(str line) {
	list[str] s = split("test bool", line);
	str name = replaceAll(s[1], " ", "");
	name = replaceAll(name, "(", "");
	name = replaceAll(name, ")", "");
	return replaceAll(name, "{", "");
}

@doc {
	Write the line to a file and attempt to build the AST, return if its has succeeded.
}
bool buildLine(str line) {
	bool success = true;
	try {
		writeFile(Solvey::tests::Setup::testFile, line);
		Program ast = sly_build(Solvey::tests::Setup::testFile);
	} catch e: {
		success = false;
		print(e);
	};
	return success;
}

@doc {
	Foreach code snippet write it to file and attempt to build, then report on the results.
}
bool buildLines(str testName, list[str] lines) {
	if (!doPrint) print("\n" + testName+"\n---------------------------------------------------------------");
	if (!Solvey::tests::Setup::isSetup) Solvey::tests::Setup::setupTestFile();
	bool success = true;
	for (line <- lines) {
		if (!doPrint) print("\n" + line);
		success = success && buildLine(line);
		if (!doPrint)print("\n|^|^| success = " + toString(success) + "\n");		
	}
	if (!doPrint)print("\n======================================");
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
															  "list[number] myList"]);
															
}

test bool listCreation() {
	return buildLines("listCreation", ["x := []", "x := [1,2]", "x := [1+1]"]);
}

test bool arithmetics() {
	return buildLines("Arithmetic and Assignment", ["2+2",
															"x := 1 ** 2",
															"x := num1 ^ num2",
															"x := num1 * num2",
															"x := num1 / num2",
															"x := num1 % num2",
															"x := num1 + num2",
															"x := num1 - num2"]);
}

test bool stringConcat() {
	return buildLines("String Concatenation", ["string myString\nmyString := \"some\" + \"thing\""]);
}

test bool boolOperators() {
	return buildLines("Boolean Operators", ["bool bol\nbol := false || true",
																			"bool bol2\nbol2 := false or true",
																			"bol bol3\nbool3 := false && true",
																			"bol bol4\nbool4 := false and true",
																			"bol bol5\nbool5 := !true"]);
}

test bool boolComparison() {
	return buildLines("Boolean Comparison", ["bool comp\ncomp := 1 \> 2",
																				"bool comp2\ncomp2 := 1 \>= 2",
																				"bool comp3\ncomp3 := 1 \< 2",
																				"bool comp4\ncomp4 := 1 \>= 2"]);
}

test bool ifStatement() {
	return buildLines("If statement", ["if (comp == comp2)\n\tcomp2 := !comp\nend if"]);
}

test bool ifelseStatement() {
	return buildLines("If Else statement", ["if (bolletje)\n\tsomething\nelse\n\tsomething2\nend if"]);
}

test bool repeatStatement() {
	return buildLines("Repeat statement", ["repeat (9)\n\tx := x+1\nend repeat"]);
}

test bool whileStatement() {
	return buildLines("While statement", ["while (succ)\n\tx := x + 1\nend while"]);
}

test bool functionDefinition() {
	return buildLines("Function definition", ["bool function isDivisiblebyThree(number x)\n\treturn x % 3 == 0\nend function", 
																		"bool function isDivisiblebyThree(number x, string s)\n\treturn x % 3 == 0\nend function"]);
}

test bool functionCall() {
	return buildLines("Function call", ["\nfunc()","func(x)","func(2)","func(3+3)","func(4\>2)"]);
}

test bool bracketExpression() {
	return buildLines("Bracket Expression", ["(2)","(2+2)","two := (2)"]);
}

test bool inoutput() {
	return buildLines("IO time", ["input()", "output(\"hello world\")"]);
}

// DO NOT REMOVE OR ALTER THE FOLLOWING LIST DECLARATION.
// Keeps track of the currently made tests for AST such that they can be utilised elsewhere.
// This line has to be the last in order for the update tests function to work properly !!!!!!!!
public list[bool()] currentAbstractTests = [declarations,listCreation,arithmetics,stringConcat,boolOperators,boolComparison,ifStatement,ifelseStatement,repeatStatement,whileStatement,functionDefinition,functionCall,bracketExpression,inoutput];

