package translation;

import org.antlr.v4.runtime.misc.Pair;

import java.util.ArrayList;
import java.util.List;

public class Variables {
	public Type type;
	// list of pairs (name, value)
	// if value is null, then no initial value is set
	public List<Pair<String, String>> vars = new ArrayList<Pair<String, String>>();
	public String currentName;
	public String currentValue;


	public Variables(Type type) {
		this.type = type;
		this.currentName = null;
		this.currentValue = null;
	}

	public Variables(String startingName) {
		this.type = null;
		this.currentName = startingName;
		this.currentValue = null;
	}

	public Variables(Type type, String startingName) {
		this.type = type;
		this.currentName = startingName;
		this.currentValue = null;
	}

	public Variables(Type type, String startingName, String startingValue) {
		this.type = type;
		this.currentName = startingName;
		this.currentValue = startingValue;
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
