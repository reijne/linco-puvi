module solvey::AST

import ParseTree;
import solvey::Syntax;

data TYPE = string() | number() | boolean();
//data Number = number();
//data Boolean = boolean();

data Program = program(list[Snippet] snippets);

data Snippet = snippet(Decl decl)
						| snippet(Stmt stmt);

data Block = block(list[Snippet] snippets);

//data WhiteSpace = space(list[str] spacing);

data Decl = decl(TYPE datatype, str id);
				  
//data Decl = strDecl(str datatype, str, id, Expr expr)
//				  | numDecl(str datatype, str, id, Expr expr)
//				  | boolDecl(str datatype, str id, Expr expr);

data Expr = idExpr(str id)
				  | strExpr(str string)
				  | numExpr(Number number)
				  | boolExpr(bool boolean)
				  | funCall(str id, list[str] args)
				  
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
				   | assStmt(str id, Expr expr)
				   | ifStmt(Expr cond, Block block)
				   | repeatStmt(num iter, Block block)
				   | whileStmt(Expr cond, Block block)
				   | funDef(TYPE datatype, str id, list[Parameter] parameters, Block block);

data Parameter = parameter(str datatype, ID id);
//data Expr_stmt = exprStmt(Expr expr);
//data Assign_stmt = assStmt(str id, Expr expr);
//data If_stmt = ifStmt(Expr cond, Block block);
//data Repeat_stmt = repeatStmt(real iter, Block block);

//anno loc String@location;
//anno loc Number@location;
//anno loc Boolean@location;

anno loc ID@location;

anno loc Program@location;
anno loc Snippet@location;
anno loc Block@location;

anno loc Expr@location;
anno loc Stmt@location;


public Program sly_build(loc file) = implode(#Program, sly_parse(file));