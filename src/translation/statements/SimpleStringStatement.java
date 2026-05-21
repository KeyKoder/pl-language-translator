package translation.statements;

public class SimpleStringStatement implements InlineStatement {
	public String statement;

	public SimpleStringStatement(String statement) {
		this.statement = statement;
	}

	@Override
	public String toString() {
		return statement;
	}
}
