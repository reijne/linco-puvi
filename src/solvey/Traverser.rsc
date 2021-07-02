//This is a generated file, do not manually alter unless you absolutely know what you're doing, and 
//dont mind getting your work overwritten upon next generation.

 // Traverser module implementing a custom labeled traversal of a Solvey AST
module solvey::Traverser
import solvey::AST;

public str startLabeledTraverse(Program p) = labeledTraverse(p);
private str labeledTraverse(t_list()) = 
    "in_Type_t_list
    out_Type_t_list";

private str labeledTraverse(t_str()) = 
    "in_Type_t_str
    out_Type_t_str";

private str labeledTraverse(t_num()) = 
    "in_Type_t_num
    out_Type_t_num";

private str labeledTraverse(t_bool()) = 
    "in_Type_t_bool
    out_Type_t_bool";

private str labeledTraverse(funCall(str id,list[Expr] args))  =
"in_Expr_funCall
_in_Expr_args
"+"<for (argsItem <- args){><labeledTraverse(argsItem)>\n<}>"[..-1]+"
_out_Expr_args
out_Expr_funCall";

private str labeledTraverse(divExpr(Expr lhs,Expr rhs))  =
"in_Expr_divExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_divExpr";

private str labeledTraverse(eqExpr(Expr lhs,Expr rhs))  =
"in_Expr_eqExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_eqExpr";

private str labeledTraverse(gtExpr(Expr lhs,Expr rhs))  =
"in_Expr_gtExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_gtExpr";

private str labeledTraverse(andExpr(Expr lhs,Expr rhs))  =
"in_Expr_andExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_andExpr";

private str labeledTraverse(boolExpr(Boolean boolean))  =
"in_Expr_boolExpr
_in_Boolean_boolean
<labeledTraverse(boolean)>
_out_Boolean_boolean
out_Expr_boolExpr";

private str labeledTraverse(modExpr(Expr lhs,Expr rhs))  =
"in_Expr_modExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_modExpr";

private str labeledTraverse(addExpr(Expr lhs,Expr rhs))  =
"in_Expr_addExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_addExpr";

private str labeledTraverse(numExpr(int number))  =
"in_Expr_numExpr
out_Expr_numExpr";

private str labeledTraverse(lteExpr(Expr lhs,Expr rhs))  =
"in_Expr_lteExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_lteExpr";

private str labeledTraverse(idExpr(str id))  =
"in_Expr_idExpr
out_Expr_idExpr";

private str labeledTraverse(minExpr(Expr lhs,Expr rhs))  =
"in_Expr_minExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_minExpr";

private str labeledTraverse(powExpr(Expr lhs,Expr rhs))  =
"in_Expr_powExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_powExpr";

private str labeledTraverse(bracketExpr(Expr expr))  =
"in_Expr_bracketExpr
_in_Expr_expr
<labeledTraverse(expr)>
_out_Expr_expr
out_Expr_bracketExpr";

private str labeledTraverse(gteExpr(Expr lhs,Expr rhs))  =
"in_Expr_gteExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_gteExpr";

private str labeledTraverse(listExpr(list[Expr] items))  =
"in_Expr_listExpr
_in_Expr_items
"+"<for (itemsItem <- items){> <labeledTraverse(itemsItem)>\n<}>"[..-1]+"
_out_Expr_items
out_Expr_listExpr";

private str labeledTraverse(ltExpr(Expr lhs,Expr rhs))  =
"in_Expr_ltExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_ltExpr";

private str labeledTraverse(strExpr(str string))  =
"in_Expr_strExpr
out_Expr_strExpr";

private str labeledTraverse(mulExpr(Expr lhs,Expr rhs))  =
"in_Expr_mulExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_mulExpr";

private str labeledTraverse(notExpr(Expr expr))  =
"in_Expr_notExpr
_in_Expr_expr
<labeledTraverse(expr)>
_out_Expr_expr
out_Expr_notExpr";

