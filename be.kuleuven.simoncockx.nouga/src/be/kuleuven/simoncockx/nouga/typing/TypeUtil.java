package be.kuleuven.simoncockx.nouga.typing;

import org.eclipse.emf.ecore.util.EcoreUtil.EqualityHelper;

import com.google.inject.Inject;

import be.kuleuven.simoncockx.nouga.nouga.BasicType;
import be.kuleuven.simoncockx.nouga.nouga.Cardinality;
import be.kuleuven.simoncockx.nouga.nouga.Type;

public class TypeUtil {
	@Inject
	private EqualityHelper eqHelper;
	@Inject
	private TypeFactory fac;
	
	public boolean basicTypesAreEqual(BasicType a, BasicType b) {
		return eqHelper.equals(a, b);
	}
	public boolean typesAreEqual(Type a, Type b) {
		return basicTypesAreEqual(a.getBasicType(), b.getBasicType())
				&& cardinalitiesAreEqual(a.getCardinality(), b.getCardinality());
	}
	public boolean cardinalitiesAreEqual(Cardinality c1, Cardinality c2) {
		return c1.getInf() == c2.getInf()
			&& (c1.isUnbounded() && c2.isUnbounded() || c1.getSup() == c2.getSup());
	}
	public boolean isSubcardinality(Cardinality sub, Cardinality sup) {
		return sub.getInf() >= sup.getInf()
			&& (sup.isUnbounded() || !sub.isUnbounded() && sub.getSup() <= sup.getSup());
	}
	public Cardinality multiply(Cardinality c1, Cardinality c2) {
		if (c1.isUnbounded() || c2.isUnbounded()) {
			return fac.createUnboundedCardinality(c1.getInf() * c2.getInf());
		}
		return fac.createCardinality(c1.getInf() * c2.getInf(), c1.getSup() * c2.getSup());
	}
	public Cardinality add(Cardinality c1, Cardinality c2) {
		if (c1.isUnbounded() || c2.isUnbounded()) {
			return fac.createUnboundedCardinality(c1.getInf() + c2.getInf());
		}
		return fac.createCardinality(c1.getInf() + c2.getInf(), c1.getSup() + c2.getSup());
	}
}
