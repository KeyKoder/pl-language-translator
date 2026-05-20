package translation.statements;

import translation.Variables;

public class VarDeclarationStatement implements BlockStatement {
	public Variables vars;

	public VarDeclarationStatement(Variables vars) {
		this.vars = vars;
	}

	@Override
	public String toString() {
		return vars.toString() + ";";
	}
}
