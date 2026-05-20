package translation.statements;

public class FunctionCallStatement extends GenericCallStatement implements InlineStatement {
	public FunctionCallStatement(String functionName) {
		super(functionName);
	}
}
