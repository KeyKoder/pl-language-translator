package translation.statements.switchcase;

import translation.Block;
import translation.statements.SimpleStringStatement;

import java.util.ArrayList;
import java.util.List;

public class RegularCaseBlock extends CaseBlock {
	// if labels is empty, it means this block is a default block
	public List<String> labels = new ArrayList<String>();

	public RegularCaseBlock() {}

	public RegularCaseBlock(List<String> labels) {
		this.labels = labels;
	}

	@Override
	public String toString() {
		String out = "\t".repeat(code.depth);
		if(labels.isEmpty()) {
			out += "default:";
		}else {
			for (String s : labels) {
				out += "case " + s + ":";
			}
		}

		String blockCode = code.toString();
		if(labels.isEmpty()) {
			out += blockCode.substring(1, blockCode.length()-code.depth-1) + "\t";
		} else {
			out += blockCode.substring(1, blockCode.length()-1);
			out += "\tbreak;\n";
		}
		return out;
	}
}
