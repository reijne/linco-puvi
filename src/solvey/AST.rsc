// Abstract syntax tree for Solvey DSL.
// Author: Youri Reijne
//
// NOTE** Utilise double slash "//" at the end of a line to exclude it from the mapping in Showey

module solvey::ast

import ParseTree;
import solvey::syntax_concrete;

data Boolean = b_true() 
						| b_false(); 

data Program = program(list[Stmt] statements); // <- Exclude from visualisation mapping 

//data Snippet = declSnip(Decl decl)
//						| stmtSnip(Stmt stmt);

data Block = block(list[Stmt] statements); // <- Exclude from visualisation mapping 

data Type = t_str() 
				   | t_num()  
				   | t_bool() 
				   | t_list(); 

//data WhiteSpace = space(list[str] spacing);

//data Decl = decl(Type datatype, str id);
				  
//data Decl = strDecl(str datatype, str, id, Expr expr)
//				  | numDecl(str datatype, str, id, Expr expr)
//				  | boolDecl(str datatype, str id, Expr expr);

//data Arguments = noargs() 
//							   | arguments(Expr arg1, list[Expr] argrest);
//data Arguments = arguments);

//data Items = emptyList()
//					| items(Expr item1, list[Expr] items);

data Expr = idExpr(str id) 
				  | strExpr(str string) 
				  | numExpr(int number) 
				  | boolExpr(Boolean boolean) 
				  | listExpr(list[Expr]  items) 
				  | funCall(str id, list[Expr] args) 
				  //| bracketExp(Expr expr)
				  
				  | powExpr(Expr lhs, Expr rhs) 
				  | mulExpr(Expr lhs, Expr rhs) 
				  | divExpr(Expr lhs, Expr rhs) 
				  | modExpr(Expr lhs, Expr rhs) 
				  | addExpr(Expr lhs, Expr rhs) 
				  | minExpr(Expr lhs, Expr rhs) 
				  
				  | andExpr(Expr lhs, Expr rhs) 
				  | orExpr(Expr lhs, Expr rhs) 
				  | notExpr(Expr expr) 
				  
				  | eqExpr(Expr lhs, Expr rhs) 
				  | gtExpr(Expr lhs, Expr rhs) 
				  | gteExpr(Expr lhs, Expr rhs) 
				  | ltExpr(Expr lhs, Expr rhs) 
				  | lteExpr(Expr lhs, Expr rhs) 
				  ;

data Stmt = exprStmt(Expr expr) 
				   | decl(Type datatype, str id) 
				   | returnStmt(Expr expr) 
				   | assStmt(str id, Expr expr) 
				   | inputStmt() 
				   | outputStmt(Expr expr) 
				   | ifStmt(Expr cond, Block block) 
				   | ifElseStmt(Expr cond, Block thenBlock, Block elseBlock) 
				   | repeatStmt(int iter, Block block) 
				   | whileStmt(Expr cond, Block block) 
				   | funDef(Type datatype, str id, list[Parameter] parameters, Block block); 

data Parameter = parameter(str datatype, str id); 

//data Arguments = arguments(list[Expr] exprs);
//noArgs()
//							  | oneArg(Expr expr) 
//							  | nArgs(list[Expr]);
//data Expr_stmt = exprStmt(Expr expr);
//data Assign_stmt = assStmt(str id, Expr expr);
//data If_stmt = ifStmt(Expr cond, Block block);
//data Repeat_stmt = repeatStmt(real iter, Block block);

//anno loc String@location;
//anno loc Number@location;
//anno loc Boolean@location;

//anno loc ID@location;
//
//anno loc Program@location;
//
//anno loc Block@location;
//
//anno loc Expr@location;
//anno loc Stmt@location;


public Program sly_build(loc file) = implode(#Program, sly_parse(file)); // <- Exclude from visualisation mapping