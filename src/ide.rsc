module ide

import solvey::syntax_concrete;
import showey::syntax_concrete;

import util::IDE;

public str SLY_NAME = "Solvey Language";
public str SLY_EXT = "sly";

// Register Solvey as a language in Eclipse o-o
public void sly_register() {
  registerLanguage(SLY_NAME, SLY_EXT, solvey::syntax_concrete::sly_parse);
}

public str SHO_NAME = "Showey Language";
public str SHO_EXT = "sho";

public void sho_register() {
	registerLanguage(SHO_NAME, SHO_EXT, showey::syntax_concrete::sho_parse);
}

public void register_langs() {
	sly_register();
	sho_register();
}