package be.kuleuven.simoncockx.nouga.lib;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;

/**
 * An implementation of the IEEE754 decimal128 standard. Under the hood, this class uses
 * BigDecimal. Also see {@link MathContext#DECIMAL128}.
 * (Actually, *almost* an implementation of the decimal128 standard. 
 *  See section "Relation to IEEE 754 Decimal Arithmetic" in the
 *  BigDecimal documentation for edge cases:
 *  https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/math/BigDecimal.html
 * )
 * 
 * Note that this class circumvents problems caused by a
 * per-instance precision, like in BigDecimal.
 * E.g., for equality, see https://stackoverflow.com/q/6787142/3083982
 */
public class NougaNumber extends Number {
	public static final MathContext DECIMAL_PRECISION = MathContext.DECIMAL128;
	private static final long serialVersionUID = 1L;

	private final BigDecimal value;
	
	private NougaNumber(BigDecimal value) {
		this.value = value;
	}
	public NougaNumber(String repr) {
		this(new BigDecimal(repr, DECIMAL_PRECISION));
	}
	
	public static NougaNumber valueOf(double value) {
		return new NougaNumber(Double.toString(value));
	}
	public static NougaNumber valueOf(long value) {
		return new NougaNumber(new BigDecimal(value, DECIMAL_PRECISION));
	}
	
	public NougaNumber add(NougaNumber other) {
		return new NougaNumber(this.value.add(other.value));
	}
	public NougaNumber subtract(NougaNumber other) {
		return new NougaNumber(this.value.subtract(other.value));
	}
	public NougaNumber multiply(NougaNumber other) {
		return new NougaNumber(this.value.multiply(other.value, DECIMAL_PRECISION));
	}
	public NougaNumber divide(NougaNumber other) {
		return new NougaNumber(this.value.divide(other.value, DECIMAL_PRECISION));
	}
	
	@Override
	public boolean equals(Object obj) {
		if (obj == null) {
            return false;
        }

        if (obj.getClass() != this.getClass()) {
            return false;
        }

        final NougaNumber other = (NougaNumber) obj;
        return this.value.compareTo(other.value) == 0;
	}
	
	@Override
	public int hashCode() {
		return this.value.stripTrailingZeros().hashCode();
	}
	
	@Override
	public String toString() {
		return this.value.stripTrailingZeros().toString();
	}
	
	@Override
	public int intValue() {
		return value.intValue();
	}

	@Override
	public long longValue() {
		return value.longValue();
	}

	@Override
	public float floatValue() {
		return value.floatValue();
	}

	@Override
	public double doubleValue() {
		return value.doubleValue();
	}

}
