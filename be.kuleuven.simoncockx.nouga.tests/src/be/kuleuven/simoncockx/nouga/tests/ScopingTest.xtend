package be.kuleuven.simoncockx.nouga.tests

import be.kuleuven.simoncockx.nouga.nouga.Model
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.ProjectionExpression
import be.kuleuven.simoncockx.nouga.nouga.Data
import static extension org.junit.jupiter.api.Assertions.*
import be.kuleuven.simoncockx.nouga.nouga.VariableReference
import be.kuleuven.simoncockx.nouga.nouga.DataConstructionExpression

@ExtendWith(InjectionExtension)
@InjectWith(NougaInjectorProvider)
class ScopingTest {
	@Inject
	extension ParseHelper<Model> parseHelper
	@Inject
	extension ValidationTestHelper
	
	@Test
	def void superTypeScopePositiveTest() {
		val model = '''
			namespace just.some.package
			
			type MyType:
				val boolean (1..1)
			
			type MySubType extends MyType:
				anotherVal int (1..1)
		'''.parse;
		model.assertNoErrors;
		model => [
			(elements.last as Data).superType.
				assertSame(elements.head)
		]
	}
	
	@Test
	def void variableScopePositiveTest() {
		val model = '''
			namespace just.some.package
			
			func Project:
				inputs: inp int (1..1)
				output: result int (1..1)
				assign-output:
					inp
		'''.parse;
		model.assertNoErrors;
		model.elements.last as Function => [
			(operation as VariableReference).reference.
				assertSame(inputs.head)
		]
	}
	
	@Test
	def void constructionScopePositiveTest() {
		val model = '''
			namespace just.some.package
			
			type SuperType:
				n int (1..1)
			type MyType extends SuperType:
				val boolean (1..1)
			
			func Create:
				inputs:
				output: result MyType (1..1)
				assign-output:
					MyType { val: True, n: 1 }
		'''.parse;
		model.assertNoErrors;
		val superType = model.elements.head as Data;
		val myType = model.elements.get(1) as Data;
		model.elements.last as Function => [
			(operation as DataConstructionExpression).values => [
				head.key.assertSame(myType.attributes.head)
				last.key.assertSame(superType.attributes.head)
			]
		]
	}
	
	@Test
	def void projectionScopePositiveTest() {
		val model = '''
			namespace just.some.package
			
			type SuperType:
				n int (1..1)
			type MyType extends SuperType:
				val boolean (1..1)
			
			func Project:
				inputs:
				output: result int (1..1)
				assign-output:
					MyType { val: True, n: 1 } -> n
		'''.parse;
		model.assertNoErrors;
		model => [
			((elements.last as Function).operation as ProjectionExpression).attribute.
				assertSame((elements.head as Data).attributes.head)
		]
	}
}