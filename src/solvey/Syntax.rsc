module solvey::Syntax

import ParseTree;

//extend lang::std::Layout;
extend lang::std::Id;

//lexical Id
//  = id: ([a-zA-Z_$] [a-zA-Z0-9_$]* !>> [a-zA-Z0-9_$]) sval \ Keyword;

// Types of the solvey language
lexical String = string: "\"" ![\"]*  "\"";
lexical Number 
 	= 	number: [0-9]+val
	 |  number: [0-9]+"."[0-9]+val;
lexical Boolean = boolean: "true" | "false";

// Identifier cannot be a defined keyword.
lexical ID = Id \ Keyword;

// Ending a statement or definition
lexical End = "end";

// Borrowed from Riemer ;)
layout LAYOUTLIST
  = LAYOUT* !>> [\t-\n \r \ ] !>> "//" !>> "/*";

lexical LAYOUT
  = Comment
  | [\t-\n \r \ ];
  
lexical Comment
  = "/*" (![*] | [*] !>> [/])* "*/" 
  | "//" ![\n]* [\n];

//layout Whitespace = whitespace: [\t-\n\r\ ]* spacing ; // << already imported

// Program syntax
start syntax Program = program: Snippet* snippets;

// Snippet intermediate either decl or stmt
syntax Snippet = snippet: Decl decl 
						   | snippet: Stmt stmt;

// Block of code
syntax Block = block: Snippet* snippets;

syntax Type = string:"string" 
					  | number: "number" 
					  | boolean: "bool";

// Declaration of a variable type
syntax Decl = decl: Type datatype ID id;
					  //|  decl: "number" datatype ID id
					  //|  decl: "bool" datatype ID id;

//syntax Decl = strDecl: "string" datatype ID id "=" Expr expr
//					  |  numDecl: "number" datatype ID id "=" Expr expr
//					  |  boolDecl: "bool" datatype ID id "=" Expr expr;

// All possible expressions
syntax Expr = idExpr: ID id
					  > strExpr: String string
					  > numExpr: Number number
					  > boolExpr: Boolean boolean
					  > funCall: Id id "(" Arguments args ")"
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
					   | returnStmt: "return" Expr expr
					   | assStmt: ID id "=" Expr expr
					   | ifStmt: "if" "(" Expr cond ")"  Block block End "if"
					   | repeatStmt: "repeat" "(" Number iter")" Block block End "repeat"
					   | whileStmt: "while" "(" Expr cond ")"  Block block End "while"
					   | funDef: Type datatype "function" ID id "(" Parameters parameters ")"  Block block End "function";

syntax Arguments = ID*;

syntax Parameters = Parameter*;

syntax Parameter = parameter: Type datatype ID id;

// Individual statement's syntax 
//syntax Expr_stmt = exprStmt: "e:" Expr expr;
//syntax Assign_stmt = assStmt: ID id "=" Expr expr;
//syntax If_stmt = ifStmt: "if" "(" Expr cond ")" "{" Block block"}";
//syntax Repeat_stmt = repeatStmt: "repeat" "(" Number iter")" "{" Block block"}";

keyword Keyword = 	"string" | "number" | "bool" | 
									"function" | "end" | "return" | 
									"if" | "else" | "repeat" | "while" | 
									"and" | "or" | "not" |
									"&&" | "||" | "!" |
									"true" | "false" |
									"==" | "\>" | "\>=" | "\<" | "\<=" |
									"**" | "^" | "*" | "/" | "%" | "+" | "-"
									;
									
// Keep track of the locations in the code
anno loc ID@location;

anno loc Program@location;
anno loc Snippet@location;
anno loc Block@location;

anno loc Expr@location;
anno loc Stmt@location;

public start[Program] sly_parse(str input, loc file) = 
  parse(#start[Program], input, file);
  
public start[Program] sly_parse(loc file) = 
  parse(#start[Program], file);
  
 public Tree sly_parse_tree(loc file) = 
  parse(#start[Program], file);