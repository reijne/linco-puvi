module solvey::GenerateTraverser

import IO;
import String;

import Node;
import List;
import Map;
import Type;
import solvey::AST;

public loc traverserFile = |project://puzzley/src/solvey/Traverser.rsc|;
private list[str] literals = ["str", "int"];

@doc {
	Generate a traverser of Solvey ASTs that labels before and after states
}
public void genTraverser() {
	str travContent = "//This is a generated file, do not manually alter unless you absolutely know what you\'re doing, and \n//dont mind getting your work overwritten upon next generation.\n\n // Traverser module implementing a custom labeled traversal of a Solvey AST\nmodule solvey::Traverser\nimport solvey::AST;\n\n";
	travContent = addEntryPoint(travContent);
	
	visit(#Program) {
		case cons(label(nodeName,adt(cateName,[])),[],[],{}): {
			travContent += "private str labeledTraverse(<nodeName>()) = 
									   '    \"in_<cateName>_< nodeName>
									   '    out_<cateName>_< nodeName>\";\n\n";
		}
		case cons(label(nodeName,adt(cateName,[])),children,[],{}): {
			travContent += "private str labeledTraverse(<nodeName>(";
			list[tuple[str, str, bool]] childList = [];
			visit (children) {
				case label(childName, \str()): childList += <"str", childName, false>;
				case label(childName, \int()): childList += <"int", childName, false>;
				case label(childName, adt(childType, [])):  childList += <childType, childName, false>;
				case label(childName, \list(adt(childType, []))): childList += <childType, childName, true>;
			}
			travContent = addParameters(travContent, childList);
			travContent += "\"in_<cateName>_<nodeName>\n";
			travContent = addChildrenTraversal(travContent, childList);
			travContent += "out_<cateName>_<nodeName>\";\n\n";	
		}
	}
	writeFile(traverserFile, travContent);
}

@doc {
	Add an entry point for the traversal that is public and thus accesible through import.
}
private str addEntryPoint(str content) {
	return content + "public str startLabeledTraverse(Program p) = labeledTraverse(p);\n";
}

@doc {
	Add in the parameters of the node type using its children
}
private str addParameters(str content, list[tuple[str, str, bool]] params) {
	for (i <- [0 .. size(params)]) {
		str typ = params[i][0];
		str name = params[i][1];
		bool isList = params[i][2];
		str delim = (i == size(params)-1) ? "" : ",";
		if (isList) {
			content += "list[<typ>] <name><delim>";				
		} else {
			content += "<typ> <name><delim>";				
		}
	}
	content += "))  =\n";
	return content;
}

@doc {
	Add the partial function "body", traversing every child with a before and after state for every child 
}
private str addChildrenTraversal(str content, list[tuple[str, str, bool]] childList) {
	 for (i <- [0 .. size(childList)]) {
	 	str typ = childList[i][0];
		str name = childList[i][1];
		bool isList = childList[i][2];
		
		if (typ in literals) continue;
		
		content += "_in_<typ>_<name>\n";
		if (isList) {
			content += "\"+\"\<for (<name>Item \<- <name>){\>\<labeledTraverse(<name>Item)\>\\n\<}\>\"[..-1]+\"\n";
		} else {
			content += "\<labeledTraverse(<name>)\>\n";
		}
		content += "_out_<typ>_<name>\n";
	 }
    return content;
}