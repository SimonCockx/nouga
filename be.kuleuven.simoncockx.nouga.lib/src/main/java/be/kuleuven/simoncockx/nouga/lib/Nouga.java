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
	
	public static Boolean or(Boolean e1, Boolean e2) {
		return e1 || e2;
	}
	
	public static Boolean and(Boolean e1, Boolean e2) {
		return e1 && e2;
	}
	
	public static Boolean not(Boolean e) {
		return !e;
	}
	
	public static <T> Boolean exists(T e) {
		return e != null;
	}
	public static <T> Boolean exists(List<? extends T> e) {
		return e.size() != 0;
	}
	
	public static <T> Boolean singleExists(T e) {
		return e != null;
	}
	public static <T> Boolean singleExists(List<? extends T> e) {
		return e.size() == 1;
	}
	
	public static <T> Boolean multipleExists(List<? extends T> e) {
		return e.size() >= 2;
	}
	
	public static <T> Boolean contains(List<? extends T> e1, List<? extends T> e2) {
		return e1.containsAll(e2);
	}
	
	public static <T> Boolean disjoint(List<? extends T> e1, List<? extends T> e2) {
		return Collections.disjoint(e1, e2);
	}
	
	public static <T> Boolean equals(List<? extends T> e1, List<? extends T> e2) {
		return e1.equals(e2);
	}
	
	public static <T> Boolean notEquals(List<? extends T> e1, List<? extends T> e2) {
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
	
	public static <T> Boolean allEquals(List<? extends T> e1, T e2) {
		return e1.stream().allMatch(e -> e.equals(e2));
	}
	
	public static <T> Boolean allNotEquals(List<? extends T> e1, T e2) {
		return e1.stream().allMatch(e -> !e.equals(e2));
	}
	
	public static <T> Boolean anyEquals(List<? extends T> e1, T e2) {
		return e1.stream().anyMatch(e -> e.equals(e2));
	}
	
	public static <T> Boolean anyNotEquals(List<? extends T> e1, T e2) {
		return e1.stream().anyMatch(e -> !e.equals(e2));
	}
	
	public static Integer addInt(Integer e1, Integer e2) {
		return e1 + e2;
	}
	public static BigDecimal addNumber(BigDecimal e1, BigDecimal e2) {
		return e1.add(e2);
	}
	
	public static Integer subtractInt(Integer e1, Integer e2) {
		return e1 - e2;
	}
	public static BigDecimal subtractNumber(BigDecimal e1, BigDecimal e2) {
		return e1.subtract(e2);
	}
	
	public static Integer multiplyInt(Integer e1, Integer e2) {
		return e1 * e2;
	}
	public static BigDecimal multiplyNumber(BigDecimal e1, BigDecimal e2) {
		return e1.multiply(e2);
	}
	
	public static BigDecimal divide(BigDecimal e1, BigDecimal e2) {
		return e1.divide(e2, DECIMAL_PRECISION);
	}
	
	public static <T> Integer count(T e) {
		if (e == null) {
			return 0;
		}
		return 1;
	}
	public static <T> Integer count(List<? extends T> e) {
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
	
	public static <T> T ifThenElse(Boolean condition, T thenResult, T elseResult) {
		return condition ? thenResult : elseResult;
	}
	
	@SafeVarargs
	public static <T, Prop> Boolean checkAll(T e, Function<T, Boolean> ... checks) {
		return Stream.of(checks).allMatch(check -> check.apply(e));
	}
	
	public static <T> T onlyElement(List<? extends T> e) {
		if (e.size() == 1) {
			return e.get(0);
		}
		return null;
	}
	
	public static BigDecimal coerceIntToNumber(Integer e) {
		return BigDecimal.valueOf(e);
	}
	public static List<? extends BigDecimal> coerceIntToNumber(List<? extends Integer> e) {
		return e.stream().map(Nouga::coerceIntToNumber).collect(Collectors.toList());
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
