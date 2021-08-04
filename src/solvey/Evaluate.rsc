module Solvey::Evaluate

import List;

import util::Math;

import Solvey::ConcreteSyntax;
import Solvey::AbstractSyntax;

private alias Name = str;

// ref:: https://tutor.rascal-mpl.org/Recipes/Languages/Pico/Evaluate/Evaluate.html
data SolveyVal = stringval(str s) 
						  | numberval(int n)
						  | boolval(bool b)
						  | listval(list[value] li)
						  | errorval(loc lo, str msg);
alias Func = tuple[Type datatype, list[Parameter] parameters, list[Stmt] block];
alias VENV = tuple[map[Name, SolveyVal] values, list[value] outputs, map[Name, Func] functions]; 	

str currentFunction = "";

bool toBool(b_true()) = true;
bool toBool(b_false()) = false;

value unwrap(stringval(str s)) = s;
value unwrap(numberval(int n)) = n;
value unwrap(boolval(bool b)) =b;
list[value] unwrap(listval(list[value] li)) = li;

// Entry point to start evaluating a file
VENV evalProgram(loc file) = evalProgram(sly_build(file));

// Entry point to start evaluating a program data type
VENV evalProgram(program(list[Stmt] statements)) {
	VENV env = <(), [], ()>;
	for (stmt <- statements) env = evalStmt(stmt, env);
	return env;
}
						  
// Expressions evaluation
SolveyVal evalExpr(Expr:idExpr(str id), VENV env) = 
	(env.values[id]?) ? env.values[id] : errorval(Expr@location, "Uninitialised variable <id>");
	
SolveyVal evalExpr(Expr:strExpr(str string), VENV env) = stringval(string);

SolveyVal evalExpr(Expr:numExpr(int number), VENV env) = numberval(number);

SolveyVal evalExpr(Expr:boolExpr(Boolean boolean), VENV env) = boolval(toBool(boolean));

SolveyVal evalExpr(Expr:listExpr(list[Expr]  items), VENV env) {
	l = [];
	for (item <- items) l += evalExpr(item, env); 
	return listval(l);
}

// TODO add input using the list of expr
SolveyVal evalExpr(Expr:inputExpr(), VENV env) = errorval(Expr@location, "Input expr not yet evaluated");

SolveyVal evalExpr(Expr:funCall(str id, list[Expr] args), VENV env) = errorval(Expr@location, "function calls are not evaluated");

SolveyVal evalExpr(Expr:bracketExpr(Expr expr), VENV env) = evalExpr(expr, env);

