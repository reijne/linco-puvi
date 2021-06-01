module solvey::TypeChecker

import Prelude;
import solvey::AST;
import solvey::Syntax;
import solvey::AST;

public Program load(str txt) = implode(#Program, parse(#Program, txt));

// Haha im empty... :'(