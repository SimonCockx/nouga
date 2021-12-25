package be.kuleuven.simoncockx.nouga.typing;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.emf.ecore.util.EcoreUtil.EqualityHelper;

import com.google.inject.Inject;

import be.kuleuven.simoncockx.nouga.nouga.ListType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType;
import be.kuleuven.simoncockx.nouga.nouga.CardinalityConstraint;
import be.kuleuven.simoncockx.nouga.nouga.DataType;
import be.kuleuven.simoncockx.nouga.nouga.Expression;
import be.kuleuven.simoncockx.nouga.nouga.Type;

public class TypeUtil {
	@Inject
	private EqualityHelper eqHelper;
	@Inject
	private TypeFactory fac;
	
	public boolean isWellTyped(Expression e) {
		return getIllTypedContent(e).isEmpty();
	}
	public Set<Expression> getIllTypedContent(Expression e) {
		Set<Expression> result = new HashSet<Expression>();
		if (e.getStaticType() == null) {
			result.add(e);
		}
		e.eAllContents().forEachRemaining((obj) -> {
			if (obj instanceof Expression) {
				Expression sub = (Expression)obj;
				if (sub.getStaticType() == null) {
					result.add(sub);
				}
			}
		});
		return result;
	}
	public boolean typesAreEqual(Type a, Type b) {
		return eqHelper.equals(a, b);
	}
	public boolean listTypesAreEqual(ListType a, ListType b) {
		return typesAreEqual(a.getItemType(), b.getItemType())
				&& constraintsAreEqual(a.getConstraint(), b.getConstraint());
	}
	public boolean constraintsAreEqual(CardinalityConstraint c1, CardinalityConstraint c2) {
		return c1.getInf() == c2.getInf()
			&& (c1.isUnbounded() && c2.isUnbounded() || c1.getSup() == c2.getSup());
	}
	public boolean isSubconstraint(CardinalityConstraint sub, CardinalityConstraint sup) {
		return sub.getInf() >= sup.getInf()
			&& (sup.isUnbounded() || !sub.isUnbounded() && sub.getSup() <= sup.getSup());
	}
	public CardinalityConstraint multiply(CardinalityConstraint c1, CardinalityConstraint c2) {
		if (c1.isUnbounded() || c2.isUnbounded()) {
			return fac.createUnboundedConstraint(c1.getInf() * c2.getInf());
		}
		return fac.createConstraint(c1.getInf() * c2.getInf(), c1.getSup() * c2.getSup());
	}
	public CardinalityConstraint add(CardinalityConstraint c1, CardinalityConstraint c2) {
		if (c1.isUnbounded() || c2.isUnbounded()) {
			return fac.createUnboundedConstraint(c1.getInf() + c2.getInf());
		}
		return fac.createConstraint(c1.getInf() + c2.getInf(), c1.getSup() + c2.getSup());
	}
	public String typeToString(Type type) {
		if (type instanceof BuiltInType) {
			return ((BuiltInType)type).getType().getLiteral();
		}
		return ((DataType)type).getData().getName();
	}
	public String constraintToString(CardinalityConstraint c) {
		if (c.isUnbounded()) {
			return "(" + c.getInf() + "..*)"; 
		}
		return "(" + c.getInf() + ".." + c.getSup() + ")";
	}
	public String listTypeToString(ListType listType) {
		return typeToString(listType.getItemType()) + " " + constraintToString(listType.getConstraint());
	}
}
