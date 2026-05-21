package translation;

import org.antlr.v4.runtime.misc.Pair;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

public class Program {
	public List<String> dcls = new ArrayList<String>();
	public LinkedHashMap<String, Function> functions = new LinkedHashMap<String, Function>();
	public List<Variables> vars = new ArrayList<Variables>();
	// TODO: una vez tengamos la gramática lista y utilizando translation.Block para sentlist, descomentar la linea de debajo
	 public Function main = new Function(new Type("void"), "main", new ArrayList<Pair<Type, String>>());
//	public String main;

	@Override
	public String toString() {
		String out = String.join("\n", dcls);
		if(!vars.isEmpty()) out += "\n\n" + vars.stream().map(v -> v.toString()+";").collect(Collectors.joining("\n"));
		if(!functions.isEmpty()) out += "\n\n" + functions.values().stream().map(function -> function.getHeader() + ";").collect(Collectors.joining("\n"));
		out += "\n\n" + main.toString();
		List<Function> fuctionsWithBodies = functions.values().stream().filter(function -> !function.code.statements.isEmpty()).toList();
		if(!fuctionsWithBodies.isEmpty()) out +=  "\n\n" + functions.values().stream().filter(function -> !function.code.statements.isEmpty()).map(function -> function.toString()).collect(Collectors.joining("\n\n"));
		return out;
	}
}
