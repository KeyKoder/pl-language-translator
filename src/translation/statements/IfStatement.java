package translation.statements;

import translation.Block;

public class IfStatement implements BlockStatement {
	public InlineStatement condition;
	public Block code;
	public Block elseCode; // this may be empty if there is no else statement

	public IfStatement(InlineStatement condition) {
		this.condition = condition;
		this.code = new Block();
		this.elseCode = new Block();
	}

	@Override
	public String toString() {
		String out = "if(" + condition.toString() + ") "+ code.toString();
		if(!elseCode.statements.isEmpty()) {
			out += "else " + elseCode.toString();
		}
		return out;
	}
}