private str labeledTraverse(orExpr(Expr lhs,Expr rhs))  =
"in_Expr_orExpr
_in_Expr_lhs
<labeledTraverse(lhs)>
_out_Expr_lhs
_in_Expr_rhs
<labeledTraverse(rhs)>
_out_Expr_rhs
out_Expr_orExpr";

private str labeledTraverse(parameter(str datatype,str id))  =
"in_Parameter_parameter
out_Parameter_parameter";

private str labeledTraverse(block(list[Stmt] statements))  =
"in_Block_block
_in_Stmt_statements
"+"<for (statementsItem <- statements){> <labeledTraverse(statementsItem)>\n<}>"[..-1]+"
_out_Stmt_statements
out_Block_block";

private str labeledTraverse(program(list[Stmt] statements))  =
"in_Program_program
_in_Stmt_statements
"+"<for (statementsItem <- statements){> <labeledTraverse(statementsItem)>\n<}>"[..-1]+"
_out_Stmt_statements
out_Program_program";

private str labeledTraverse(b_false()) = 
    "in_Boolean_b_false
    out_Boolean_b_false";

private str labeledTraverse(b_true()) = 
    "in_Boolean_b_true
    out_Boolean_b_true";

private str labeledTraverse(decl(Type datatype,str id))  =
"in_Stmt_decl
_in_Type_datatype
<labeledTraverse(datatype)>
_out_Type_datatype
out_Stmt_decl";

private str labeledTraverse(returnStmt(Expr expr))  =
"in_Stmt_returnStmt
_in_Expr_expr
<labeledTraverse(expr)>
_out_Expr_expr
out_Stmt_returnStmt";

private str labeledTraverse(funDef(Type datatype,str id,list[Parameter] parameters,Block block))  =
"in_Stmt_funDef
_in_Type_datatype
<labeledTraverse(datatype)>
_out_Type_datatype
_in_Parameter_parameters
"+"<for (parametersItem <- parameters){> <labeledTraverse(parametersItem)>\n<}>"[..-1]+"
_out_Parameter_parameters
_in_Block_block
<labeledTraverse(block)>
_out_Block_block
out_Stmt_funDef";

private str labeledTraverse(outputStmt(Expr expr))  =
"in_Stmt_outputStmt
_in_Expr_expr
<labeledTraverse(expr)>
_out_Expr_expr
out_Stmt_outputStmt";

private str labeledTraverse(inputStmt()) = 
    "in_Stmt_inputStmt
    out_Stmt_inputStmt";

private str labeledTraverse(whileStmt(Expr cond,Block block))  =
"in_Stmt_whileStmt
_in_Expr_cond
<labeledTraverse(cond)>
_out_Expr_cond
_in_Block_block
<labeledTraverse(block)>
_out_Block_block
out_Stmt_whileStmt";

private str labeledTraverse(exprStmt(Expr expr))  =
"in_Stmt_exprStmt
_in_Expr_expr
<labeledTraverse(expr)>
_out_Expr_expr
out_Stmt_exprStmt";

private str labeledTraverse(ifStmt(Expr cond,Block block))  =
"in_Stmt_ifStmt
_in_Expr_cond
<labeledTraverse(cond)>
_out_Expr_cond
_in_Block_block
<labeledTraverse(block)>
_out_Block_block
out_Stmt_ifStmt";

private str labeledTraverse(ifElseStmt(Expr cond,Block thenBlock,Block elseBlock))  =
"in_Stmt_ifElseStmt
_in_Expr_cond
<labeledTraverse(cond)>
_out_Expr_cond
_in_Block_thenBlock
<labeledTraverse(thenBlock)>
_out_Block_thenBlock
_in_Block_elseBlock
<labeledTraverse(elseBlock)>
_out_Block_elseBlock
out_Stmt_ifElseStmt";

private str labeledTraverse(assStmt(str id,Expr expr))  =
"in_Stmt_assStmt
_in_Expr_expr
<labeledTraverse(expr)>
_out_Expr_expr
out_Stmt_assStmt";

private str labeledTraverse(repeatStmt(int iter,Block block))  =
"in_Stmt_repeatStmt
_in_Block_block
<labeledTraverse(block)>
_out_Block_block
out_Stmt_repeatStmt";

