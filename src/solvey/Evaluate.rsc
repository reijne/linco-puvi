module Solvey::Evaluate

import List;
import util::Math;

import Solvey::ConcreteSyntax;
import Solvey::AbstractSyntax;

private alias Name = str;
private list[value] inputs = [];
private int inid = 0;

// ref:: https://tutor.rascal-mpl.org/Recipes/Languages/Pico/Evaluate/Evaluate.html
public data SolveyVal = stringval(str s) 
						  | numberval(int n)
						  | boolval(bool b)
						  | listval(list[value] li)
						  | errorval(loc lo, int nid, str msg);
						  
alias Func = tuple[Type datatype, list[Parameter] parameters, list[Stmt] block];
alias VENV = tuple[map[Name, SolveyVal] values, 
								list[value] outputs, 
								map[Name, Func] functions, 
								list[SolveyVal] errors,
								list[int] nonBranches,
								list[int] branchTails]; 	

str currentFunction = "";
int nodeID = 0;
list[SolveyVal] errors = [];
list[int] nonTraversed = [];
list[int] tailEnds = [];

bool toBool(b_true()) {nodeID +=1; return true;}
bool toBool(b_false()) {nodeID +=1; return false;}

// Unwrappers used for output stmts, used for pretty printing of the results
value unwrap(stringval(str s)) = s;
value unwrap(numberval(int n)) = n;
value unwrap(boolval(bool b)) =b;
list[value] unwrap(listval(list[value] li)) = li;
SolveyVal unwrap(errorval(loc lo, int nid, str msg)) = errorval(lo, nid, msg);

// SolveyVal makers using primary datatypes
SolveyVal makeSolveyVal(int i) = numberval(i);
SolveyVal makeSolveyVal(str s) = stringval(s);
SolveyVal makeSolveyVal(bool b) = boolval(b);
SolveyVal makeSolveyVal(list[value] l) = listval(l);


// Add an error to the list and return the value
SolveyVal addError(errorval(loc lo, int nid, str msg)) {
	errors += errorval(lo, nid, msg);
	return errorval(lo, nid, msg);
}

// Get all the errors in a concatenated string
str getErrorString(VENV env) {
	str errorstring = "";
	for (e <- env.errors) 
		errorstring += "<e.nid>|<e.msg>\n";
	return errorstring == "" ? errorstring : errorstring[..-1];
}

tuple[loc, int, str] getErrorTuple(errorval(loc lo, int nid, str msg)) {
	return <lo, nid, msg>;
}

// Get all the branch locations and their tails
str getBranchString(VENV env) {
	str branchstring = "";
	for (b <- env.nonBranches) branchstring += "<b>,";
	if (branchstring != "") branchstring = branchstring[..-1];
	branchstring += "|";
	for (t <- env.branchTails) branchstring += "<t>,";
	if (branchstring[-1] == ",") branchstring = branchstring[..-1];
	return branchstring;
}

// Entry point to start evaluating a file
VENV evalProgram(loc file, list[value] input=[]) = evalProgram(sly_build(file), input=input);

// Entry point to start evaluating a program data type
VENV evalProgram(program(list[Stmt] statements), list[value] input=[]) {
	init(input);
	VENV env = <(), [], (), [], [], []>;
	for (stmt <- statements) env = evalStmt(stmt, env);
	env.errors = errors;
	env.nonBranches = nonTraversed;
	env.branchTails = tailEnds;
	return env;
}

void init(list[value] input) {
	inputs = input;
	inid = 0;
	nodeID = 0;
	errors = [];
	nonTraversed = [];
	tailEnds = [];
}

void evalType(Type t, VENV env) {
	nodeID += 1;
}
						  
// Expressions evaluation
SolveyVal evalExpr(Expr:idExpr(str id), VENV env) {
	nodeID += 1; 
	if (env.values[id]?) return env.values[id];
	return addError(errorval(Expr@location, nodeID, "Uninitialised variable <id>"));
}
	
SolveyVal evalExpr(Expr:strExpr(str string), VENV env) {
	nodeID += 1; 
	return stringval(string);
}

SolveyVal evalExpr(Expr:numExpr(int number), VENV env) { 
	nodeID += 1; 
	return numberval(number);
}

SolveyVal evalExpr(Expr:boolExpr(Boolean boolean), VENV env) {
	nodeID += 1; 
	return boolval(toBool(boolean));
}

SolveyVal evalExpr(Expr:listExpr(list[Expr]  items), VENV env) {
	nodeID += 1; 
	l = [];
	for (item <- items) l += evalExpr(item, env); 
	return listval(l);
}

