module solvey::IDE

import solvey::Syntax;
import util::IDE;

public str SLY_NAME = "Solvey Language";
public str SLY_EXT = "sly";

// Register Solvey as a language in Eclipse o-o
public void sly_register() {
  registerLanguage(SLY_NAME, SLY_EXT, solvey::Syntax::sly_parse);
}