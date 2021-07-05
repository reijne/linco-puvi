//This is a generated file, do not manually alter unless you absolutely know what you're doing, and 
//dont mind getting your work overwritten upon next generation.

 // Traverser module implementing a custom labeled traversal of a Solvey AST
module Solvey::Traverser
import Solvey::AST;

public str startLabeledTraverse(Program p) = labeledTraverse(p);
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

private str labeledTraverse(funCall(str id,list[Expr] args))  =
"in-Expr-funCall
-in-list[Expr]-args
"+"<for (argsItem <- args){><labeledTraverse(argsItem)>\n<}>"[..-1]+"
-out-Expr-args
out-Expr-funCall";

private str labeledTraverse(divExpr(Expr lhs,Expr rhs))  =
"in-Expr-divExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-divExpr";

private str labeledTraverse(eqExpr(Expr lhs,Expr rhs))  =
"in-Expr-eqExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-eqExpr";

private str labeledTraverse(gtExpr(Expr lhs,Expr rhs))  =
"in-Expr-gtExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-gtExpr";

private str labeledTraverse(andExpr(Expr lhs,Expr rhs))  =
"in-Expr-andExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-andExpr";

private str labeledTraverse(boolExpr(Boolean boolean))  =
"in-Expr-boolExpr
-in-Boolean-boolean
<labeledTraverse(boolean)>
-out-Boolean-boolean
out-Expr-boolExpr";

private str labeledTraverse(modExpr(Expr lhs,Expr rhs))  =
"in-Expr-modExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-modExpr";

private str labeledTraverse(addExpr(Expr lhs,Expr rhs))  =
"in-Expr-addExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-addExpr";

private str labeledTraverse(numExpr(int number))  =
"in-Expr-numExpr
out-Expr-numExpr";

private str labeledTraverse(lteExpr(Expr lhs,Expr rhs))  =
"in-Expr-lteExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-lteExpr";

private str labeledTraverse(idExpr(str id))  =
"in-Expr-idExpr
out-Expr-idExpr";

private str labeledTraverse(minExpr(Expr lhs,Expr rhs))  =
"in-Expr-minExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-minExpr";

private str labeledTraverse(powExpr(Expr lhs,Expr rhs))  =
"in-Expr-powExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-powExpr";

private str labeledTraverse(bracketExpr(Expr expr))  =
"in-Expr-bracketExpr
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Expr-bracketExpr";

private str labeledTraverse(gteExpr(Expr lhs,Expr rhs))  =
"in-Expr-gteExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-gteExpr";

private str labeledTraverse(listExpr(list[Expr] items))  =
"in-Expr-listExpr
-in-list[Expr]-items
"+"<for (itemsItem <- items){><labeledTraverse(itemsItem)>\n<}>"[..-1]+"
-out-Expr-items
out-Expr-listExpr";

private str labeledTraverse(ltExpr(Expr lhs,Expr rhs))  =
"in-Expr-ltExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-ltExpr";

private str labeledTraverse(strExpr(str string))  =
"in-Expr-strExpr
out-Expr-strExpr";

private str labeledTraverse(mulExpr(Expr lhs,Expr rhs))  =
"in-Expr-mulExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-mulExpr";

private str labeledTraverse(notExpr(Expr expr))  =
"in-Expr-notExpr
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Expr-notExpr";

private str labeledTraverse(orExpr(Expr lhs,Expr rhs))  =
"in-Expr-orExpr
-in-Expr-lhs
<labeledTraverse(lhs)>
-out-Expr-lhs
-in-Expr-rhs
<labeledTraverse(rhs)>
-out-Expr-rhs
out-Expr-orExpr";

private str labeledTraverse(parameter(str datatype,str id))  =
"in-Parameter-parameter
out-Parameter-parameter";

private str labeledTraverse(block(list[Stmt] statements))  =
"in-Block-block
-in-list[Stmt]-statements
"+"<for (statementsItem <- statements){><labeledTraverse(statementsItem)>\n<}>"[..-1]+"
-out-Stmt-statements
out-Block-block";

private str labeledTraverse(program(list[Stmt] statements))  =
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

private str labeledTraverse(decl(Type datatype,str id))  =
"in-Stmt-decl
-in-Type-datatype
<labeledTraverse(datatype)>
-out-Type-datatype
out-Stmt-decl";

private str labeledTraverse(returnStmt(Expr expr))  =
"in-Stmt-returnStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-returnStmt";

private str labeledTraverse(funDef(Type datatype,str id,list[Parameter] parameters,Block block))  =
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

private str labeledTraverse(outputStmt(Expr expr))  =
"in-Stmt-outputStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-outputStmt";

private str labeledTraverse(inputStmt()) = 
    "in-Stmt-inputStmt
    out-Stmt-inputStmt";

private str labeledTraverse(whileStmt(Expr cond,Block block))  =
"in-Stmt-whileStmt
-in-Expr-cond
<labeledTraverse(cond)>
-out-Expr-cond
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-whileStmt";

private str labeledTraverse(exprStmt(Expr expr))  =
"in-Stmt-exprStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-exprStmt";

private str labeledTraverse(ifStmt(Expr cond,Block block))  =
"in-Stmt-ifStmt
-in-Expr-cond
<labeledTraverse(cond)>
-out-Expr-cond
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-ifStmt";

private str labeledTraverse(ifElseStmt(Expr cond,Block thenBlock,Block elseBlock))  =
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

private str labeledTraverse(assStmt(str id,Expr expr))  =
"in-Stmt-assStmt
-in-Expr-expr
<labeledTraverse(expr)>
-out-Expr-expr
out-Stmt-assStmt";

private str labeledTraverse(repeatStmt(int iter,Block block))  =
"in-Stmt-repeatStmt
-in-Block-block
<labeledTraverse(block)>
-out-Block-block
out-Stmt-repeatStmt";

