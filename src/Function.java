import org.antlr.v4.runtime.misc.Pair;

import java.util.List;

public class Function {
	public Type type;
	public String name;
	public List<Pair<Type, String>> params; // pair (type, name)

	public Function(Type type, String name, List<Pair<Type, String>> params) {
		this.type = type;
		this.name = name;
		this.params = params;
	}

	public String getHeader() {
		String out = type + " " + name + "(";
		int bracketIdx;
		for(Pair<Type, String> param : params) {
			out += param.a.typename;
			out += " "+param.b;

			if(param.a.isArray()) out += "[]";
			out += ", ";
		}
		return out.substring(0, out.length()-2) + ")";
	}
}
