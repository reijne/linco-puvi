module solvey::syntax_concrete

import ParseTree;

//extend lang::std::Layout;
extend lang::std::Id;

//lexical Id
//  = id: ([a-zA-Z_$] [a-zA-Z0-9_$]* !>> [a-zA-Z0-9_$]) sval \ Keyword;

// Types of the solvey language
lexical String = "\"" ![\"]*  "\"";
//lexical Number = @category="Value" ([0-9]+([.][0-9]+?)?);
lexical Number = [0-9]+
	 					   |  [0-9]+"."[0-9]+;
	 					   
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
start syntax Program = program: Snippet* snippets;

// Snippet intermediate either decl or stmt
syntax Snippet = declSnip: Decl decl 
						   | stmtSnip: Stmt stmt;

// Block of code
syntax Block = block: Snippet* snippets;

syntax Type = t_str:"string" | t_num:"number" | t_bool:"bool" | t_list:"list";

// Declaration of a variable type
syntax Decl = decl: Type datatype ID id;
					  //|  decl: "number" datatype ID id
					  //|  decl: "bool" datatype ID id;

//syntax Decl = strDecl: "string" datatype ID id "=" Expr expr
//					  |  numDecl: "number" datatype ID id "=" Expr expr
//					  |  boolDecl: "bool" datatype ID id "=" Expr expr;
//syntax Arguments = noargs: "(" >> ")" 
//								  | arguments: "(" Expr arg1 ("," Expr)* ")"argrest;
//syntax Arguments = arguments:{Expr ","}* args;

//syntax Items = emptyList: "[" "]" 
//						| items: "[" Expr item1 ("," Expr)* items "]" ;
//noArgs: ""
//								  |  oneArg: Expr
//								  |  arguments: (Expr ",")*;

// All possible expressions
syntax Expr = idExpr: ID id !>> "("
					  | strExpr: String string
					  | numExpr: Number number
					  | boolExpr: Boolean boolean
					  | listExpr: "[" {Expr ","}* items "]"
					  | funCall: ID id "(" {Expr ","}* args")"
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
					   | inputStmt: "input" "(" ")"
					   | outputStmt: "output" "(" Expr expr ")"
					   | ifStmt: "if" "(" Expr cond ")"  Block block "end" "if"
					   | ifElseStmt: "if" "(" Expr cond ")"  Block thenBlock "else" Block elseBlock "end" "if"
					   | repeatStmt: "repeat" "(" Number iter ")" Block block "end" "repeat"
					   | whileStmt: "while" "(" Expr cond ")"  Block block "end" "while"
					   | funDef: Type datatype "function" ID id "(" Parameters parameters ")"  Block block "end" "function";

syntax Parameters = Parameter*;

syntax Parameter = parameter: Type datatype ID id;

// Individual statement's syntax 
//syntax Expr_stmt = exprStmt: "e:" Expr expr;
//syntax Assign_stmt = assStmt: ID id "=" Expr expr;
//syntax If_stmt = ifStmt: "if" "(" Expr cond ")" "{" Block block"}";
//syntax Repeat_stmt = repeatStmt: "repeat" "(" Number iter")" "{" Block block"}";

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