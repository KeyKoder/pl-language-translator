package translation.statements;

public class ProcedureCallStatement extends GenericCallStatement implements BlockStatement {

	public ProcedureCallStatement(String functionName) {
		super(functionName);
	}
}
