module solvey::ide

import solvey::syntax_concrete;
import util::IDE;

public str SLY_NAME = "Solvey Language";
public str SLY_EXT = "sly";

// Register Solvey as a language in Eclipse o-o
public void sly_register() {
  registerLanguage(SLY_NAME, SLY_EXT, sly_parse);
}