module Solvey::ConcreteSyntax

import ParseTree;

//extend lang::std::Layout;
extend lang::std::Id;

//lexical Id
//  = id: ([a-zA-Z_$] [a-zA-Z0-9_$]* !>> [a-zA-Z0-9_$]) sval \ Keyword;

// Types of the solvey language
lexical String = ![\"]*;
//lexical Number = @category="Value" ([0-9]+([.][0-9]+?)?);
lexical Number = [0-9]+;
	 					   //|  [0-9]+"."[0-9]+;
	 					   
syntax Boolean = b_true: "true"
							| b_false: "false";

// Identifier cannot be a defined keyword.
lexical ID = Id \ Keyword;

// Borrowed from Riemer ;)
layout LAYOUTLIST
  = LAYOUT* !>> [\t-\n \r \ ] !>> "//" !>> "/*";

lexical LAYOUT
  = Comment
  | [\t-\n \r \ ];
  
lexical Comment
  = "/*" (![*] | [*] !>> [/])* "*/" 
  | "//" ![\n]* $;

//layout Whitespace = whitespace: [\t-\n\r\ ]* spacing ; // << already imported

// Program syntax
start syntax Program = program: Stmt* statements;

// Block of code
//syntax Block = block: Stmt* statements;

// All types
syntax Type = t_str:"string" | t_num:"number" | t_bool:"bool" | t_list:"list";

// All possible expressions
syntax Expr = idExpr: ID id !>> "("
					  | strExpr: "\""String string "\""
					  | numExpr: Number number
					  | boolExpr: Boolean boolean
					  | listExpr: "[" {Expr ","}* items "]"
					  > inputExpr:"input" "(" ")"
					  > funCall: ID id "(" {Expr ","}* args")"
					  > bracketExpr: "(" Expr e ")"
					  
					  > left ( left powExpr: Expr lhs "**" Expr rhs
					  			 | left powExpr: Expr lhs "^" Expr rhs)
					  			 
					  > left ( left mulExpr: Expr lhs "*" Expr rhs
					    		 | left divExpr: Expr lhs "/" Expr rhs
					    		 | left modExpr: Expr lhs "%" Expr rhs)
					    		 
					   >left ( left addExpr: Expr lhs "+" Expr rhs
					   	         | left minExpr: Expr lhs "-" Expr rhs)
					  
					  > left ( left andExpr: Expr lhs "and" Expr rhs
					  			| left andExpr: Expr lhs "&&" Expr rhs
					  			| left orExpr: Expr lhs "or" Expr rhs
					  			| left orExpr: Expr lhs "||" Expr rhs)
					  			
					  >right ( right notExpr: "not" Expr expr 
					  			  | right notExpr: "!" Expr expr) 
					  			  
					  > non-assoc ( non-assoc eqExpr: Expr lhs "==" Expr rhs
					  						 | non-assoc gtExpr: Expr lhs "\>" Expr rhs
					  						 | non-assoc gteExpr: Expr lhs "\>=" Expr rhs
					  						 | non-assoc ltExpr: Expr lhs "\<" Expr rhs
					  						 | non-assoc lteExpr: Expr lhs "\<=" Expr rhs) 
					  ;

// All possible statements
syntax Stmt = exprStmt: Expr expr
					   | decl: Type datatype ID id
					   | listDecl: "list" "[" Type datatype "]" ID id
					   | returnStmt: "return" Expr expr
					   | assStmt: ID id ":=" Expr expr
					   | outputStmt: "output" "(" Expr expr ")"
					   | ifStmt: "if" "(" Expr cond ")"  Stmt* block "end" "if"
					   | ifElseStmt: "if" "(" Expr cond ")"  Stmt* thenBlock "else" Stmt* elseBlock "end" "if"
					   | repeatStmt: "repeat" "(" Number iter ")" Stmt* block "end" "repeat"
					   | whileStmt: "while" "(" Expr cond ")"  Stmt* block "end" "while"
					   | funDef: Type datatype "function" ID id "(" {Parameter ","}* parameters ")"  Stmt* block "end" "function";

syntax Parameter = parameter: Type datatype ID id;

keyword Keyword = "string" | "number" | "bool" | "list" |
									"function" | "end" | "return" | 
									"input" | "output" |
									"if" | "else" | "repeat" | "while" | 
									"and" | "or" | "not" |
									"&&" | "||" | "!" |
									"true" | "false" |
									"==" | "\>" | "\>=" | "\<" | "\<=" |
									"**" | "^" | "*" | "/" | "%" | "+" | "-"
									;
									
// Keep track of the locations in the code
anno loc ID@location;
anno loc Comment@location;
anno loc Expr@location;
anno loc Stmt@location;

public start[Program] sly_parse(str input, loc file) = parse(#start[Program], input, file);
  
public start[Program] sly_parse(loc file) = parse(#start[Program], file);