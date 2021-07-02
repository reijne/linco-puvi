package Network;

import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValueFactory;

public class Socket {
	private final IValueFactory values;

    public Socket(IValueFactory values){
        this.values = values;
    }

    public IString tester() {
        return values.string("lol");
    }
}