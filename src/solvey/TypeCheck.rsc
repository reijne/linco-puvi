module Solvey::TypeCheck

import Prelude;
import Solvey::AST;
import Solvey::ConcreteSyntax;

public Program load(str txt) = implode(#Program, parse(#Program, txt));

// Haha im empty... :'(