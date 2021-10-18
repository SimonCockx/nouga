package be.kuleuven.simoncockx.nouga.tests

import be.kuleuven.simoncockx.nouga.typing.TypeFactory
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

@ExtendWith(InjectionExtension)
@InjectWith(NougaInjectorProvider)
class TypingTest {
	@Inject
	extension NougaTestHelper
	@Inject
	extension TypeFactory
	
	@Test
	def void testLiteralTyping() {
		'''
			False
		'''.type.assertTypeEquals(singleBoolean);
		'''
			-5.32e7
		'''.type.assertTypeEquals(singleNumber);
		'''
			42
		'''.type.assertTypeEquals(singleInt);

	}
}