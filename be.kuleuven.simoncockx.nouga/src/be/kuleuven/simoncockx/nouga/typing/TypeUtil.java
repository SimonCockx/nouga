package be.kuleuven.simoncockx.nouga.typing;

import org.eclipse.emf.ecore.util.EcoreUtil.EqualityHelper;

import com.google.inject.Inject;

import be.kuleuven.simoncockx.nouga.nouga.BasicType;
import be.kuleuven.simoncockx.nouga.nouga.Cardinality;
import be.kuleuven.simoncockx.nouga.nouga.Type;

public class TypeUtil {
	@Inject
	private EqualityHelper eqHelper;
	
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
			&& (sup.isUnbounded() || !sub.isUnbounded() && sub.getInf() <= sup.getInf());
	}
}
