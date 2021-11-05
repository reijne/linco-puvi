module Puzzle::Lightlang

start syntax LL = Nums;
lexical Nums = [0-9]*;

layout LAYOUTLIST
  = LAYOUT* !>> [\t-\n \r \ ] !>> "//" !>> "/*";

lexical LAYOUT= [\t-\n \r \ ];

public start[LL] ll_parse(str input, loc file) = parse(#start[LL], input, file);
public start[LL] ll_parse(loc file) = parse(#start[LL], file);