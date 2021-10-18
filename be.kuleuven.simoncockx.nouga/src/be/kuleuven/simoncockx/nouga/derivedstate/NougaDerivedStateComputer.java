package be.kuleuven.simoncockx.nouga.derivedstate;

import org.eclipse.xtext.resource.DerivedStateAwareResource;
import org.eclipse.xtext.resource.IDerivedStateComputer;

import com.google.inject.Inject;

import be.kuleuven.simoncockx.nouga.nouga.ConditionalExpression;
import be.kuleuven.simoncockx.nouga.nouga.NougaFactory;

public class NougaDerivedStateComputer implements IDerivedStateComputer {
	
	@Override
	public void installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase) {
			resource.getAllContents().forEachRemaining((obj) -> {
				if (obj instanceof ConditionalExpression) {
					this.setDefaultElseToEmpty((ConditionalExpression)obj);
				}
			});
		}
	}

	@Override
	public void discardDerivedState(DerivedStateAwareResource resource) {
		resource.getAllContents().forEachRemaining((obj) -> {
			if (obj instanceof ConditionalExpression) {
				this.discardDefaultElse((ConditionalExpression)obj);
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
}
