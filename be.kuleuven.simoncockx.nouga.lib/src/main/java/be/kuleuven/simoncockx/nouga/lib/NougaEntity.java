package be.kuleuven.simoncockx.nouga.lib;

import java.util.List;

public abstract class NougaEntity {
	public abstract List<String> getAttributeNames();
	public Object getAttributeValue(String attr) {
		throw new IllegalArgumentException("Attribute `" + attr + "` does not exist in entity `" + this.getClass().getSimpleName() + "`.");
	}
}
