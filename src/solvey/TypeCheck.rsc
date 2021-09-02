module Solvey::TypeCheck

import Prelude;
import Solvey::AbstractSyntax;
import Solvey::ConcreteSyntax;

private alias Name = str;
// https://tutor.rascal-mpl.org/Recipes/Languages/Pico/Typecheck/Typecheck.html#/Recipes/Languages/Pico/Typecheck/Typecheck.html

// Type environment, 
// Symbols :: variables, functions with their corresponding type
// FunParams :: the parameters and types for a defined function
// Errors :: A collection of all the found errors while type checking the program
alias TENV = tuple[ map[Name, Type] symbols, map[Name, list[tuple[Name,Type]]] funParams, list[tuple[loc l, int nid, str msg]] errors];

// Last defined function
str lastFunc = "";
// Boolean used for nested function checking
bool inFunc = false;
// Boolean used for return checking
bool hasReturned = false;
// Integer used for keeping track which node has an error
int nodeID = -1;

// Add a variable and its type to the symboltable in the type environment
TENV addSymbol(TENV env, Name name, Type t) {
	env.symbols[name] = t;
	return env;
} 

// Get all the errors in a concatenated string
str getErrorString(TENV env) {
	str errorstring = "";
	for (tuple[loc l, int nid, str msg] e <- env.errors) 
		errorstring += "<e.nid>|<e.msg>\n";
	return errorstring == "" ? errorstring : errorstring[..-1];
}

// Add an error message to type environment
TENV addError(TENV env, loc l, str msg) = env[errors = env.errors + <l, nodeID, msg>];

// Constructing an expected type message
str expected(Type t, str got) = "Expected <out(t)>, got <got>";                 
str expected(Type t, Type got) = "Expected <out(t)>, got <out(got)>";  

// Return the verbose form of a type
str out(t_num()) = "number";
str out(t_str()) = "string";
str out(t_bool()) = "bool";
str out(t_list()) = "list[]";
str out(t_undefined()) = "undefined";

// Location based wrapper for checkProgram, envokes the building into AST.
TENV checkProgram(loc l) = checkProgram(sly_build(l));

// Entry point for typechecking on Program type
TENV checkProgram(Program p) {
	nodeID = 0; // Reset the nodeID so the first stmt is at 0
	if(program(list[Stmt] statements) := p){
     env = <(),(),[]>;
     for (stmt <- statements) env = checkStmt(stmt, env);
     return env;
  } else
    throw "Cannot happen";
}

tuple[bool, Type] getParam(str id, TENV env) {
	for (tuple[Name, Type] param <- env.funParams[lastFunc]) {
		if (param[0] == id) {
			return <true, param[1]>;
		}
	} 
	return <false, t_list()>;
}

TENV checkType(Type t, TENV env) {
	nodeID += 1;
	return env;
}

TENV checkBoolean(Boolean b, TENV env) {
	nodeID += 1;
	return env;
}

// Expression checking
TENV checkExpr(Expr:idExpr(Name id), Type req, TENV env) {
	nodeID += 1;
	if (inFunc) {
		tuple[bool, Type] paramType = getParam(id, env);
		if (!paramType[0]) 
			if (!env.symbols[id]?) return addError(env, Expr@location, "Undeclared Variable <id>"); 
			else return req == env.symbols[id] ? env : addError(env, Expr@location, expected(req, env.symbols[id]));
		else {
			return req == paramType[1] ? env : addError(env, Expr@location, expected(req, paramType[1]));
		}
	} else {
		if (!env.symbols[id]?) return addError(env, Expr@location, "Undeclared Variable <id>");
		return req == env.symbols[id] ? env : addError(env, Expr@location, expected(req, env.symbols[id]));
	}
}

// Typed expressions
TENV checkExpr(Expr:strExpr(str string), Type req, TENV env) {
	nodeID += 1; 
	return req == t_str() ? env : addError(env, Expr@location, expected(req, "string"));
} 
	
TENV checkExpr(Expr:numExpr(int number), Type req, TENV env) {
	nodeID += 1;
	return req == t_num() ? env : addError(env, Expr@location, expected(req, "number")); 
}

