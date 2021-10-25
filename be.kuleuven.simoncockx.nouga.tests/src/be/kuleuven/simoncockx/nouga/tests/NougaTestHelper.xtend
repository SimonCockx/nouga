package be.kuleuven.simoncockx.nouga.tests

import be.kuleuven.simoncockx.nouga.nouga.Model
import org.eclipse.xtext.testing.util.ParseHelper
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.Expression
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import be.kuleuven.simoncockx.nouga.typing.NougaTyping
import be.kuleuven.simoncockx.nouga.nouga.Type
import static extension org.junit.jupiter.api.Assertions.*
import be.kuleuven.simoncockx.nouga.typing.TypeUtil

class NougaTestHelper {
	@Inject
	extension ParseHelper<Model> parseHelper
	@Inject
	extension ValidationTestHelper
	@Inject
	extension NougaTyping
	@Inject
	TypeUtil typeUtil
	
	def Expression parseExpression(CharSequence expr) {
		val model = '''
			namespace test
			
			func Test:
				inputs:
				output: result boolean (1..1)
				assign-output: «expr»
		'''.parse;
		return (model.elements.last as Function).operation;
	}
	
	def Type getType(CharSequence expr) {
		return getType(expr.parseExpression);
	}
	def Type getType(Expression expr) {
		val res = expr.type();
		assertFalse(res.failed);
		return res.value;
	}
	
	def void assertTypeEquals(Type a, Type b) {
		typeUtil.typesAreEqual(a, b).assertTrue
	}
	def void assertSubtype(Type a, Type b) {
		assertTrue(subtype(a, b).value)
	}
}