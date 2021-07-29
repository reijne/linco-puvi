module Tools::NodeExtractor

import IO;
import List;
import Type;
import String;

import Solvey::AbstractSyntax;

import util::Benchmark;
import util::Math;

private loc standardSolvey = |project://Puzzle/src/Solvey/AbstractSyntax.rsc|;

@doc {
	Get the hierarchical AST nodes for the solvey language type #Program in a string.
}
public str getNodes() = getNodes(#Program);
 
@doc {
	Get the hierarchical AST nodes representation for a given tree..
}
public str getNodes(node tree) {
	categoryNodeMap = ();
	nodeChildrenMap = ();
	visit (tree) {
		case cons(label(nodeName,adt(cateName,[])),children,[],{}): {
			categoryNodeMap = initialisedAdd(categoryNodeMap, cateName, nodeName);
			visit (children) {
				case label(childName, adt(childType, [])):
					nodeChildrenMap = initialisedAdd(nodeChildrenMap, nodeName, childType+"_"+childName);
				case label(childName, \list(adt(childType, []))): 
					nodeChildrenMap = initialisedAdd(nodeChildrenMap, nodeName, "list["+childType+"]_"+childName);
			}
		}
	}
	return stringifyNodes(categoryNodeMap, nodeChildrenMap);
}

@doc {
	Create a string from all the categories, AST nodes and children
}
private str stringifyNodes(map[str, list[str]] categoryNodeMap, map[str, list[str]] nodeChildrenMap) {
	str stringy = "";
	for (category <- categoryNodeMap) {
		stringy += category + " category\n" ;
		for (noden <- categoryNodeMap[category]) {
			stringy += noden;
			if (noden in nodeChildrenMap && size(nodeChildrenMap[noden]) > 0) {
				stringy += "{\n";
				for (child <- nodeChildrenMap[noden]) stringy += child + "\n";
				stringy += "}\n";
			}  else {
				stringy += "{}\n";
			}
		}
	}
	return stringy;
}

@doc {
	Index the map at key and add to the list or initialise a list with the value.
	.param mappy, map wherin the value is to be added at key
	.param key, index for the map
	.param val, value to be added to the list
}
private map[value, list[value]] initialisedAdd(map[value, list[value]] mappy, value key, value val) {
	if (key in mappy) {
		mappy[key] += val;
	} else {
		mappy[key] = [val];
	}
	return mappy;
}

/// Section /// String methodology for extraction
@doc {
	Get all the AST nodes for the standard location of solvey
}
public str getSolveyASTNodes() {
	return getSolveyASTNodesString(standardSolvey);
}

@doc {
	Get the AST nodes from a language definition at 
	.param location
}
public str getSolveyASTNodesString(loc solveyAST) {
	str nodes = "";
	for (str line  <- readFileLines(solveyAST)) {
		if ((contains(line, "=") || contains(line, "|")) && !contains(line, "//")) {
			line = removeFront(trim(line));
			line = removeSpaces(line);
			line = insertNewLines(line);
			nodes += line + "\n";
		}
	}
	return nodes;
}

@doc {
	Remove the front part of the AST node definitions, up and including the "=" or "|"
}
public str removeFront(str line) {
	int starter = findFirst(line, "=");
	if (starter == -1) starter = findFirst(line, "|");
	return replaceLast(trim(substring(line, starter+1)), ";", "");
}

@doc {
	Remove all the intermediary spaces and replace the space between type and identifier with an _
}
public str removeSpaces(str line) {
	line = replaceAll(line, ", ",",");
	line = replaceAll(line, " ","_");
	line = replaceAll(line, "(", "{");
	line = replaceAll(line, ")", "}");
	return line;
}

@ doc {
	Insert new lines for every parameter such that mapping can be done.
}
public str insertNewLines(str line) {
	if (contains(line, "{}")) return replaceAll(line, "{}", ":");
	line = replaceAll(line, "{", ": {\n\t");
	line = replaceAll(line, "}", ": \n}");
	line = replaceAll(line, ",", ": \n\t");
	return line;
}
/// End Section /// String methodology for extraction

@doc {
	Compare the execution times for the different methods of AST node extraction.
}
public void timer() {
	for (iter <- [100, 1000, 10000, 100000]) {		
		int starter = realTime();
		for (_ <- [0 .. iter]) {
			getSolveyASTNodesString(standardSolvey);
		}
		int end  = realTime();
		int firsty = end-starter;
		
		starter = realTime();
		for (_ <- [0 .. iter]) {
			getNodes();
		}
		end = realTime();
		int lasty = end-starter;
		print("Calls: "); 			print(iter);
		print("\nString method:"); 	print(firsty);
		print("\nVisit method: "); 	print(lasty);
		print("\n" + "======\n");
		print("Ratio:");						print(toReal(lasty)/firsty); 	
		print("\n");	
	}
}