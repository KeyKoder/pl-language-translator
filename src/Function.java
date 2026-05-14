import org.antlr.v4.runtime.misc.Pair;

import java.util.List;

public class Function {
	public String type;
	public String name;
	public List<Pair<String, String>> params; // pair (type, name) (its reversed)
	// TODO: find a better way of filling the param list so we don't have to reverse it.

	public Function(String type, String name, List<Pair<String, String>> params) {
		this.type = type;
		this.name = name;
		this.params = params;
	}

	public String getHeader() {
		String out = type + " " + name + "(";
		int bracketIdx;
		for(Pair<String, String> param : params) {
			bracketIdx = param.a.indexOf("[");
			if(bracketIdx == -1) out += param.a;
			else out += param.a.substring(0, bracketIdx);

			out += " "+param.b;

			if(bracketIdx != -1) out += "[]";

			out += ", ";
		}
		return out.substring(0, out.length()-2) + ")";
	}
}
