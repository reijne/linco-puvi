module controller

import IO;
import String;

public loc standardSolvey = |project://puzzley/src/solvey/ast.rsc|;

@doc {
	Get all the AST nodes for the standard location of solvey
}
public str getSolveyASTNodes() {
	return getSolveyASTNodes(standardSolvey);
}

@doc {
	Get all the AST nodes for the solvey language located at param: loc
}
public str getSolveyASTNodes(loc solveyAST) {
	str nodes = "";
	for (str line  <- readFileLines(solveyAST)) {
		if ((contains(line, "=") || contains(line, "|")) && !contains(line, "//")) {
			line = removeFront(trim(line));
			line = removeSpaces(line);
			line = insertNewLines(line);
			nodes += line + "\n";
		}
	}
	print(nodes);
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
	Remove all the intermediary spaces and replace the space between type and identifier with a _
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