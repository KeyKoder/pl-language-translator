public class Utils {
	// Fixes strings with escaped quotes
	public static String unescapeString(String string) {
		String output = "";
		if(string.charAt(0) == '"') {
			output = string.replaceAll("\"\"", "\"");
		}else if(string.charAt(0) == '\'') {
			output = string.replaceAll("''", "'");
		}
		output = output.substring(1, output.length()-1); // trim the start and end quotes
		return output.replaceAll("\"", "\\\\\""); // the \" replacement needs four '\' to escape a single '\' due to being in a regex context
	}

	public static String fixString(String string) {
		String output = unescapeString(string);
		if(output.length() == 1) {
			return "'" + output + "'";
		}
		return "\"" + output + "\"";
	}

	public static String fixBasedIntLiteral(String literal) {
		String output = literal;
		if(output.charAt(0) == 'z') output = 'x' + output.substring(1);
		output = output.replaceAll("'", "");
		return "0" + output;
	}
}
