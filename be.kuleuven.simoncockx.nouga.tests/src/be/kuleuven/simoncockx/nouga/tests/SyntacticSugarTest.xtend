package be.kuleuven.simoncockx.nouga.tests

import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.InjectWith
import com.google.inject.Inject
import static extension org.junit.jupiter.api.Assertions.*
import org.eclipse.emf.ecore.util.EcoreUtil.EqualityHelper;
import org.junit.jupiter.api.Test
import be.kuleuven.simoncockx.nouga.nouga.ConditionalExpression

@ExtendWith(InjectionExtension)
@InjectWith(NougaInjectorProvider)
class SyntacticSugarTest {
	@Inject
	extension NougaTestHelper
	@Inject
	EqualityHelper eqHelper;
	
	@Test
	def void testEmpty() {
		eqHelper.equals('empty'.parseExpression, '[]'.parseExpression).assertTrue
	}
	
	@Test
	def void testIfThen() {
		'if True then False'.parseExpression as ConditionalExpression => [
			isFull.assertFalse;
			eqHelper.equals(elsethen, 'empty'.parseExpression).assertTrue
		]
	}
}