TENV checkExpr(Expr:boolExpr(Boolean boolean), Type req, TENV env) {
	nodeID += 1;
	checkBoolean(boolean, env); 
	return req == t_bool() ? env : addError(env, Expr@location, expected(req, "boolean"));
} 

// List expression, check every element
TENV checkExpr(Expr:listExpr(list[Expr] items), Type req, TENV env) {
	nodeID += 1; 
	for (item <- items) env = checkExpr(item, req, env);
	return env;
}

// TODO add this from the list of inputs
TENV checkExpr(Expr:inputExpr(), Type req, TENV env) {
	nodeID += 1; 
	return env;
}

// Function call, check if its defined, and check all the arguments
TENV checkExpr(Expr:funCall(str id, list[Expr] args), Type req, TENV env) {
	nodeID += 1; 
	if (!env.symbols[id]?) env = addError(env, Expr@location, "Undeclared Function <id> called");
	if (size(env.funParams[id]) != size(args)) 
		env = addError(env, Expr@location, "<out(req)> function <id> expects <size(env.funParams[id])> arguments, but got <size(args)>");
	for (i <- [0 .. size(env.funParams[id])]) {
		if (i >= size(args)) break;
		env = checkExpr(args[i], env.funParams[id][i][1], env);
	}
	return env;
}

TENV checkExpr(Expr:bracketExpr(Expr expr), Type req, TENV env) {
	nodeID += 1; 
	return checkExpr(expr, req, env);
}

// Arithmetic Expressions
TENV checkExpr(Expr:powExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_num() ? env1 : env2;
}			
							  
TENV checkExpr(Expr:mulExpr(Expr lhs, Expr rhs), Type req, TENV env)  {
	nodeID += 1; 
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_num() ?  env1 : env2;
}							  
	
TENV checkExpr(Expr:divExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_num() ? env1 : env2;
}
							  
TENV checkExpr(Expr:modExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_num() ? env1 : env2;
}							  
							  
TENV checkExpr(Expr:minExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_num() ? env1 : env2;
}

// Addition expression which also support string type
TENV checkExpr(Expr:addExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	if (req == t_num()) return checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	else if (req == t_str()) return checkExpr(lhs, t_str(), checkExpr(rhs, t_str(), env));
	env = addError(env, Expr@location, expected(req, "unexpected type")); 
	checkExpr(lhs, t_str(), checkExpr(rhs, t_str(), env));
	return env;
}

TENV checkExpr(Expr:andExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env));
	return req == t_bool() ? env1 : env2;
}

TENV checkExpr(Expr:orExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env));
	return req == t_bool() ? env1 : env2;
}						
							  
TENV checkExpr(Expr:notExpr(Expr expr), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, expected(req, "unexpected type"));
	env1 = checkExpr(expr, t_bool(), env);
	return req == t_bool() ? env1 : env2; 						  
}

// Comparison expressions 
TENV checkExpr(Expr:eqExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	checkExpr(lhs, t_undefined(), checkExpr(rhs, t_undefined(), env));
	return env;  
}

TENV checkExpr(Expr:gtExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, "The greater-than operator (\>) expects two numeric values to compare and results in a boolean, but another resulting type was expected: <req>.");
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)); 
	return req == t_bool() ? env1 : env2; 	
}

TENV checkExpr(Expr:gteExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, "The greater-than-or-equal operator (\>=) expects two numeric values to compare and results in a boolean, but another resulting type was expected: <req>.");
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_bool() ? env1 : env2; 	
}

TENV checkExpr(Expr:ltExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, "The less-than operator (\<) expects two numeric values to compare and results in a boolean, but another resulting type was expected: <req>.");	
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_bool() ? env1 : env2; 	
}							  

TENV checkExpr(Expr:lteExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env2 = addError(env, Expr@location, "The less-than-or-equal operator (\<=) expects two numeric values to compare and results in a boolean, but another resulting type was expected: <req>.");
	env1 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	return req == t_bool() ? env1 : env2; 	
}

