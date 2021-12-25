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
		'False'.type.assertListTypeEquals(singleBoolean);
		'-5.32e7'.type.assertListTypeEquals(singleNumber);
		'42'.type.assertListTypeEquals(singleInt);
		'[]'.type.assertListTypeEquals(emptyNothing);
	}
	
	@Test
	def void testSubtyping() {
		val t1 = createListType(BuiltInTypeEnum.INT, 1, 3);
		val t2 = createListType(BuiltInTypeEnum.NUMBER, 1, 5);
		t1.assertListSubtype(t2)
		
		val model = '''
		namespace test
		
		type A:
		type B extends A:
		'''.parse
		model.assertNoErrors;
		val a = model.elements.head as Data
		val b = model.elements.last as Data
		createListType(b, 1, 1).assertListSubtype(createListType(a, 1, 1))
	}
	
	@Test
	def void testTList() {
		'[2, 4.5, 7, -3.14]'.type.assertListTypeEquals(createListType(BuiltInTypeEnum.NUMBER, 4, 4));
	}
	
	@Test
	def void testTBooleanOperation() {
		'True or False'.type.assertListTypeEquals(singleBoolean);
		'True and False'.type.assertListTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTNot() {
		'not True'.type.assertListTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTExists() {
		'(if True then empty else 1) exists'.type.assertListTypeEquals(singleBoolean);
		'(if True then empty else 1) single exists'.type.assertListTypeEquals(singleBoolean);
		'(if True then 1 else [2, 3]) single exists'.type.assertListTypeEquals(singleBoolean);
		'(if True then 1 else [2, 3]) multiple exists'.type.assertListTypeEquals(singleBoolean);
		'(if True then empty else 1) is absent'.type.assertListTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTContains() {
		'[3.5, 1.0] contains [5, 2, 10]'.type.assertListTypeEquals(singleBoolean);
		'[3, 1] disjoint [5.1, 10.0, -5.3]'.type.assertListTypeEquals(singleBoolean);
	}
	
	@Test
	def void testTEquals() {
		'''
		(if True then [1] else [2, 3]) = (if False then [4.0, 5] else [6.0, 7, 8])
		'''.type.assertListTypeEquals(singleBoolean)
		'''
		(if True then [1] else [2, 3]) <> (if False then [4.0, 5] else [6.0, 7, 8])
		'''.type.assertListTypeEquals(singleBoolean)
		'[1, 3] all = 5.0'.type.assertListTypeEquals(singleBoolean)
		'empty all <> 5.0'.type.assertListTypeEquals(singleBoolean)
		'[1, 3] any = 5.0'.type.assertListTypeEquals(singleBoolean)
		'[3.0] any <> 5'.type.assertListTypeEquals(singleBoolean)
	}
	
	@Test
	def void testTArithmetic() {
		'3 + 4'.type.assertListTypeEquals(singleInt)
		'3.0 + 4'.type.assertListTypeEquals(singleNumber)
		'3 + 4.0'.type.assertListTypeEquals(singleNumber)
		'3.0 + 4.0'.type.assertListTypeEquals(singleNumber)
		'3 - 4'.type.assertListTypeEquals(singleInt)
		'3 - 4.0'.type.assertListTypeEquals(singleNumber)
		'3 * 4'.type.assertListTypeEquals(singleInt)
		'3.0 * 4'.type.assertListTypeEquals(singleNumber)
		'3 / 4'.type.assertListTypeEquals(singleNumber)
	}
	
	@Test
	def void testTCount() {
		'[] count'.type.assertListTypeEquals(singleInt);
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
		val expression = (model.elements.last as Function).operation;
		expression.assertWellTyped;
		model.assertNoErrors;
		expression.type.assertListTypeEquals(createListType(^int, 6, 35));
	}
	
	@Test
	def void testTIf() {
		'if True then [1, 2] else [3.0, 4.0, 5.0, 6.0]'.type.assertListTypeEquals(createListType(number, 2, 4));
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
		val expression = (model.elements.last as Function).operation;
		expression.assertWellTyped;
		model.assertNoErrors;
		expression.type.assertListTypeEquals(createListType(number, 3, 5));
	}
	
	@Test
	def void testTInstantiate() {
		val model = '''
		namespace test
		
		type Super:
			n int (1..1)
		type MyType extends Super:
			val int (2..7)
			otherVal boolean (0..1)
		func Test:
			inputs:
			output: result MyType (1..1)
			assign-output:
				MyType {val: [1, 2], n: 42, otherVal: empty}
		'''.parse
		val expression = (model.elements.last as Function).operation;
		expression.assertWellTyped;
		model.assertNoErrors;
		val data = model.elements.get(1) as Data
		expression.type.assertListTypeEquals(createListType(data, 1, 1));
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
		val expression = (model.elements.last as Function).operation;
		expression.assertWellTyped;
		model.assertNoErrors;
		expression.type.assertListTypeEquals(createListType(number, 2, 4));
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
		val expression = (model.elements.last as Function).operation;
		expression.assertWellTyped;
		model.assertNoErrors;
		expression.type.assertListTypeEquals(createListType(^boolean, 1, 1));
	}
}