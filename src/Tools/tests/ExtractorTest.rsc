module Tools::tests::ExtractorTest

import List;
import Type;
import String;

import Solvey::AbstractSyntax;
import Tools::NodeExtractor;

// Property 1: All Algebraic data types and constructors have to be in the extracted nodes
// Property 2: All children of constructor have to be in there as childname
// Property 3: All nodes have to be closed after being opened

test bool t_containsAllConstructors() = containsAllConstructors(#Program);
bool containsAllConstructors(node tree) {
	bool success = true;
	str extractedNodes = getNodes(tree);
	visit(tree) {
		case cons(label(nodeName,adt(cateName,[])),_,[],{}): {
			success = success && contains(extractedNodes, cateName)
										 && contains(extractedNodes, nodeName);
		}
	}
	return success;
}

test bool t_noMissingChildren() = noMissingChildren(#Program);
bool noMissingChildren(node tree) {
	bool success = true;
	str extractedNodes = getNodes(tree);
	visit(tree) {
		case cons(label(_,adt(_,[])), children,[],{}): {
			visit (children) {
				case label(childName, adt(_, [])): success = success && contains(extractedNodes, childName);
				case label(childName, \list(adt(_, []))): success = success && contains(extractedNodes, childName);
			}
		}
	}
	return success;
}

test bool t_allNodesClosedAfterOpen() = allNodesClosedAfterOpen(#Program);
bool allNodesClosedAfterOpen(node tree) {
	str extractedNodes = getNodes(tree);
	return size(findAll(extractedNodes ,"{")) == size(findAll(extractedNodes, "}"));
}