// TODO add input using the list of expr
SolveyVal evalExpr(Expr:inputExpr(), VENV env) {
	nodeID += 1; 
	if (inid >= size(inputs)) return addError(errorval(Expr@location, nodeID, "Input count mismatch, requested <inid+1> input(s), but supplied <size(inputs)> actual inputs")); 
	SolveyVal s = makeSolveyVal(inputs[inid]);
	inid += 1;
	return s;
}

SolveyVal evalExpr(Expr:funCall(str id, list[Expr] args), VENV env) {
	nodeID += 1;
	tuple[Type datatype, list[Parameter] parameters, list[Stmt] block] function = env.functions[id];
	VENV localEnv = env;
	for (i <- [0 .. size(function.parameters)]) {
		param = function.parameters[i];
		localEnv.values[param.id] = evalExpr(args[i], localEnv);
	}
	currentFunction = id;
	for (stmt <- function.block) localEnv = evalStmt(stmt, localEnv);
	return localEnv.values[id];
}

SolveyVal evalExpr(Expr:bracketExpr(Expr expr), VENV env) {
	nodeID += 1;
	return evalExpr(expr, env);
}

// Arithemetic Expressions
SolveyVal evalExpr(Expr:powExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(toInt(pow(n1, n2))) : 
	addError(errorval(Expr@location, nodeID, "Power Expression requires number arguments on both sides"));
}
SolveyVal evalExpr(Expr:mulExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 * n2) : 
	addError(errorval(Expr@location, nodeID, "Multiplication requires number arguments on both sides"));
}

SolveyVal evalExpr(Expr:divExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 / n2) : 
	addError(errorval(Expr@location, nodeID, "Division requires number arguments on both sides"));
}

SolveyVal evalExpr(Expr:modExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 % n2) : 
	addError(errorval(Expr@location, nodeID, "Modulo requires number arguments on both sides"));
}

SolveyVal evalExpr(Expr:minExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 - n2) : 
	addError(errorval(Expr@location, nodeID, "Minus requires number arguments on both sides"));
}

// TODO add string + list operations
SolveyVal evalExpr(Expr:addExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 + n2) : 
	addError(errorval(Expr@location, nodeID, "Addition requires number arguments on both sides"));
}

// Logical Expressions
SolveyVal evalExpr(Expr:andExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (boolval(b1) := evalExpr(lhs, env) && boolval(b2) := evalExpr(rhs, env)) ? 
	boolval(b1 && b2) : 
	addError(errorval(Expr@location, nodeID, "AND operation requires bool arguments on both sides"));
}

SolveyVal evalExpr(Expr:andExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	return (boolval(b1) := evalExpr(lhs, env) && boolval(b2) := evalExpr(rhs, env)) ? 
	boolval(b1 || b2) : 
	addError(errorval(Expr@location, nodeID, "OR operation requires bool arguments on both sides"));
}

SolveyVal evalExpr(Expr:notExpr(Expr expr), VENV env) { 
	nodeID += 1;
	return boolval(b1) := evalExpr(expr, env) ? 
	boolval(!b1) : 
	addError(errorval(Expr@location, nodeID, "NOT operation requires a bool argument"));
}

SolveyVal evalExpr(Expr:eqExpr(Expr lhs, Expr rhs), VENV env) {
	nodeID += 1;
	err = errorval(Expr@location, nodeID, "Cannot compare the values with each other, an unknown type has been found");
	str equalError(str typa) = "Equality Operator requires two arguments of the same type, one is a <typa> the other is not";
	if (boolval(b1) := evalExpr(lhs, env)) {
		return boolval(b2) := evalExpr(rhs, env) ? boolval(b1 == b2) : addError(errorval(Expr@location, nodeID, equalError("bool")));
	}	else if (numberval(n1) := evalExpr(lhs, env)) {
		return numberval(n2) := evalExpr(rhs, env) ? boolval(n1 == n2) : addError(errorval(Expr@location, nodeID, equalError("number")));
	} else if (stringval(s1) := evalExpr(lhs, env)) {
		return stringval(s2) := evalExpr(rhs, env) ? boolval(s1 == s2) : addError(errorval(Expr@location, nodeID, equalError("string")));
	} else if (listval(l1) := evalExpr(lhs, env)) {
		return listval(l2) := evalExpr(rhs, env) ? boolval(l1 == l2) : 	addError(errorval(Expr@location, nodeID, equalError("list")));
	} else {
		evalExpr(rhs, env);
		return addError(err);
	} 
}

