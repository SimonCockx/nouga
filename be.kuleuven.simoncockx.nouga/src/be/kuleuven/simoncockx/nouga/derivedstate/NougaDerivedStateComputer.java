package be.kuleuven.simoncockx.nouga.derivedstate;

import org.eclipse.xtext.resource.DerivedStateAwareResource;
import org.eclipse.xtext.resource.IDerivedStateComputer;

import com.google.inject.Inject;

import be.kuleuven.simoncockx.nouga.nouga.ConditionalExpression;
import be.kuleuven.simoncockx.nouga.nouga.Expression;
import be.kuleuven.simoncockx.nouga.nouga.Function;
import be.kuleuven.simoncockx.nouga.nouga.KeyValuePair;
import be.kuleuven.simoncockx.nouga.nouga.NougaFactory;
import be.kuleuven.simoncockx.nouga.typing.NougaTyping;

/**
 * Derived state:
 * - syntactic sugar for if-then: automatically add 'empty' to the 'else' clause.
 * - typing expressions
 */
public class NougaDerivedStateComputer implements IDerivedStateComputer {
	@Inject
	private NougaTyping typing;
	
	@Override
	public void installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			resource.getAllContents().forEachRemaining((obj) -> {
				if (obj instanceof ConditionalExpression) {
					this.setDefaultElseToEmpty((ConditionalExpression)obj);
				}
			});
			resource.getAllContents().forEachRemaining((obj) -> {
				if (obj instanceof Function) {
					this.setStaticTypeRecursively(((Function)obj).getOperation());
				}
			});
		}
	}

	@Override
	public void discardDerivedState(DerivedStateAwareResource resource) {
		resource.getAllContents().forEachRemaining((obj) -> {
			if (obj instanceof Expression) {
				this.discardStaticType((Expression)obj);
				if (obj instanceof ConditionalExpression) {
					this.discardDefaultElse((ConditionalExpression)obj);
				}
			}
		});
	}
	
	private void setDefaultElseToEmpty(ConditionalExpression expr) {
		if (!expr.isFull()) {
			expr.setElsethen(NougaFactory.eINSTANCE.createListLiteral());
		}
	}
	private void discardDefaultElse(ConditionalExpression expr) {
		if (!expr.isFull()) {
			expr.setElsethen(null);
		}
	}
	private void setStaticTypeRecursively(Expression expr) {
		expr.eContents().forEach((obj) -> {
			if (obj instanceof Expression) {
				this.setStaticTypeRecursively((Expression)obj);
			} else if (obj instanceof KeyValuePair) {
				this.setStaticTypeRecursively(((KeyValuePair)obj).getValue());
			}
		});
		expr.setStaticType(typing.inferType(expr).getValue());
	}
	private void discardStaticType(Expression expr) {
		expr.setStaticType(null);
	}
}
