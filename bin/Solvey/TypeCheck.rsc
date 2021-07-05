module Solvey::TypeCheck

import Prelude;
import Solvey::AST;
import Solvey::Syntax;
import Solvey::AST;

public Program load(str txt) = implode(#Program, parse(#Program, txt));

// Haha im empty... :'(