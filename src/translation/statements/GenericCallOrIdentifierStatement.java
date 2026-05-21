package translation.statements;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class GenericCallOrIdentifierStatement implements InlineStatement {
	public String identifier;
	public List<InlineStatement> paramList = new ArrayList<InlineStatement>();
	public boolean hasParams = true;

	public GenericCallOrIdentifierStatement(String identifier) {
		this.identifier = identifier;
	}

	@Override
	public String toString() {
		String out = identifier;
		if(hasParams) {
			out +="(" + paramList.stream().map(p -> p.toString()).collect(Collectors.joining(", ")) + ")";
		}
		return out;
	}
}
