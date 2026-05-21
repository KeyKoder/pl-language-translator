package translation.statements.switchcase;

import translation.Block;
import translation.statements.SimpleStringStatement;

public class RangeCaseBlock extends CaseBlock {
	public String from; // this may be empty when there is no start of the range
	public String to;  // this may be empty when there is no end of the range

	public RangeCaseBlock(String from, String to) {
		this.from = from;
		this.to = to;
	}

	@Override
	public String toString() {
		String out = "\t".repeat(code.depth);
		if(from.isEmpty()) {
			out += "case < " + to + ":";
		}else if(to.isEmpty()) {
			out += "case > " + from + ":";
		}else {
			out += "case " + from + " to " + to + ":";
		}

		String blockCode = code.toString();
		out += blockCode.substring(1, blockCode.length()-1);
		out += "\tbreak;\n";
		return out;
	}
}
