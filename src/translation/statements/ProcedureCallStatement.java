package translation.statements;

public class ProcedureCallStatement extends GenericCallOrIdentifierStatement implements BlockStatement {

	public ProcedureCallStatement(String functionName) {
		super(functionName);
	}
}
