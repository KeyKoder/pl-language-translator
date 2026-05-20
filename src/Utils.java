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
}
