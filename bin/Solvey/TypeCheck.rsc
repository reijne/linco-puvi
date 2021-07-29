module Solvey::TypeCheck

import Prelude;
import Node;
import Solvey::AbstractSyntax;
import Solvey::ConcreteSyntax;

private alias varName = str;
// https://tutor.rascal-mpl.org/Recipes/Languages/Pico/Typecheck/Typecheck.html#/Recipes/Languages/Pico/Typecheck/Typecheck.html
// Type environment
alias TENV = tuple[ map[varName, Type] symbols, list[tuple[loc l, str msg]] errors];

// Add a variable and its type to the symboltable in the type environment
TENV addSymbol(TENV env, varName name, Type t) {
	env.symbols[name] = t;
	return env;
} 

// Add an error message to type environment
TENV addError(TENV env, loc l, str msg) = env[errors = env.errors + <l, msg>];

// Constructing a required message
str expected(Type t, str got) = "Expected <getName(t)>, got <got>";                 
str expected(Type t1, Type t2) = expected(t1, getName(t2));

// Expression checking
TENV checkExpr(Expr:idExpr(varName id), Type req, TENV env) {
	if (!env.symbols[id]?) return addError(env, Expr@location, "Undeclared Variable <id>");
	expectedType = env.symbols[id];
	return req == expectedType ? env : addError(env, Expr@location, expected(req, expectedType));
}

// Typed expressions
TENV checkExpr(Expr:strExpr(str string), Type req, TENV env) = 
	req == t_str() ? env : addError(env, Expr@location, expected(req, "string")); 
	
TENV checkExpr(Expr:numExpr(int number), Type req, TENV env) = 
	req == t_num() ? env : addError(env, Expr@location, expected(req, "number")); 
	
TENV checkExpr(Expr:boolExpr(Boolean boolean), Type req, TENV env) = 
	req == t_bool() ? env : addError(env, Expr@location, expected(req, "boolean")); 

// List expression, check every element
TENV checkExpr(Expr:listExpr(list[Expr] items), Type req, TENV env) {
	for (item <- items) env = checkExpr(item, req, env);
	return env;
}

// Function call, check if its defined, and check all the arguments
TENV checkExpr(Expr:funCall(str id, list[Expr] args), Type req, TENV env) {
	if (!env.symbols[id]?) tenv = addError(env, Expr@location, "Undeclared function <id> called");
	for (arg <- args)  tenv = checkExpr(arg, req, env);
	return env;
}

TENV checkExpr(Expr:bracketExpr(Expr expr), Type req, TENV env) = checkExpr(expr, req, env);

// Arithmetic Expressions
TENV checkExpr(Expr:powExpr(Expr lhs, Expr rhs), Type req, TENV env) = 
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
							  
TENV checkExpr(Expr:mulExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
	
TENV checkExpr(Expr:divExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
							  
TENV checkExpr(Expr:modExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
							  
TENV checkExpr(Expr:minExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));

// Addition expression which also support string type
TENV checkExpr(Expr:addExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	if (req == t_num()) return checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	else if (req == t_str()) return checkExpr(lhs, t_str(), checkExpr(rhs, t_str(), env));
	else 	return addError(env, Expr@location, expected(req, "unexpected type")); 
}

TENV checkExpr(Expr:andExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_bool() ? checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));

TENV checkExpr(Expr:orExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_bool() ? checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
							  
TENV checkExpr(Expr:notExpr(Expr expr), Type req, TENV env) =
	req == t_bool() ? checkExpr(expr, t_bool(), env) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));						  

// Comparison expressions 
TENV checkExpr(Expr:eqExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	if (req == t_num()) return checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	else if (req == t_str()) return checkExpr(lhs, t_str(), checkExpr(rhs, t_str(), env));
	else if (req == t_bool()) return checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env));
	else if (req == t_list()) return checkExpr(lhs, t_list(), checkExpr(rhs, t_list(), env));
	else 	return addError(env, Expr@location, expected(req, "unexpected type")); 
}

TENV checkExpr(Expr:gtExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The greater-than operator (\>) expects two numeric values on either side, but was given something else.");

TENV checkExpr(Expr:gteExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The greater-than-or-equal operator (\>=) expects two numeric values on either side, but was given something else.");


TENV checkExpr(Expr:ltExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The less-than operator (\<) expects two numeric values on either side, but was given something else.");	
							  

TENV checkExpr(Expr:lteExpr(Expr lhs, Expr rhs), Type req, TENV env) =
	req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The less-than-or-equal operator (\<=) expects two numeric values on either side, but was given something else.");
							  
// Statements
TENV checkStmt(Stmt:exprStmt(Expr expr), Type req, TENV env) = 
	checkExpr(expr, t_num(), env);

TENV checkStmt(Stmt:decl(Type datatype, str id) , Type req, TENV env) {
	if (env.symbols[id]?) return addError(env, Stmt@location, "Already declared variable found, you cannot declare the same variable twice.");
	else return addSymbol(env, id, datatype);
}
	
