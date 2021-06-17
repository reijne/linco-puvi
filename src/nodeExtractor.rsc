module nodeExtractor

import IO;
import String;

import Node;
import List;
import Map;
import Type;
import solvey::ast;

import util::Benchmark;
import util::Math;

public loc standardSolvey = |project://puzzley/src/solvey/ast.rsc|;

@doc {
	Compare the execution times for the different methods of AST node extraction.
}
public void timer() {
	for (iter <- [n*n  | int n <- [10, 100, 200, 500, 1000]]) {		
		int starter = realTime();
		for (_ <- [0 .. iter]) {
			getSolveyASTNodesString(standardSolvey);
		}
		int end  = realTime();
		int firsty = end-starter;
		
		starter = realTime();
		for (_ <- [0 .. iter]) {
			getSolveyASTNodesVisit();
		}
		end = realTime();
		int lasty = end-starter;
		print("Iterations: "); 			print(iter);
		print("\nString method:"); 	print(firsty);
		print("\nVisit method: "); 	print(lasty);
		print("\n" + "======\n");
		print("Ratio:");						print(toReal(lasty)/firsty); 	
		print("\n");	
	}
}

@doc {
	Get all the AST nodes for the solvey language #Program type
}
public str getSolveyASTNodesVisit() {
	set[node] constructors = getConstructors();
	categorisedMap = ();
	children = ();
	for(c <- constructors) {
		cate = "";
		constructor = c[0];
		visit(constructor) {
			case \label(consName, categoryADT): {
				visit(categoryADT) {
					case \adt(gory, _): cate = gory;
				}
				categorisedMap = initialisedAdd(categorisedMap, cate, consName);
				childList = c[1];
				visit(childList) {
					case \label(childName, childCateADT): {
						visit (childCateADT) {
							case \adt(gory, _): children = initialisedAdd(children, consName, gory + "_" + childName);
							case \int(): children = initialisedAdd(children, consName, "int_" + childName);
							case \str(): children = initialisedAdd(children, consName, "str_" + childName);
						}
					}
				}				
			}
		}
	}
	return stringifyNodes(categorisedMap, children);	
}

@doc {
	Create a string from all the categories, AST nodes and children
}
private str stringifyNodes(map[str, list[str]] categorisedMap, map[str, list[str]] children) {
	str stringy = "";
	for (category <- categorisedMap) {
		stringy += category + " category\n" ;
		for (constructor <- categorisedMap[category]) {
			stringy += constructor;
			if (constructor in children && size(children[constructor]) > 0) {
				stringy += "{\n";
				for (chil <- children[constructor]) stringy += chil + "\n";
				stringy += "}\n";
			}  else {
				stringy += "{}\n";
			}
		}
	}
	print(stringy);
	return stringy;
}

@doc {
	Get the constructors for the Solvey #Program type.
}
private set[node] getConstructors() {
	constructors = {};
	visit(#Program) {
		case node N: {
			switch(getName(N)) {
				case "cons": constructors += N;
				default: ;
			}
		}
		default: ; 
	}
	return constructors;
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