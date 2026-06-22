package translation;

import org.antlr.v4.runtime.misc.Pair;
import translation.statements.SimpleStringStatement;
import translation.statements.Statement;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

public class Program {
	public List<String> dcls = new ArrayList<String>();
	public LinkedHashMap<String, Function> functions = new LinkedHashMap<String, Function>();
	public List<Variables> vars = new ArrayList<Variables>();
	public Function main = new Function(new Type("void"), "main", new ArrayList<Pair<Type, String>>());

	@Override
	public String toString() {
		String out = "";
		if(!dcls.isEmpty()) out += String.join("\n", dcls) + "\n\n";
		if(!vars.isEmpty()) {
			for(int i=vars.size()-1;i>=0;i--) {
				main.code.statements.add(0, new SimpleStringStatement(vars.get(i).toString()));
			}
//			out += vars.stream().map(v -> v.toString()+";").collect(Collectors.joining("\n")) + "\n\n";
		}
		if(!functions.isEmpty()) out += functions.values().stream().map(function -> function.getHeader() + ";").collect(Collectors.joining("\n")) + "\n\n";

		out += main.toString() + "\n\n";
		List<Function> fuctionsWithBodies = functions.values().stream().filter(function -> !function.code.statements.isEmpty()).toList();
		if(!fuctionsWithBodies.isEmpty()) out +=  functions.values().stream().filter(function -> !function.code.statements.isEmpty()).map(function -> function.toString()).collect(Collectors.joining("\n\n")) + "\n\n";

		for(int i=0;i<vars.size();i++) {
			main.code.statements.removeFirst();
		}

		return out;
	}
}
