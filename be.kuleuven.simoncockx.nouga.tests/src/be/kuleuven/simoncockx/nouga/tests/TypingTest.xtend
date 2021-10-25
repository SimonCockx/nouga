package be.kuleuven.simoncockx.nouga.tests

import be.kuleuven.simoncockx.nouga.typing.TypeFactory
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum
import org.eclipse.xtext.testing.util.ParseHelper
import be.kuleuven.simoncockx.nouga.nouga.Model
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.Data

@ExtendWith(InjectionExtension)
@InjectWith(NougaInjectorProvider)
class TypingTest {
	@Inject
	extension ParseHelper<Model> parseHelper
	@Inject
	extension ValidationTestHelper
	@Inject
	extension NougaTestHelper
	@Inject
	extension TypeFactory
	
	@Test
	def void testLiteralTyping() {
		'False'.type.assertTypeEquals(singleBoolean);
		'-5.32e7'.type.assertTypeEquals(singleNumber);
		'42'.type.assertTypeEquals(singleInt);
		'[]'.type.assertTypeEquals(emptyNothing);
	}
	
	@Test
	def void testSubtyping() {
		val t1 = createType(BuiltInTypeEnum.INT, 1, 3);
		val t2 = createType(BuiltInTypeEnum.NUMBER, 1, 5);
		t1.assertSubtype(t2)
	}
	
	@Test
	def void testTList() {
		'[2, 4.5, 7, -3.14]'.type.assertTypeEquals(createType(BuiltInTypeEnum.NUMBER, 4, 4));
	}
	
	@Test
	def void testTBooleanOperation() {
		'True or False'.type.assertTypeEquals(singleBoolean);
		'True and False'.type.assertTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTExists() {
		'[] exists'.type.assertTypeEquals(singleBoolean);
		'[] single exists'.type.assertTypeEquals(singleBoolean);
		'[] multiple exists'.type.assertTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTContains() {
		'[3.5, 1.0] contains [5, 2, 10]'.type.assertTypeEquals(singleBoolean);
		'[3, 1] disjoint [5.1, 10.0, -5.3]'.type.assertTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTEquals() {
		'''
		(if True then [1] else [2, 3]) = (if False then [4.0, 5] else [6.0, 7, 8])
		'''.type.assertTypeEquals(singleBoolean)
		'''
		(if True then [1] else [2, 3]) <> (if False then [4.0, 5] else [6.0, 7, 8])
		'''.type.assertTypeEquals(singleBoolean)
		'[1, 3] all = 5.0'.type.assertTypeEquals(singleBoolean)
		'empty all <> 5.0'.type.assertTypeEquals(singleBoolean)
		'[1, 3] any = 5.0'.type.assertTypeEquals(singleBoolean)
		'[3.0] any <> 5'.type.assertTypeEquals(singleBoolean)
	}
	
	@Test
	def void testTArithmetic() {
		'3 + 4'.type.assertTypeEquals(singleInt)
		'3.0 + 4'.type.assertTypeEquals(singleNumber)
		'3 + 4.0'.type.assertTypeEquals(singleNumber)
		'3.0 + 4.0'.type.assertTypeEquals(singleNumber)
		'3 - 4'.type.assertTypeEquals(singleInt)
		'3 - 4.0'.type.assertTypeEquals(singleNumber)
		'3 * 4'.type.assertTypeEquals(singleInt)
		'3.0 * 4'.type.assertTypeEquals(singleNumber)
		'3 / 4'.type.assertTypeEquals(singleNumber)
	}
	
	@Test
	def void testTCount() {
		'[] count'.type.assertTypeEquals(singleInt);
	}
	
	@Test
	def void testTProject() {
		val model = '''
		namespace test
		
		type MyType:
			val int (2..7)
		func CreateMyTypes:
			inputs:
			output: result MyType (3..5)
			assign-output:
				[ MyType {val: [1, 2]}
				, MyType {val: [3, 4, 5, 6]}
				, MyType {val: [7, 8]}
				]
		func Test:
			inputs:
			output: result int (6..35)
			assign-output:
				CreateMyTypes() -> val
		'''.parse
		model.assertNoErrors;
		val expression = (model.elements.last as Function).operation;
		expression.type.assertTypeEquals(createType(^int, 6, 35));
	}
	
	@Test
	def void testTIf() {
		'if True then [1, 2] else [3.0, 4.0, 5.0, 6.0]'.type.assertTypeEquals(createType(number, 2, 4));
	}
	
	@Test
	def void testTFunc() {
		val model = '''
		namespace test
		
		func SomeFunc:
			inputs:
			output: result number (3..5)
			assign-output:
				[1.0, 2.0, 3.0]
		func Test:
			inputs:
			output: result number (3..5)
			assign-output:
				SomeFunc()
		'''.parse
		model.assertNoErrors;
		val expression = (model.elements.last as Function).operation;
		expression.type.assertTypeEquals(createType(number, 3, 5));
	}
	
	@Test
	def void testTConstruct() {
		val model = '''
		namespace test
		
		type MyType:
			val int (2..7)
			otherVal boolean (0..1)
		func Test:
			inputs:
			output: result MyType (1..1)
			assign-output:
				MyType {val: [1, 2], otherVal: empty}
		'''.parse
		model.assertNoErrors;
		val data = model.elements.head as Data
		val expression = (model.elements.last as Function).operation;
		expression.type.assertTypeEquals(createType(data, 1, 1));
	}
	
	@Test
	def void testTVar() {
		val model = '''
		namespace test

		func Id:
			inputs: input number (2..4)
			output: result number (2..4)
			assign-output:
				input
		'''.parse
		model.assertNoErrors;
		val expression = (model.elements.last as Function).operation;
		expression.type.assertTypeEquals(createType(number, 2, 4));
	}
	
	@Test
	def void testTOnlyExists() {
		val model = '''
		namespace test
		
		type MyType:
			val boolean (0..1)
			otherVal boolean (0..1)
		func Test:
			inputs:
			output: result boolean (1..1)
			assign-output:
				MyType {val: True, otherVal: empty} -> val only exists
		'''.parse
		model.assertNoErrors;
		val expression = (model.elements.last as Function).operation;
		expression.type.assertTypeEquals(createType(^boolean, 1, 1));
	}
}