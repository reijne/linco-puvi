module Solvey::Evaluate

import Solvey::ConcreteSyntax;

// ref:: https://tutor.rascal-mpl.org/Recipes/Languages/Pico/Evaluate/Evaluate.html
data SolveyVal = stringval(str s) 
						  | numberval(int n)
						  | boolval(bool b)
						  | listval(list l)
						  | errorval(loc l, str msg);
					
alias VENV = map[Name, SolveyVal]; 	

str currentFunction = "";
						  
// Expressions evaluation
SolveyVal evalExpr(Expr:idExpr(str id), VENV env) = 
	(env[id]?) ? env[id] : errorval(Expr@location, "Uninitialised variable <id>");
	
SolveyVal evalExpr(Expr:strExpr(str string), VENV env) = stringval(string);

SolveyVal evalExpr(Expr:numExpr(int number), VENV env) = numberval(number);

SolveyVal evalExpr(Expr:boolExpr(Boolean boolean), VENV env) = boolval(boolean);

SolveyVal evalExpr(Expr:listExpr(list[Expr]  items), VENV env) {
	list l = [];
	for (item <- items) l += evalExpr(item); 
	return listVal(l);
}

SolveyVal evalExpr(Expr:funCall(str id, list[Expr] args), VENV env) = errorval(Expr@location, "function calls are not evaluated");

SolveyVal evalExpr(Expr:bracketExpr(Expr expr), VENV env) = evalExpr(expr);

// Arithemetic Expressions
SolveyVal evalExpr(Expr:powExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	numberval(n1 ** n2) : 
	errorval(Expr@location, "Power Expression requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:mulExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	numberval(n1 * n2) : 
	errorval(Expr@location, "Multiplication requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:divExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	numberval(n1 / n2) : 
	errorval(Expr@location, "Division requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:modExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	numberval(n1 % n2) : 
	errorval(Expr@location, "Modulo requires number arguments on both sides");
	
SolveyVal evalExpr(Expr:minExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	numberval(n1 - n2) : 
	errorval(Expr@location, "Minus requires number arguments on both sides");

// TODO add string + list operations
SolveyVal evalExpr(Expr:addExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	numberval(n1 + n2) : 
	errorval(Expr@location, "Addition requires number arguments on both sides");
	
// Logical Expressions
SolveyVal evalExpr(Expr:andExpr(Expr lhs, Expr rhs), VENV env) = 
	(boolval(b1) := evalExpr(lhs) && boolval(b2) := evalExpr(rhs)) ? 
	boolval(b1 && b2) : 
	errorval(Expr@location, "AND operation requires boolean arguments on both sides");
	
SolveyVal evalExpr(Expr:andExpr(Expr lhs, Expr rhs), VENV env) = 
	(boolval(b1) := evalExpr(lhs) && boolval(b2) := evalExpr(rhs)) ? 
	boolval(b1 || b2) : 
	errorval(Expr@location, "OR operation requires boolean arguments on both sides");

SolveyVal evalExpr(Expr:notExpr(Expr expr), VENV env) = 
	boolval(b1) := evalExpr(expr) ? 
	boolval(!b1) : 
	errorval(Expr@location, "NOT operation requires a boolean argument");

SolveyVal evalExpr(Expr:eqExpr(Expr lhs, Expr rhs), VENV env) {
	str equalError(string typa) = "Equality Operator requires two arguments of the same type, one is a <typa> the other is not";
	if (boolval(b1) := evalExpr(lhs)) {
		boolval(b2) := evalExpr(rhs) ? boolval(b1 == b2) : 
		errorval(Expr@location, equalError("bool"));
	}	else if (numberval(n1) := evalExpr(lhs)) {
		numberval(n2) := evalExpr(rhs) ? boolval(n1 == n2) : 
		errorval(Expr@location, equalError("number"));
	} else if (stringval(s1) := evalExpr(lhs)) {
		stringval(s2) := evalExpr(rhs) ? boolval(n1 == n2) : 
		errorval(Expr@location, equalError("string"));
	} else if (listval(l1) := evalExpr(lhs)) {
		listval(l2) := evalExpr(rhs) ? boolval(n1 == n2) : 
		errorval(Expr@location, equalError("list"));
	} else {
		errorval(Expr@location, "Cannot compare the values with each other, an unknown type has been found");
	} 
}

SolveyVal evalExpr(Expr:gtExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	boolval(n1 > n2) : 
	errorval(Expr@location, "Greater than requires number arguments on both sides in order to compare");

SolveyVal evalExpr(Expr:gteExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	boolval(n1 >= n2) : 
	errorval(Expr@location, "Greater than or equal requires number arguments on both sides in order to compare");

SolveyVal evalExpr(Expr:ltExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	boolval(n1 < n2) : 
	errorval(Expr@location, "Lesser than requires number arguments on both sides in order to compare");
	
SolveyVal evalExpr(Expr:lteExpr(Expr lhs, Expr rhs), VENV env) = 
	(numberval(n1) := evalExpr(lhs) && numberval(n2) := evalExpr(rhs)) ? 
	boolval(n1 < n2) : 
	errorval(Expr@location, "Lesser than or equal requires number arguments on both sides in order to compare");
	
// Statement Evaluations
VENV evalStmt(Stmt:exprStmt(Expr expr), VENV env) = env;

VENV evalStmt(Stmt:decl(Type datatype, str id), VENV env) = env;

VENV evalStmt(Stmt:listDecl(Type datatype, str id), VENV env) = env;

VENV evalStmt(Stmt:returnStmt(Expr expr), VENV env) {
	env[currentFunction] = evalExpr(expr);
	return env;
}

VENV evalStmt(Stmt:assStmt(str id, Expr expr), VENV env) {
	env[id] = evalExpr(expr);
	return env;
}

// TODO add this thing, make a list of inputs to gather from
VENV evalStmt(Stmt:inputStmt(), VENV env) {
	// Gather the list bro
	return env;
}