//							  
// Statements
//
TENV checkStmt(Stmt:exprStmt(Expr expr), TENV env) {
	nodeID += 1;
	return checkExpr(expr, t_undefined(), env);
}

TENV checkStmt(Stmt:decl(Type datatype, str id), TENV env) {
	checkType(datatype, env);
	nodeID += 1;
	if (env.symbols[id]?) return addError(env, Stmt@location, "Already declared variable found, you can only declare a variable once.");
	else return addSymbol(env, id, datatype);
}

TENV checkStmt(Stmt:listDecl(Type datatype, str id), TENV env) {
	checkType(datatype, env);
	nodeID += 1;
	if (env.symbols[id]?) return addError(env, Stmt@location, "Already declared variable found, you cannot declare a variable once.");
	else return addSymbol(env, id, t_list());
}

TENV checkStmt(Stmt:returnStmt(Expr expr), TENV env) {
	nodeID += 1;
	if (!env.symbols[lastFunc]?) env = addError(env, Stmt@location, "Return outside Function body. Cannot return any value if not inside a Function.");
	hasReturned = true;
	return checkExpr(expr, env.symbols[lastFunc], env);
}

TENV checkStmt(Stmt:assStmt(str id, Expr expr), TENV env) {
	nodeID += 1;
	if (!env.symbols[id]?) {
		env = addError(env, Stmt@location, "Variable not found. Attempting to assign a value to an undeclared variable.");
		checkExpr(expr, t_undefined(), env);
		return env;
	}
	return checkExpr(expr, env.symbols[id], env);
}

// TODO figure out how to fucking make any type required lol
TENV checkStmt(Stmt:outputStmt(Expr expr), TENV env) {
	nodeID += 1;
	return env;
}

TENV checkStmt(Stmt:ifStmt(Expr cond, list[Stmt] block) , TENV env) {
	nodeID += 1;
	env = checkExpr(cond, t_bool(), env);
	for (stmt <- block) env = checkStmt(stmt, env);
	return env;
}

TENV checkStmt(Stmt:ifElseStmt(Expr cond, list[Stmt] thenBlock, list[Stmt] elseBlock) , TENV env) {
	nodeID += 1;
	env = checkExpr(cond, t_bool(), env);
	for (stmt <- (thenBlock + elseBlock)) env = checkStmt(stmt, env);
	return env;
}

TENV checkStmt(Stmt:repeatStmt(int iter, list[Stmt]block), TENV env) {
	nodeID += 1;
	for (stmt <- block) env = checkStmt(stmt, env);
	return env;
}

TENV checkStmt(Stmt:whileStmt(Expr cond, list[Stmt] block), TENV env) {
	nodeID += 1;
	env = checkExpr(cond, t_bool(), env);
	for (stmt <- block) env = checkStmt(stmt, env);
	return env;
}

TENV checkStmt(Stmt:funDef(Type datatype, str id, list[Parameter] parameters, list[Stmt] block), TENV env) {
	checkType(datatype, env);
	nodeID += 1;
	if (env.symbols[id]?) env = addError(env, Stmt@location, "Function redeclaration. Overwriting already existing variable or Function by this definition.");
	if (inFunc) env = addError(env, Stmt@location, "Nested Functions. Trying to declare a Function within a Function is not supported.");
	inFunc = true;
	hasReturned = false;
	lastFunc = id;
	env.symbols[id] = datatype;
	env = addParameters(id, parameters, env);
	for (stmt <- block) env = checkStmt(stmt, env);
	if (!hasReturned) env = addError(env, Stmt@location, "Missing return. <out(datatype)> function <id> needs to return a <out(datatype)> value");
	inFunc = false;
	return env;
}

TENV addParameters(str id, list[Parameter] parameters, TENV env) {
	list[tuple[Name,Type]] paramTypes = [];
	for (param <- parameters) {
		paramTypes = addParam(param, paramTypes, env);
	}
	env.funParams[id] = paramTypes;
	return env;
}

list[tuple[Name,Type]] addParam(parameter(Type datatype, str id), list[tuple[Name,Type]] paramTypes, TENV env) {
	nodeID += 1;
	checkType(datatype, env);
	return paramTypes += <id, datatype>;
}
