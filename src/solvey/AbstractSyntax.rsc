// Abstract syntax tree for Solvey DSL.
// Author: Youri Reijne

module Solvey::AbstractSyntax

import ParseTree;
import Solvey::ConcreteSyntax;

data Boolean = b_true() 
						| b_false(); 

data Program = program(list[Stmt] statements); 

//data Block = block(); 

data Type = t_str() 
				   | t_num()  
				   | t_bool() 
				   | t_list(); 

data Expr = idExpr(str id) 
				  | strExpr(str string) 
				  | numExpr(int number) 
				  | boolExpr(Boolean boolean) 
				  | listExpr(list[Expr]  items) 
				  | funCall(str id, list[Expr] args) 
				  | bracketExpr(Expr expr)
				  
				  | powExpr(Expr lhs, Expr rhs) 
				  | mulExpr(Expr lhs, Expr rhs) 
				  | divExpr(Expr lhs, Expr rhs) 
				  | modExpr(Expr lhs, Expr rhs) 
				  | minExpr(Expr lhs, Expr rhs) 
				  | addExpr(Expr lhs, Expr rhs) 
				  
				  | andExpr(Expr lhs, Expr rhs) 
				  | orExpr(Expr lhs, Expr rhs) 
				  | notExpr(Expr expr) 
				  
				  | eqExpr(Expr lhs, Expr rhs) 
				  | gtExpr(Expr lhs, Expr rhs) 
				  | gteExpr(Expr lhs, Expr rhs) 
				  | ltExpr(Expr lhs, Expr rhs) 
				  | lteExpr(Expr lhs, Expr rhs) 
				  
				  | inputExpr()
				  ;

data Stmt = exprStmt(Expr expr) 
				   | decl(Type datatype, str id) 
				   | listDecl(Type datatype, str id) 
				   | returnStmt(Expr expr) 
				   | assStmt(str id, Expr expr)  
				   | outputStmt(Expr expr) 
				   | ifStmt(Expr cond, list[Stmt] block) 
				   | ifElseStmt(Expr cond, list[Stmt] thenBlock, list[Stmt] elseBlock) 
				   | repeatStmt(int iter, list[Stmt]block) 
				   | whileStmt(Expr cond, list[Stmt] block) 
				   | funDef(Type datatype, str id, list[Parameter] parameters, list[Stmt] block); 

data Parameter = parameter(Type datatype, str id); 

anno loc Program@location;

anno loc Expr@location;
anno loc Stmt@location;


public Program sly_build(loc file) = implode(#Program, sly_parse(file)); 
