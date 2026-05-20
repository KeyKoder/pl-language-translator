package translation;

import translation.statements.Statement;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class Block {
	public List<Statement> statements = new ArrayList<Statement>();

	@Override
	public String toString() {
		return "{\n" + String.join("\n", statements.stream().map(Object::toString).collect(Collectors.toSet())) + "\n}";
	}
}
