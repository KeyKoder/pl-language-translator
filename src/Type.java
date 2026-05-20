public class Type {
	public String typename;
	// si count >= 0 -> representa un array de longitud count
	// si count == -1 -> representa solo el tipo
	public int count;

	public Type(String typename) {
		this.typename = typename;
		this.count = -1;
	}

	public Type(String typename, int count) {
		this.typename = typename;
		this.count = count;
	}

	public boolean isArray() {
		return count >= 0;
	}

	@Override
	public String toString() {
		if(count >= 0) {
			return typename + "[" + count + "]";
		}else {
			return typename;
		}
	}
}
