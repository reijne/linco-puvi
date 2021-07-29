//This is a generated file, do not manually alter unless you absolutely know what you're doing, and 
//dont mind getting your work overwritten upon next generation.

 // Traverser module implementing a custom labeled traversal of a Solvey AST
module Solvey::Traverser
import Solvey::AbstractSyntax;

private str labeledTraverse(t_list()) = 
    "in-Type-t_list
    out-Type-t_list";

private str labeledTraverse(t_str()) = 
    "in-Type-t_str
    out-Type-t_str";

private str labeledTraverse(t_num()) = 
    "in-Type-t_num
    out-Type-t_num";

private str labeledTraverse(t_bool()) = 
    "in-Type-t_bool
    out-Type-t_bool";

public str labeledTraverse(funCall(str id,list[Expr] args))  =
"in-Expr-funCall
-in-list[Expr]-args
"+"<for (argsItem <- args){><labeledTraverse(argsItem)>\n<}>"[..-1]+"
-out-Expr-args
out-Expr-funCall";

public str labeledTraverse(divExpr(Expr lhs,Expr rhs))  =
"in-Expr-divExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-divExpr";

public str labeledTraverse(eqExpr(Expr lhs,Expr rhs))  =
"in-Expr-eqExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-eqExpr";

public str labeledTraverse(gtExpr(Expr lhs,Expr rhs))  =
"in-Expr-gtExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-gtExpr";

public str labeledTraverse(andExpr(Expr lhs,Expr rhs))  =
"in-Expr-andExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-andExpr";

public str labeledTraverse(boolExpr(Boolean boolean))  =
"in-Expr-boolExpr
-in-Boolean-boolean
<labeledTraverse(boolean)>
-out-Boolean-boolean
out-Expr-boolExpr";

public str labeledTraverse(modExpr(Expr lhs,Expr rhs))  =
"in-Expr-modExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-modExpr";

public str labeledTraverse(addExpr(Expr lhs,Expr rhs))  =
"in-Expr-addExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-addExpr";

public str labeledTraverse(numExpr(int number))  =
"in-Expr-numExpr
out-Expr-numExpr";

public str labeledTraverse(lteExpr(Expr lhs,Expr rhs))  =
"in-Expr-lteExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-lteExpr";

public str labeledTraverse(idExpr(str id))  =
"in-Expr-idExpr
out-Expr-idExpr";

public str labeledTraverse(minExpr(Expr lhs,Expr rhs))  =
"in-Expr-minExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-minExpr";

public str labeledTraverse(powExpr(Expr lhs,Expr rhs))  =
"in-Expr-powExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-powExpr";

public str labeledTraverse(bracketExpr(Expr expr))  =
"in-Expr-bracketExpr
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Expr-bracketExpr";

public str labeledTraverse(gteExpr(Expr lhs,Expr rhs))  =
"in-Expr-gteExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-gteExpr";

public str labeledTraverse(listExpr(list[Expr] items))  =
"in-Expr-listExpr
-in-list[Expr]-items
"+"<for (itemsItem <- items){><labeledTraverse(itemsItem)>\n<}>"[..-1]+"
-out-Expr-items
out-Expr-listExpr";

public str labeledTraverse(ltExpr(Expr lhs,Expr rhs))  =
"in-Expr-ltExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-ltExpr";

public str labeledTraverse(strExpr(str string))  =
"in-Expr-strExpr
out-Expr-strExpr";

public str labeledTraverse(mulExpr(Expr lhs,Expr rhs))  =
"in-Expr-mulExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-mulExpr";

public str labeledTraverse(notExpr(Expr expr))  =
"in-Expr-notExpr
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Expr-notExpr";

public str labeledTraverse(orExpr(Expr lhs,Expr rhs))  =
"in-Expr-orExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-orExpr";

public str labeledTraverse(parameter(Type datatype,str id))  =
"in-Parameter-parameter
-in-Type-datatype
<labeledTraverse(datatype)>
-out-Type-datatype
out-Parameter-parameter";

public str labeledTraverse(block(list[Stmt] statements))  =
"in-Block-block
-in-list[Stmt]-statements
"+"<for (statementsItem <- statements){><labeledTraverse(statementsItem)>\n<}>"[..-1]+"
-out-Stmt-statements
out-Block-block";

public str labeledTraverse(program(list[Stmt] statements))  =
"in-Program-program
-in-list[Stmt]-statements
"+"<for (statementsItem <- statements){><labeledTraverse(statementsItem)>\n<}>"[..-1]+"
-out-Stmt-statements
out-Program-program";

private str labeledTraverse(b_false()) = 
    "in-Boolean-b_false
    out-Boolean-b_false";

private str labeledTraverse(b_true()) = 
    "in-Boolean-b_true
    out-Boolean-b_true";

public str labeledTraverse(decl(Type datatype,str id))  =
"in-Stmt-decl
-in-Type-datatype
<labeledTraverse(datatype)>
-out-Type-datatype
out-Stmt-decl";

public str labeledTraverse(funDef(Type datatype,str id,list[Parameter] parameters,Block block))  =
"in-Stmt-funDef
-in-Type-datatype
<labeledTraverse(datatype)>
-out-Type-datatype
-in-list[Parameter]-parameters
"+"<for (parametersItem <- parameters){><labeledTraverse(parametersItem)>\n<}>"[..-1]+"
-out-Parameter-parameters
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-funDef";

public str labeledTraverse(outputStmt(Expr expr))  =
"in-Stmt-outputStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-outputStmt";

private str labeledTraverse(inputStmt()) = 
    "in-Stmt-inputStmt
    out-Stmt-inputStmt";

public str labeledTraverse(whileStmt(Expr cond,Block block))  =
"in-Stmt-whileStmt
-in-Expr-cond
<labeledTraverse(cond)>
-out-Expr-cond
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-whileStmt";

public str labeledTraverse(returnStmt(Expr expr))  =
"in-Stmt-returnStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-returnStmt";

public str labeledTraverse(listDecl(Type datatype,str id))  =
"in-Stmt-listDecl
-in-Type-datatype
<labeledTraverse(datatype)>
-out-Type-datatype
out-Stmt-listDecl";

public str labeledTraverse(exprStmt(Expr expr))  =
"in-Stmt-exprStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-exprStmt";

public str labeledTraverse(ifStmt(Expr cond,Block block))  =
"in-Stmt-ifStmt
-in-Expr-cond
<labeledTraverse(cond)>
-out-Expr-cond
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-ifStmt";

public str labeledTraverse(ifElseStmt(Expr cond,Block thenBlock,Block elseBlock))  =
"in-Stmt-ifElseStmt
-in-Expr-cond
<labeledTraverse(cond)>
-out-Expr-cond
-in-Block-thenBlock
<labeledTraverse(thenBlock)>
-out-Block-thenBlock
-in-Block-elseBlock
<labeledTraverse(elseBlock)>
-out-Block-elseBlock
out-Stmt-ifElseStmt";

public str labeledTraverse(assStmt(str id,Expr expr))  =
"in-Stmt-assStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-assStmt";

public str labeledTraverse(repeatStmt(int iter,Block block))  =
"in-Stmt-repeatStmt
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-repeatStmt";

