package translation.statements;

public class ExprStatement implements InlineStatement {
	public String statement;

	public ExprStatement(String statement) {
		this.statement = statement;
	}

	@Override
	public String toString() {
		return statement;
	}
}
