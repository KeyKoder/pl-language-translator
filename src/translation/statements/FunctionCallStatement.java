package translation.statements;

public class FunctionCallStatement extends GenericCallOrIdentifierStatement implements InlineStatement {
	public FunctionCallStatement(String functionName) {
		super(functionName);
	}
}
