module showey::syntax_concrete

import ParseTree;
extend lang::std::Layout;
extend lang::std::Id;


lexical ID = Id \ Keyword;
lexical Number = [0-9]+;

lexical Sign = s_plus: "+"
					  | s_min: "-";
					  
lexical Color = "\"white\"" 
					   | "\"blue\""
					   | "\"cyan\""
					   | "\"green\""
					   | "\"red\""
					   | "\"magenta\""
					   | "\"yellow\"";
					  
lexical Dir = dir_x: "x"
				   |  dir_x: "X"
				   |  dir_y: "y"
				   |  dir_y: "Y"
				   |  dir_z: "z"
				   |  dir_y: "Z"; 
				   
lexical Direction = "Direction" | "direction";
lexical General = "General" | "general";
				   
// Definition Start
start syntax Definition = def: GenDir Camera Blocky+ Mapping;

// General Direction
syntax GenDir = gendir: General Direction "=" Sign sign Dir dir;

// Camera definition
syntax Camera = "Camera" "{" "mode" "=" CamMode Direction "=" CamDir ForwardBackward "}";		   

// Camera mode, determining behaviour
syntax CamMode = c_static: "static"
								 |  c_kine: "kinematic"
								 |  c_user: "user";

// Camera Direction relative to the general direction
syntax CamDir = "N" | "NE" | "E" | "SE" | "S" | "SW" | "W" | "NW";

// Camera offset in the forward and backwards direction relative to general direction
syntax ForwardBackward = "forwardbackward" "=" Number;

// Blocky definition
syntax Blocky ="Blocky" ID "=" "[" Tile+ "]";

// Tile definition
syntax Tile = "(" Number x "," Number y "," Number z "|" Color ")" ; 

// Mapping of Nodes to blocky definitions
syntax  Mapping = "Map" "{" Map* "}";

// One mapping of a node to a blocky
syntax Map = ID ":" ID;
// Offset + relative Direction

keyword Keyword = "General" | "general" |
									"Direction" | "direction" |
									"x" | "X" | "y" | "Y" | "z" | "Z" |
									"Blocky" | "mode" | "forwardbackward" |
									"Map" ;

public start[Definition] sho_parse(str input, loc file) = parse(#start[Definition], input, file);
  
public start[Definition] sho_parse(loc file) = parse(#start[Definition], file);
  
public Tree sho_parse_tree(loc file) = parse(#start[Definition], file);