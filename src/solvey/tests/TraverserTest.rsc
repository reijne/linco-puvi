module Solvey::tests::TraverserTest

import IO;
import String;
import List;

import Solvey::Traverser;
import Solvey::AbstractSyntax;
import Tools::GenerateTraverser;

import Solvey::tests::Setup;
import Solvey::tests::AbstractTest;

// Property 1 :: Always starts with an in-x-x  and ends with an out-x-x
// Property 2 :: A child cannot occur before a node has been found ... implied in 1
// Property 3 :: All traversal items have to be closed, in other words; every in operation has to be met with an out

@doc {
	Test the start and ending of the labeled traversal, must be in accordance with property 1.
}
test bool headsAndTails() {
	genTraverser();
	bool success = true;
	Solvey::tests::AbstractTest::updateTestList();
	for (fun <- Solvey::tests::AbstractTest::currentAbstractTests) {
		executeTestFunction(fun);
		str labelTrav = labeledTraverse(sly_build(Solvey::tests::Setup::testFile));
		list[str] ops = split("\n", labelTrav);
		if (ops[0][0..2] != "in" || ops[size(ops)-1][0..3] != "out") {
			print("LabeledTraversal <labelTrav> does not comply with property 1 of starting with in and ending in out");
			success = false;
		} 
	}
	return success;
}

@doc {
	Test that no child can exist without having a node prior, as stated by property 2.
}
test bool childAfterNode() {
	genTraverser();
	bool success = true;
	Solvey::tests::AbstractTest::updateTestList();
	for (fun <- Solvey::tests::AbstractTest::currentAbstractTests) {
		executeTestFunction(fun);
		str labelTrav = labeledTraverse(sly_build(Solvey::tests::Setup::testFile));
		if (contains(labelTrav, "-in")) success = findFirst(labelTrav, "in") < findFirst(labelTrav, "-in");
	}
	return success;
}

@doc {
	Test that the traversal is complete by matching the pairs of operations
}
test bool completeTraversal() {
	genTraverser();
	bool success = true;
	Solvey::tests::AbstractTest::updateTestList();
	for (fun <- Solvey::tests::AbstractTest::currentAbstractTests) {
		executeTestFunction(fun);
		str labelTrav = labeledTraverse(sly_build(Solvey::tests::Setup::testFile));
		stack = [];
		for (op <- split("\n", labelTrav)) {
			if (contains(op, "in")) stack += "1";
			else stack = pop(stack)[1];
		}
		success = size(stack) == 0;
	}
	return success;
}

@doc {
	Execute the specified function while disabling the verbose output.
}
private void executeTestFunction(bool() fun) {
	Solvey::tests::AbstractTest::doPrint = false;
	fun();
	Solvey::tests::AbstractTest::doPrint = true; 
}