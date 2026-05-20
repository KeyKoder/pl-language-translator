package translation.statements;

// For statements that can be inside other statements
// ex. a = b + 3 * c; -> "b + 3 * c" is an inline statement
public interface InlineStatement extends Statement {
}
