import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

public class Program {
	public List<String> dcls = new ArrayList<String>();
	public HashMap<String, Function> functions = new HashMap<String, Function>();
	public String vars;
	public String main;
	public String funimpl;

	//TODO: añadir vars al toString
	@Override
	public String toString() {
		return String.join("\n", dcls) + "\n\n" + String.join("\n", functions.values().stream().map(f -> f.getHeader()+";").collect(Collectors.toSet()));
	}
}
