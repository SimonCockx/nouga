package be.kuleuven.simoncockx.nouga.lib;

import java.math.BigDecimal;
import java.math.MathContext;

/**
 * A class that behaves similar to BigDecimal, but ignores precision when checking
 * equality.
 */
public class NougaNumber extends Number {
	public static final MathContext DECIMAL_PRECISION = MathContext.DECIMAL128;
	private static final long serialVersionUID = 1L;

	private final BigDecimal value;
	
	public NougaNumber(BigDecimal value) {
		this.value = value;
	}
	public NougaNumber(String repr) {
		this.value = new BigDecimal(repr);
	}
	
	public static NougaNumber valueOf(double value) {
		return new NougaNumber(BigDecimal.valueOf(value));
	}
	public static NougaNumber valueOf(long value) {
		return new NougaNumber(BigDecimal.valueOf(value));
	}
	
	public NougaNumber add(NougaNumber other) {
		return new NougaNumber(this.value.add(other.value));
	}
	public NougaNumber subtract(NougaNumber other) {
		return new NougaNumber(this.value.subtract(other.value));
	}
	public NougaNumber multiply(NougaNumber other) {
		return new NougaNumber(this.value.multiply(other.value));
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
		return this.value.toString();
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
