package translation.statements;

import translation.Block;

public class IfStatement implements BlockStatement {
	public String condition;
	public Block code;
	public Block elseCode; // this may be null if there is no else statement
}
