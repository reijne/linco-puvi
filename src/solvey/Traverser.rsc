//This is a generated file, do not manually alter unless you absolutely know what you're doing, and 
//dont mind getting your work overwritten upon next generation.

 // Traverser module implementing a custom labeled traversal of a Solvey AST
module Solvey::Traverser
import Solvey::AbstractSyntax;

public str labeledTraverse(image(int width,int height,Colour c))  =
"in-Image-image
-in-Colour-c
<labeledTraverse(c)>
-out-Colour-c
out-Image-image";

public str labeledTraverse(colour(int r,int g,int b))  =
"in-Colour-colour
out-Colour-colour";

