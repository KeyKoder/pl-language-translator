import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

public class Program {
	public List<String> dcls = new ArrayList<String>();
	public LinkedHashMap<String, Function> functions = new LinkedHashMap<String, Function>();
	public List<GlobalVariables> vars = new ArrayList<GlobalVariables>();
	public String main;
	public String funimpl;

	@Override
	public String toString() {
		return String.join("\n", dcls) + "\n\n"
				+ String.join("\n", vars.stream().map(v -> v.toString()+";").collect(Collectors.toSet())) + "\n\n"
				+ String.join("\n", functions.values().stream().map(f -> f.getHeader()+";").collect(Collectors.toSet())) + "\n\n"
				+ main;
	}
}
