package be.kuleuven.simoncockx.nouga.lib;

import java.math.BigDecimal;
import java.math.MathContext;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.function.BiFunction;
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
	public static <T> List<? extends T> list(List<? extends T> ... es) {
		return Stream
				.of(es)
				.flatMap(Collection::stream)
				.collect(Collectors.toList());
	}
	
	public static List<? extends Boolean> or(List<? extends Boolean> e1, List<? extends Boolean> e2) {
		return zipWith(e1, e2, Boolean::logicalOr);
	}
	
	public static List<? extends Boolean> and(List<? extends Boolean> e1, List<? extends Boolean> e2) {
		return zipWith(e1, e2, Boolean::logicalAnd);
	}
	
	public static List<? extends Boolean> not(List<? extends Boolean> e) {
		return e.stream().map(b -> !b).collect(Collectors.toList());
	}
	
	public static <T> List<? extends Boolean> exists(List<? extends T> e) {
		return single(e.size() != 0);
	}
	
	public static <T> List<? extends Boolean> singleExists(List<? extends T> e) {
		return single(e.size() == 1);
	}
	
	public static <T> List<? extends Boolean> multipleExists(List<? extends T> e) {
		return single(e.size() >= 2);
	}
	
	public static <T> List<? extends Boolean> contains(List<? extends T> e1, List<? extends T> e2) {
		return single(e1.containsAll(e2));
	}
	
	public static <T> List<? extends Boolean> disjoint(List<? extends T> e1, List<? extends T> e2) {
		return single(Collections.disjoint(e1, e2));
	}
	
	public static <T> List<? extends Boolean> equals(List<? extends T> e1, List<? extends T> e2) {
		return single(e1.equals(e2));
	}
	
	public static <T> List<? extends Boolean> notEquals(List<? extends T> e1, List<? extends T> e2) {
		if (e1.size() != e2.size()) {
			return single(true);
		}
		for (int i=0; i<e1.size(); i++) {
			if (e1.get(i).equals(e2.get(i))) {
				return single(false);
			}
		}
		return single(true);
	}
	
	public static <T> List<? extends Boolean> allEquals(List<? extends T> e1, List<? extends T> e2) {
		T elem = e2.get(0);
		return single(e1.stream().allMatch(e -> e.equals(elem)));
	}
	
	public static <T> List<? extends Boolean> allNotEquals(List<? extends T> e1, List<? extends T> e2) {
		T elem = e2.get(0);
		return single(e1.stream().allMatch(e -> !e.equals(elem)));
	}
	
	public static <T> List<? extends Boolean> anyEquals(List<? extends T> e1, List<? extends T> e2) {
		T elem = e2.get(0);
		return single(e1.stream().anyMatch(e -> e.equals(elem)));
	}
	
	public static <T> List<? extends Boolean> anyNotEquals(List<? extends T> e1, List<? extends T> e2) {
		T elem = e2.get(0);
		return single(e1.stream().anyMatch(e -> !e.equals(elem)));
	}
	
	public static <T extends Number> List<? extends Integer> addInt(List<? extends Integer> e1, List<? extends Integer> e2) {
		return zipWith(e1, e2, (a, b) -> a + b);
	}
	public static List<? extends BigDecimal> addNumber(List<? extends BigDecimal> e1, List<? extends BigDecimal> e2) {
		return zipWith(e1, e2, (a, b) -> a.add(b));
	}
	
	public static <T extends Number> List<? extends Integer> subtractInt(List<? extends Integer> e1, List<? extends Integer> e2) {
		return zipWith(e1, e2, (a, b) -> a - b);
	}
	public static List<? extends BigDecimal> subtractNumber(List<? extends BigDecimal> e1, List<? extends BigDecimal> e2) {
		return zipWith(e1, e2, (a, b) -> a.subtract(b));
	}
	
	public static <T extends Number> List<? extends Integer> multiplyInt(List<? extends Integer> e1, List<? extends Integer> e2) {
		return zipWith(e1, e2, (a, b) -> a * b);
	}
	public static List<? extends BigDecimal> multiplyNumber(List<? extends BigDecimal> e1, List<? extends BigDecimal> e2) {
		return zipWith(e1, e2, (a, b) -> a.multiply(b));
	}
	
	public static List<? extends BigDecimal> divide(List<? extends BigDecimal> e1, List<? extends BigDecimal> e2) {
		return zipWith(e1, e2, (a, b) -> a.divide(b, DECIMAL_PRECISION));
	}
	
	public static <T> List<? extends Integer> count(List<? extends T> e) {
		return single(e.size());
	}
	
	public static <T, Prop> List<? extends Prop> project(List<? extends T> e, Function<T, List<? extends Prop>> f) {
		return e.stream()
				.flatMap(elem -> f.apply(elem).stream())
				.collect(Collectors.toList());
	}
	
	public static <T> List<? extends T> ifThenElse(List<? extends Boolean> condition, List<? extends T> thenResult, List<? extends T> elseResult) {
		return condition.get(0) ? thenResult : elseResult;
	}
	
	public static <T, Prop> List<? extends Boolean> onlyExists(List<? extends T> e, Function<T, List<? extends Prop>> getter, Function<T, List<?>> ... otherGetters) {
		T elem = e.get(0);
		return single(
				getter.apply(elem).size() >= 1
				&& Stream.of(otherGetters).allMatch(otherGetter -> otherGetter.apply(elem).size() == 0)
			);
	}
	
	public static <T> List<? extends T> onlyElement(List<? extends T> e) {
		if (e.size() == 1) {
			return e;
		}
		return empty();
	}
	
	public static List<? extends BigDecimal> coerceIntToNumber(List<? extends Integer> e) {
		return e.stream().map(BigDecimal::valueOf).collect(Collectors.toList());
	}
	public static <T> List<? extends T> coerceNothingToAnything(List<? extends Void> e) {
		return empty();
	}
	
	private static <T> List<? extends T> zipWith(List<? extends T> e1, List<? extends T> e2, BiFunction<T, T, T> f) {
		List<T> res = new ArrayList<T>(e1.size());
		for (int i=0; i<e1.size() && i<e2.size(); i++) {
			res.add(f.apply(e1.get(i), e2.get(i)));
		}
		return res;
	}
}
