package translation.statements;

import translation.statements.switchcase.CaseBlock;
import translation.statements.switchcase.RegularCaseBlock;

import java.util.List;

public class CaseStatement implements BlockStatement, CompositeStatement {
	public InlineStatement selector;
	public List<CaseBlock> cases;

	public CaseStatement(InlineStatement selector, List<CaseBlock> cases) {
		this.selector = selector;
		this.cases = cases;
	}

	@Override
	public String toString() {
		String out = "switch(" + selector.toString() + ") {\n";
		int depth = cases.getFirst().code.depth;
		for(CaseBlock block : cases) {
			block.code.depth++;
			out += block.toString();
		}
		out += "}";
		return out;
	}
}
