package be.kuleuven.simoncockx.nouga.generator;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import be.kuleuven.simoncockx.nouga.lib.Nouga;

/**
 * See https://stackoverflow.com/a/2010302/3083982.
 */
public class JavaLibUtil {
	public String libName = Nouga.class.getSimpleName();
	
	public String single;
	public String empty;
	public String list;
	public String or;
	public String and;
	public String not;
	public String exists;
	public String singleExists;
	public String multipleExists;
	public String isAbsent;
	public String contains;
	public String disjoint;
	public String equals;
	public String notEquals;
	public String allEquals;
	public String allNotEquals;
	public String anyEquals;
	public String anyNotEquals;
	public String addInt;
	public String addNumber;
	public String subtractInt;
	public String subtractNumber;
	public String multiplyInt;
	public String multiplyNumber;
	public String divide;
	public String count;
	public String project;
	public String flatProject;
	public String ifThenElse;
	public String onlyElement;
	public String onlyExists;
	public String coerceIntToNumber;
	public String coerceItemToList;
	
	public JavaLibUtil() {
		Field[] fields = JavaLibUtil.class.getDeclaredFields();
		List<String> notFound = new ArrayList<String>();
		for (var i=0; i<fields.length; i++) {
			try {
				if (fields[i].get(this) == null) {
					fields[i].set(this, verifyMethod(fields[i].getName()));
				}
			} catch (IllegalAccessException e) {
				throw new RuntimeException(e);
			} catch (NoSuchMethodException e) {
				notFound.add(fields[i].getName());
			}
		}
		if (notFound.size() > 0) {
			String l = String.join(", ", notFound.stream().map(name -> "`" + name + "`").collect(Collectors.toList()));
			throw new RuntimeException("No Nouga library methods named " + l + ".");
		}
	}
	
	private String verifyMethod(String name) throws NoSuchMethodException {
		for (Method m : Nouga.class.getDeclaredMethods()) {
			if (m.getName().equals(name)) {
				return this.libName + "." + m.getName();
			}
		}
		throw new NoSuchMethodException(name);
	}
}