// Arithemetic Expressions
SolveyVal evalExpr(Expr:powExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(toInt(pow(n1, n2))) : 
	errorval(Expr@location, "Power Expression requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:mulExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 * n2) : 
	errorval(Expr@location, "Multiplication requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:divExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 / n2) : 
	errorval(Expr@location, "Division requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:modExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 % n2) : 
	errorval(Expr@location, "Modulo requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:minExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 - n2) : 
	errorval(Expr@location, "Minus requires number arguments on both sides");

// TODO add string + list operations
SolveyVal evalExpr(Expr:addExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	numberval(n1 + n2) : 
	errorval(Expr@location, "Addition requires number arguments on both sides");
	
// Logical Expressions
SolveyVal evalExpr(Expr:andExpr(Expr lhs, Expr rhs), VENV env) = 
	(boolval(b1) := evalExpr(lhs, env) && boolval(b2) := evalExpr(rhs, env)) ? 
	boolval(b1 && b2) : 
	errorval(Expr@location, "AND operation requires boolean arguments on both sides");
	
SolveyVal evalExpr(Expr:andExpr(Expr lhs, Expr rhs), VENV env) = 
	(boolval(b1) := evalExpr(lhs, env) && boolval(b2) := evalExpr(rhs, env)) ? 
	boolval(b1 || b2) : 
	errorval(Expr@location, "OR operation requires boolean arguments on both sides");

SolveyVal evalExpr(Expr:notExpr(Expr expr), VENV env) = 
	boolval(b1) := evalExpr(expr, env) ? 
	boolval(!b1) : 
	errorval(Expr@location, "NOT operation requires a boolean argument");

SolveyVal evalExpr(Expr:eqExpr(Expr lhs, Expr rhs), VENV env) {
	str equalError(str typa) = "Equality Operator requires two arguments of the same type, one is a <typa> the other is not";
	if (boolval(b1) := evalExpr(lhs, env)) {
		return boolval(b2) := evalExpr(rhs, env) ? boolval(b1 == b2) : 
		errorval(Expr@location, equalError("bool"));
	}	else if (numberval(n1) := evalExpr(lhs, env)) {
		return numberval(n2) := evalExpr(rhs, env) ? boolval(n1 == n2) : 
		errorval(Expr@location, equalError("number"));
	} else if (stringval(s1) := evalExpr(lhs, env)) {
		return stringval(s2) := evalExpr(rhs, env) ? boolval(s1 == s2) : 
		errorval(Expr@location, equalError("string"));
	} else if (listval(l1) := evalExpr(lhs, env)) {
		return listval(l2) := evalExpr(rhs, env) ? boolval(l1 == l2) : 
		errorval(Expr@location, equalError("list"));
	} else {
		return errorval(Expr@location, "Cannot compare the values with each other, an unknown type has been found");
	} 
	//throw("Cannot happen");
}

SolveyVal evalExpr(Expr:gtExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	boolval(n1 > n2) : 
	errorval(Expr@location, "Greater than requires number arguments on both sides in order to compare");

SolveyVal evalExpr(Expr:gteExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	boolval(n1 >= n2) : 
	errorval(Expr@location, "Greater than or equal requires number arguments on both sides in order to compare");

SolveyVal evalExpr(Expr:ltExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	boolval(n1 < n2) : 
	errorval(Expr@location, "Lesser than requires number arguments on both sides in order to compare");
	
SolveyVal evalExpr(Expr:lteExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs, env) && numberval(n2) := evalExpr(rhs, env)) ? 
	boolval(n1 < n2) : 
	errorval(Expr@location, "Lesser than or equal requires number arguments on both sides in order to compare");
	
// Statement Evaluations
VENV evalStmt(Stmt:exprStmt(Expr expr), VENV env) = env;

VENV evalStmt(Stmt:decl(Type datatype, str id), VENV env) = env;

VENV evalStmt(Stmt:listDecl(Type datatype, str id), VENV env) = env;

VENV evalStmt(Stmt:returnStmt(Expr expr), VENV env) {
	env.values[currentFunction] = evalExpr(expr, env);
	return env;
}

VENV evalStmt(Stmt:assStmt(str id, Expr expr), VENV env) {
	env.values[id] = evalExpr(expr, env);
	return env;
}

VENV evalStmt(Stmt:outputStmt(Expr expr), VENV env) {
	env.outputs = [env.outputs, unwrap(evalExpr(expr, env))];
	return env;
}

VENV evalStmt(Stmt:ifStmt(Expr cond, list[Stmt] block), VENV env) {
	if (boolval(true) := evalExpr(cond, env)) for(st <- block) env = evalStmt(st, env); 
	return env;
}

VENV evalStmt(Stmt:ifElseStmt(Expr cond, list[Stmt] thenBlock, list[Stmt] elseBlock), VENV env) {
	if (boolval(true) := evalExpr(cond, env)) for(st <- thenBlock) env = evalStmt(st, env); 
	else for(st <- elseBlock) env = evalStmt(st, env);
	return env;
}

VENV evalStmt(Stmt:repeatStmt(int iter, list[Stmt]block), VENV env) {
	for (_ <- [0 .. iter]) 
		for (st <- block) env = evalStmt(st, env);
	return env;
}

VENV evalStmt(Stmt:whileStmt(Expr cond, list[Stmt] block), VENV env) {
	while (boolval(true) := evalExpr(cond, env)) 
		for (st <- block) env = evalStmt(st, env);
	return env;
}

VENV evalStmt(Stmt:funDef(Type datatype, str id, list[Parameter] parameters, list[Stmt] block), VENV env) {
	env.functions[id] = <datatype, parameters, block>;
	return env;
}
