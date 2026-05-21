package translation.statements;

public class AssignStatement implements BlockStatement {
	public String varname;
	public InlineStatement statement;

	public AssignStatement(String varname, InlineStatement statement) {
		this.varname = varname;
		this.statement = statement;
	}

	@Override
	public String toString() {
		return varname + " = " + statement.toString();
	}
}
