import java.util.ArrayList;
import java.util.List;

public class Program {
	public List<String> dcls = new ArrayList<String>();

	@Override
	public String toString() {
		return "Program{" +
				"dcls=" + dcls.stream().reduce((a,b) -> a + ", " + b) +
				'}';
	}
}
