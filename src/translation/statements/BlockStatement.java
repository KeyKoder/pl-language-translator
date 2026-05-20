package translation.statements;

// For statements that cannot be inside other statements
// ex. a = b + 3 * c; -> "a = ...;" is an block statement. it has an inline statement inside
public interface BlockStatement extends Statement {
}