SolveyVal evalExpr(Expr:gtExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	err = errorval(Expr@location, nodeID, "Greater than requires number arguments on both sides in order to compare"); 
	if (numberval(n1) := evalExpr(lhs, env))
		if (numberval(n2) := evalExpr(rhs, env))
			return boolval(n1 > n2);
	return addError(err); 
	//return (numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	//boolval(n1 > n2) : 
	//addError(errorval(Expr@location, nodeID, "Greater than requires number arguments on both sides in order to compare"));
}

SolveyVal evalExpr(Expr:gteExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	err = errorval(Expr@location, nodeID, "Greater than or equal requires number arguments on both sides in order to compare");
	if (numberval(n1) := evalExpr(lhs, env))
		if (numberval(n2) := evalExpr(rhs, env))
			return boolval(n1 >= n2);
	return addError(err);
}

SolveyVal evalExpr(Expr:ltExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	err = errorval(Expr@location, nodeID, "Lesser than requires number arguments on both sides in order to compare");
	if (numberval(n1) := evalExpr(lhs, env))
		if (numberval(n2) := evalExpr(rhs, env))
			return boolval(n1 < n2); 
	return addError(err);
}

SolveyVal evalExpr(Expr:lteExpr(Expr lhs, Expr rhs), VENV env) { 
	nodeID += 1;
	err = errorval(Expr@location, nodeID, "Lesser than or equal requires number arguments on both sides in order to compare");
	if (numberval(n1) := evalExpr(lhs, env))
		if (numberval(n2) := evalExpr(rhs, env))
			return boolval(n1 < n2); 
	return addError(err);
}

// Statement Evaluations
VENV evalStmt(Stmt:exprStmt(Expr expr), VENV env) { 
	nodeID += 1;
	evalExpr(expr, env);
	return env;
}

VENV evalStmt(Stmt:decl(Type datatype, str id), VENV env) { 
	nodeID += 1;
	evalType(datatype, env);
	return env;
}

VENV evalStmt(Stmt:listDecl(Type datatype, str id), VENV env) { 
	nodeID += 1;
	evalType(datatype, env);
	return env;
}

VENV evalStmt(Stmt:returnStmt(Expr expr), VENV env) {
	nodeID += 1;
	env.values[currentFunction] = evalExpr(expr, env);
	return env;
}

VENV evalStmt(Stmt:assStmt(str id, Expr expr), VENV env) {
	nodeID += 1;
	env.values[id] = evalExpr(expr, env);
	return env;
}

VENV evalStmt(Stmt:outputStmt(Expr expr), VENV env) {
	nodeID += 1;
	list[value] newoutputs = [];
	for (out <- env.outputs) newoutputs += out;
	newoutputs += unwrap(evalExpr(expr, env));
	env.outputs = newoutputs;
	return env;
}

VENV evalStmt(Stmt:ifStmt(Expr cond, list[Stmt] block), VENV env) {
	nodeID += 1;
	if (boolval(true) := evalExpr(cond, env)) {
		for(st <- block) env = evalStmt(st, env);
	} else {
		nodeIDbefore = nodeID;
		for(st <- block) evalStmt(st, env);
		for (i <- [nodeIDbefore .. nodeID]) nonTraversed += i;
		tailEnds += nodeID-1;
		nodeID = nodeIDbefore;
	}
	return env;
}

VENV evalStmt(Stmt:ifElseStmt(Expr cond, list[Stmt] thenBlock, list[Stmt] elseBlock), VENV env) {
	nodeID += 1;
	list[Stmt] oppositeBlock = elseBlock;
	
	if (boolval(true) := evalExpr(cond, env)) {
		for(st <- thenBlock) env = evalStmt(st, env); 
	} else {
		for(st <- elseBlock) env = evalStmt(st, env);
		oppositeBlock = thenBlock;
	}
	
	nodeIDbefore = nodeID;
	for(st <- oppositeBlock) evalStmt(st, env);
	for (i <- [nodeIDbefore .. nodeID]) nonTraversed += i;
	tailEnds += nodeID-1;
	nodeID = nodeIDbefore;
	
	return env;
}

VENV evalStmt(Stmt:repeatStmt(int iter, list[Stmt]block), VENV env) {
	nodeID += 1;
	for (_ <- [0 .. iter]) 
		for (st <- block) env = evalStmt(st, env);
	return env;
}

VENV evalStmt(Stmt:whileStmt(Expr cond, list[Stmt] block), VENV env) {
	nodeID += 1;
	while (boolval(true) := evalExpr(cond, env)) 
		for (st <- block) env = evalStmt(st, env);
	return env;
}

VENV evalStmt(Stmt:funDef(Type datatype, str id, list[Parameter] parameters, list[Stmt] block), VENV env) {
	nodeID += 1;
	evalType(datatype, env);
	env.functions[id] = <datatype, parameters, block>;
	return env;
}
