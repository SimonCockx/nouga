package be.kuleuven.simoncockx.nouga.lib;

import java.math.BigDecimal;
import java.math.MathContext;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Nouga {
	public static final MathContext DECIMAL_PRECISION = MathContext.DECIMAL128;
	
	public static <T> List<? extends T> single(T e) {
		return Collections.singletonList(e);
	}	
	public static <T> List<? extends T> empty() {
		return Collections.emptyList();
	}
	
	@SafeVarargs
	public static <T> List<? extends T> list(T ... es) {
		return List.of(es);
	}
	@SafeVarargs
	public static <T> List<? extends T> list(List<? extends T> ... es) {
		return Stream
				.of(es)
				.flatMap(Collection::stream)
				.collect(Collectors.toList());
	}
	
	public static boolean or(boolean e1, boolean e2) {
		return e1 || e2;
	}
	
	public static boolean and(boolean e1, boolean e2) {
		return e1 && e2;
	}
	
	public static boolean not(boolean e) {
		return !e;
	}
	
	public static <T> boolean exists(T e) {
		return e != null;
	}
	public static <T> boolean exists(List<? extends T> e) {
		return e.size() != 0;
	}
	
	public static <T> boolean singleExists(T e) {
		return e != null;
	}
	public static <T> boolean singleExists(List<? extends T> e) {
		return e.size() == 1;
	}
	
	public static <T> boolean multipleExists(List<? extends T> e) {
		return e.size() >= 2;
	}
	
	public static <T> boolean isAbsent(T e) {
		return e == null;
	}
	public static <T> boolean isAbsent(List<? extends T> e) {
		return e.size() == 0;
	}
	
	public static <T> boolean contains(List<? extends T> e1, List<? extends T> e2) {
		return e1.containsAll(e2);
	}
	
	public static <T> boolean disjoint(List<? extends T> e1, List<? extends T> e2) {
		return Collections.disjoint(e1, e2);
	}
	
	public static <T> boolean equals(List<? extends T> e1, List<? extends T> e2) {
		return e1.equals(e2);
	}
	
	public static <T> boolean notEquals(List<? extends T> e1, List<? extends T> e2) {
		if (e1.size() != e2.size()) {
			return true;
		}
		for (int i=0; i<e1.size(); i++) {
			if (e1.get(i).equals(e2.get(i))) {
				return false;
			}
		}
		return true;
	}
	
	public static <T> boolean allEquals(List<? extends T> e1, T e2) {
		return e1.stream().allMatch(e -> e.equals(e2));
	}
	
	public static <T> boolean allNotEquals(List<? extends T> e1, T e2) {
		return e1.stream().allMatch(e -> !e.equals(e2));
	}
	
	public static <T> boolean anyEquals(List<? extends T> e1, T e2) {
		return e1.stream().anyMatch(e -> e.equals(e2));
	}
	
	public static <T> boolean anyNotEquals(List<? extends T> e1, T e2) {
		return e1.stream().anyMatch(e -> !e.equals(e2));
	}
	
	public static int addInt(int e1, int e2) {
		return e1 + e2;
	}
	public static BigDecimal addNumber(BigDecimal e1, BigDecimal e2) {
		return e1.add(e2);
	}
	
	public static int subtractInt(int e1, int e2) {
		return e1 - e2;
	}
	public static BigDecimal subtractNumber(BigDecimal e1, BigDecimal e2) {
		return e1.subtract(e2);
	}
	
	public static int multiplyInt(int e1, int e2) {
		return e1 * e2;
	}
	public static BigDecimal multiplyNumber(BigDecimal e1, BigDecimal e2) {
		return e1.multiply(e2);
	}
	
	public static BigDecimal divide(BigDecimal e1, BigDecimal e2) {
		return e1.divide(e2, DECIMAL_PRECISION);
	}
	
	public static <T> int count(T e) {
		if (e == null) {
			return 0;
		}
		return 1;
	}
	public static <T> int count(List<? extends T> e) {
		return e.size();
	}
	
	public static <T, Prop> List<? extends Prop> project(List<? extends T> e, Function<T, Prop> f) {
		return e.stream()
				.map(elem -> f.apply(elem))
				.collect(Collectors.toList());
	}
	public static <T, Prop> List<? extends Prop> flatProject(List<? extends T> e, Function<T, List<? extends Prop>> f) {
		return e.stream()
				.flatMap(elem -> f.apply(elem).stream())
				.collect(Collectors.toList());
	}
	
	public static <T> T ifThenElse(boolean condition, T thenResult, T elseResult) {
		return condition ? thenResult : elseResult;
	}
	
	@SafeVarargs
	public static <T, Prop> boolean checkAll(T e, Function<T, Boolean> ... checks) {
		return Stream.of(checks).allMatch(check -> check.apply(e));
	}
	
	public static <T> T onlyElement(List<? extends T> e) {
		if (e.size() == 1) {
			return e.get(0);
		}
		return null;
	}
	
	public static BigDecimal coerceIntToNumber(int e) {
		return BigDecimal.valueOf(e);
	}
	public static List<? extends BigDecimal> coerceIntToNumber(List<? extends Integer> e) {
		return e.stream().map(Nouga::coerceIntToNumber).collect(Collectors.toList());
	}
	public static <T> T coerceNothingToAnything(Void e) {
		return null;
	}
	public static <T> List<? extends T> coerceNothingToAnything(List<? extends Void> e) {
		return empty();
	}
	public static <T> List<? extends T> coerceToList(T e) {
		if (e == null) {
			return empty();
		}
		return single(e);
	}
}
