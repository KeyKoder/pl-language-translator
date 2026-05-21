package translation.statements;

public class ReturnStatement implements BlockStatement {
	public InlineStatement returnValue;

	public ReturnStatement(InlineStatement returnValue) {
		this.returnValue = returnValue;
	}

	@Override
	public String toString() {
		return "return " + returnValue.toString();
	}
}
