package translation.statements;

import java.util.ArrayList;
import java.util.List;

public class GenericCallStatement {
	public String functionName;
	public List<String> paramList = new ArrayList<String>();

	public GenericCallStatement(String functionName) {
		this.functionName = functionName;
	}

	@Override
	public String toString() {
		return functionName + "(" + String.join(", ", paramList) + ")";
	}
}
