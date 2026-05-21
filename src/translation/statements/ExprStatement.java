package translation.statements;

public class ExprStatement implements InlineStatement {
	public InlineStatement left;
	public String operator;
	public InlineStatement right;

	public ExprStatement() {}

	@Override
	public String toString() {
		String out = left.toString();
		if(operator != null) {
			out += " " + operator;
		}
		if(right != null) {
			out += " " + right.toString();
		}
		return out;
	}
}
