package translation;

import org.antlr.v4.runtime.misc.Pair;
import translation.statements.AssignStatement;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class Function {
	public Type type;
	public String name;
	public List<Pair<Type, String>> params; // pair (type, name)
	public Block code;

	public Function(Type type, String name) {
		this.type = type;
		this.name = name;
		this.params = new ArrayList<Pair<Type, String>>();
		this.code = new Block();
	}

	public Function(Type type, String name, List<Pair<Type, String>> params) {
		this.type = type;
		this.name = name;
		this.params = params;
		this.code = new Block();
	}

	public String getHeader() {
		String out = type + " " + name + "(";
		if(params.isEmpty()) {
			return out + "void)";
		}else {
			for (Pair<Type, String> param : params) {
				out += param.a.typename;
				out += " " + param.b;

				if (param.a.isArray()) out += "[]";
				out += ", ";
			}
			return out.substring(0, out.length() - 2) + ")";
		}
	}

	@Override
	public String toString() {
		return getHeader() + "\n{\n" + code.statements.stream().map(s -> {
			if(s instanceof AssignStatement assignStatement && assignStatement.varname.equals(name)) {
				return "return " + assignStatement.statement.toString() + ";";
			}
			return s.toString();
		}).collect(Collectors.joining("\n")) + "\n}";
	}
}
