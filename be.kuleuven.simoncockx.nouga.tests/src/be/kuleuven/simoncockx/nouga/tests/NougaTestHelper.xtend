package be.kuleuven.simoncockx.nouga.tests

import be.kuleuven.simoncockx.nouga.nouga.Model
import org.eclipse.xtext.testing.util.ParseHelper
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.Expression
import be.kuleuven.simoncockx.nouga.typing.NougaTyping
import be.kuleuven.simoncockx.nouga.nouga.ListType
import static extension org.junit.jupiter.api.Assertions.*
import be.kuleuven.simoncockx.nouga.typing.TypeUtil
import org.eclipse.xtext.testing.validation.ValidationTestHelper

class NougaTestHelper {
	@Inject
	extension ParseHelper<Model> parseHelper
	@Inject
	extension NougaTyping
	@Inject
	TypeUtil typeUtil
	@Inject
	extension ValidationTestHelper
	
	def Expression parseExpression(CharSequence expr, String type) {
		val model = '''
			namespace test
			
			func Test:
				inputs:
				output: result «type»
				assign-output: «expr»
		'''.parse;
		return (model.elements.last as Function).operation;
	}
	def Expression parseExpression(CharSequence expr) {
		var pexpr = parseExpression(expr, 'nothing (0..0)')
		pexpr.assertWellTyped
		pexpr = parseExpression(expr, typeUtil.listTypeToString(pexpr.staticType));
		pexpr.assertNoErrors
		return pexpr
	}
	
	def ListType getType(CharSequence expr) {
		return getType(expr.parseExpression);
	}
	def ListType getType(Expression expr) {
		val res = expr.inferType();
		assertFalse(res.failed);
		return res.value;
	}
	
	def void assertListTypeEquals(ListType a, ListType b) {
		typeUtil.listTypesAreEqual(a, b).assertTrue
	}
	def void assertListSubtype(ListType a, ListType b) {
		assertTrue(listSubtype(a, b).value)
	}
	def void assertWellTyped(Expression e) {
		val illTyped = typeUtil.getIllTypedContent(e);
		assertTrue(illTyped.empty,
			'''Expression is ill-typed: `«e.stringRep»`. Failed to infer type of «illTyped.join(', ')["`" + it.stringRep + "`"]».''')
	}
}