module Visualisation::Syntax

import ParseTree;

layout LAYOUTLIST
  = LAYOUT* !>> [\t-\n \r \ ] !>> "//" !>> "/*";

lexical LAYOUT
  = [\t-\n \r \ ];

lexical Integer = [0-9] !>> [0-9]; 

start syntax Image = image:"Width" Integer width "Height"Integer height "Colour" Colour colour;

syntax Colour = colour:"r" Integer r "g" Integer g "b" Integer b; 

public start[Image] img_parse(str input, loc file) = parse(#start[Image], input, file);
public start[Image] img_parse(loc file) = parse(#start[Image], file);

data Image = image(int width, int height, Colour c);
data Colour = colour(int r, int g, int b);

public Image img_build(loc file) = implode(#Image, img_parse(file));