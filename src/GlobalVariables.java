import org.antlr.v4.runtime.misc.Pair;

import java.util.ArrayList;
import java.util.List;

public class GlobalVariables {
	public Type type;
	// list of pairs (name, value)
	// if value is null, then no initial value is set
	public List<Pair<String, String>> vars = new ArrayList<Pair<String, String>>();
	public String currentName;
	public String currentValue;


	public GlobalVariables(Type type) {
		this.type = type;
		this.currentName = null;
		this.currentValue = null;
	}

	public GlobalVariables(String name) {
		this.type = null;
		this.currentName = name;
		this.currentValue = null;
	}

	public GlobalVariables(Type type, String name) {
		this.type = type;
		this.currentName = name;
		this.currentValue = null;
	}

	public GlobalVariables(Type type, String name, String value) {
		this.type = type;
		this.currentName = name;
		this.currentValue = value;
	}

	public void addCurrentVar() {
		vars.add(new Pair<String, String>(currentName, currentValue));
		currentName = null;
		currentValue = null;
	}

	@Override
	public String toString() {
		String out = type.typename + " ";

		for(Pair<String, String> var : vars) {
			out += var.a;

			if(type.isArray()) out += "[" + type.count + "]";
			if(var.b != null) out += " = " + var.b;

			out += ", ";
		}

		return out.substring(0, out.length()-2);
	}
}
