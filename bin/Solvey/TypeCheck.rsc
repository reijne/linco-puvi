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

str getErrorString(TENV env) {
	str errorstring = "";
	for (tuple[loc l, int nid, str msg] e <- env.errors) 
		errorstring += "<e.nid>|<e.msg>\n";
	return errorstring[..-1];
}

// Add an error message to type environment
TENV addError(TENV env, loc l, str msg) = env[errors = env.errors + <l, nodeID, msg>];

// Constructing an expected type message
str expected(Type t, str got) = "Expected a <out(t)>, got <got>";                 
str expected(Type t, Type got) = "Expected a <out(t)>, got <out(got)>";  

// Return the verbose form of a type
str out(Type t) {
	if (t == t_num()) return "number";
	if (t == t_str()) return "string";
	if (t == t_bool()) return "bool";
	if (t == t_list()) return "list[]";
	return "unkown type";
}

// Location based wrapper for checkProgram, envokes the building into AST.
TENV checkProgram(loc l) = checkProgram(sly_build(l));

// Entry point for typechecking on Program type
TENV checkProgram(Program p) {
	nodeID = 0;
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

// Expression checking
TENV checkExpr(Expr:idExpr(Name id), Type req, TENV env) {
	nodeID += 1;
	if (inFunc) {
		tuple[bool, Type] paramType = getParam(id, env);
		if (!paramType[0] && !env.symbols[id]?) return addError(env, Expr@location, "Undeclared Variable <id>"); 
		if (paramType[0]) {
			return req == paramType[1] ? env : addError(env, Expr@location, expected(req, paramType[1]));
		}
	} else {
		if (!env.symbols[id]?) return addError(env, Expr@location, "Undeclared Variable <id>");
		return req == env.symbols[id] ? env : addError(env, Expr@location, expected(req, env.symbols[id]));
	}
	throw("Cannot happen");
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
	return req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}			
							  
TENV checkExpr(Expr:mulExpr(Expr lhs, Expr rhs), Type req, TENV env)  {
	nodeID += 1; 
	return req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}							  
	
TENV checkExpr(Expr:divExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	return req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}
							  
TENV checkExpr(Expr:modExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	return req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}							  
							  
TENV checkExpr(Expr:minExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	return req == t_num() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}

// Addition expression which also support string type
TENV checkExpr(Expr:addExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1; 
	if (req == t_num()) return checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	else if (req == t_str()) return checkExpr(lhs, t_str(), checkExpr(rhs, t_str(), env));
	else 	return addError(env, Expr@location, expected(req, "unexpected type")); 
}

TENV checkExpr(Expr:andExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}

TENV checkExpr(Expr:orExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env)) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));
}						
							  
TENV checkExpr(Expr:notExpr(Expr expr), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(expr, t_bool(), env) 
							  : addError(env, Expr@location, expected(req, "unexpected type"));						  
}

// Comparison expressions 
TENV checkExpr(Expr:eqExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	env0 = checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env));
	env1 = checkExpr(lhs, t_str(), checkExpr(rhs, t_str(), env));
	env2 = checkExpr(lhs, t_bool(), checkExpr(rhs, t_bool(), env));
	env3 = checkExpr(lhs, t_list(), checkExpr(rhs, t_list(), env));
	TENV correctEnv = env0;
	for (TENV envN <- [env1, env2, env3]) if (size(envN.errors) < size(correctEnv.errors)) correctEnv = envN;
	if (correctEnv == env0 && size(env0.errors) == size(env1.errors)) 
		correctEnv = addError(env, Expr@location,"Equality expects two equal types, but this was not given");
	return correctEnv;  
}

TENV checkExpr(Expr:gtExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The greater-than operator (\>) expects two numeric values on either side, but was given something else.");
}

TENV checkExpr(Expr:gteExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The greater-than-or-equal operator (\>=) expects two numeric values on either side, but was given something else.");
}

TENV checkExpr(Expr:ltExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The less-than operator (\<) expects two numeric values on either side, but was given something else.");	
}							  

TENV checkExpr(Expr:lteExpr(Expr lhs, Expr rhs), Type req, TENV env) {
	nodeID += 1;
	return req == t_bool() ? checkExpr(lhs, t_num(), checkExpr(rhs, t_num(), env)) 
							  : addError(env, Expr@location, "The less-than-or-equal operator (\<=) expects two numeric values on either side, but was given something else.");
}

//							  
// Statements
//
TENV checkStmt(Stmt:exprStmt(Expr expr), TENV env) {
	nodeID += 1;
	return checkExpr(expr, t_num(), env);
}

TENV checkStmt(Stmt:decl(Type datatype, str id), TENV env) {
	nodeID += 1;
	if (env.symbols[id]?) return addError(env, Stmt@location, "Already declared variable found, you cannot declare a variable once.");
	else return addSymbol(env, id, datatype);
}

TENV checkStmt(Stmt:listDecl(Type datatype, str id), TENV env) {
	nodeID += 1;
	if (env.symbols[id]?) return addError(env, Stmt@location, "Already declared variable found, you cannot declare a variable once.");
	else return addSymbol(env, id, t_list());
}

TENV checkStmt(Stmt:returnStmt(Expr expr), TENV env) {
	nodeID += 1;
	if (!env.symbols[lastFunc]?) return addError(env, Stmt@location, "Return outside Function body. Cannot return any value if not inside a Function.");
	hasReturned = true;
	return checkExpr(expr, env.symbols[lastFunc], env);
}
TENV checkStmt(Stmt:assStmt(str id, Expr expr), TENV env) {
	nodeID += 1;
	if (!env.symbols[id]?) return addError(env, Stmt@location, "Variable not found. Attempting to assign a value to an undeclared variable.");
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
		paramTypes = addParam(param, paramTypes);
	}
	env.funParams[id] = paramTypes;
	return env;
}

list[tuple[Name,Type]] addParam(parameter(Type datatype, str id), list[tuple[Name,Type]] paramTypes) {
	return paramTypes += <id, datatype>;
}
