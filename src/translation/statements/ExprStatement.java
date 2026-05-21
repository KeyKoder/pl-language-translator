package translation.statements;

public class ExprStatement implements InlineStatement {
	public InlineStatement left;
	public String operator;
	public InlineStatement right;
	public boolean hasParenthesis = false;

	public ExprStatement() {}

	public ExprStatement(InlineStatement left, String operator, InlineStatement right) {
		this.left = left;
		this.operator = operator;
		this.right = right;
	}

	@Override
	public String toString() {
		String out = "";
		if(left != null) {
			out += " " + left.toString();
		}
		if(operator != null) {
			out += " " + operator;
		}
		if(right != null) {
			out += " " + right.toString();
		}
		if(hasParenthesis) return "(" + out.trim() + ")";
		else return out.trim();
	}
}
