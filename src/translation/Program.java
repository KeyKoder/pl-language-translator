package translation;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

public class Program {
	public List<String> dcls = new ArrayList<String>();
	public LinkedHashMap<String, Function> functions = new LinkedHashMap<String, Function>();
	public List<Variables> vars = new ArrayList<Variables>();
	// TODO: una vez tengamos la gramática lista y utilizando translation.Block para sentlist, descomentar la linea de debajo
	// public translation.Function main = new translation.Function(new translation.Type("void"), "main", new ArrayList<Pair<translation.Type, String>>());
	public String main;

	@Override
	public String toString() {
		return String.join("\n", dcls) + "\n\n"
				+ vars.stream().map(v -> v.toString()+";").collect(Collectors.joining("\n")) + "\n\n"
				+ functions.values().stream().map(function -> function.getHeader() + ";").collect(Collectors.joining("\n")) + "\n\n"
				+ main.toString();
	}
}
