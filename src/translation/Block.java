package translation;

import translation.statements.CompositeStatement;
import translation.statements.Statement;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class Block {
	public List<Statement> statements = new ArrayList<Statement>();
	public int depth = 0; // how many levels deep is this block

	@Override
	public String toString() {
		return "{\n" + "\t".repeat(depth+1) + String.join("\n"+"\t".repeat(depth+1), statements.stream().map(s -> {
			String out = s.toString();
			if(!(s instanceof CompositeStatement)) out += ";";
			return out;
		}).toList()) + "\n" + "\t".repeat(depth) + "}";
	}
}
