package be.kuleuven.simoncockx.nouga.tests

import org.junit.jupiter.api.^extension.ExtendWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.jupiter.api.Test
import static extension org.junit.jupiter.api.Assertions.*
import java.lang.reflect.Modifier
import java.util.List
import java.lang.reflect.ParameterizedType
import java.lang.reflect.Type
import java.lang.reflect.WildcardType
import be.kuleuven.simoncockx.nouga.generator.JavaNameUtil
import org.eclipse.xtext.util.IAcceptor
import com.google.inject.Guice
import com.google.inject.AbstractModule
import org.junit.jupiter.api.BeforeEach
import org.eclipse.xtext.util.JavaVersion
import be.kuleuven.simoncockx.nouga.lib.NougaNumber
import org.eclipse.xtext.testing.util.ParseHelper
import be.kuleuven.simoncockx.nouga.nouga.Model
import be.kuleuven.simoncockx.nouga.nouga.Function
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import be.kuleuven.simoncockx.nouga.lib.NougaEntity

@ExtendWith(InjectionExtension)
@InjectWith(NougaInjectorProvider)
class GenerationTest {
	@Inject extension CompilationTestHelper
	@Inject extension JavaNameUtil
	@Inject extension ParseHelper<Model>
	@Inject extension ValidationTestHelper
	@Inject extension NougaTestHelper
	
	@BeforeEach                                         
    def setUp() {
        javaVersion = JavaVersion.JAVA8
    }
	
	@Test
	def void testEmptyEntity() {
		'''
		namespace mydummypackage
		
		type EmptyEntity:
		'''.compile[
			getCompiledClass => [
				canonicalName.assertEquals("mydummypackage.EmptyEntity");
				declaredConstructors => [
					length.assertEquals(1);
					get(0).parameterCount.assertEquals(0);
				]
				declaredFields.length.assertEquals(0);
				declaredMethods.length.assertEquals(4);
				Modifier.isPublic(modifiers)
				NougaEntity.assertEquals(superclass)
			]
		]
	}
	
	@Test
	def void testConstructorAndGetters() {
		'''
		namespace mydummypackage
		
		type Entity:
			someNumber number (1..1)
			flags boolean (0..*)
		'''.compile[
			getCompiledClass => [c |
				c.declaredConstructors.head => [
					parameterCount.assertEquals(2);
					parameters => [
						get(0).type.assertEquals(NougaNumber)
						get(1).parameterizedType.assertListType(Boolean)
					]
					newInstance(NougaNumber.valueOf(5), #[true, false]) => [
						NougaNumber.valueOf(5).assertEquals(c.getDeclaredMethod("getSomeNumber").invoke(it));
						#[true, false].assertListEquals(c.getDeclaredMethod("getFlags").invoke(it));
						#["someNumber", "flags"].assertListEquals(c.getMethod("getAttributeNames").invoke(it));
					]
				]
			]			
		]
	}
	
	@Test
	def void testComposition() {
		'''
		namespace mydummypackage
		
		type A:
		  n int (1..2)
		type B:
		  a A (1..1)
		'''.compile[c |
			c.getCompiledClass('mydummypackage.A') => [
				val a = getDeclaredConstructor(List).newInstance(#[1] as Object);
				c.getCompiledClass('mydummypackage.B') => [
					val b = declaredConstructors.head.newInstance(a);
					a.assertEquals(getDeclaredMethod('getA').invoke(b))
				]
			]
		]
	}
	
	@Test
	def void testInheritance() {
		'''
		namespace mydummypackage
		
		type A:
		  n int (1..2)
		type B extends A:
		  f boolean (1..1)
		'''.compile[c |
			c.getCompiledClass('mydummypackage.A') => [A |
				c.getCompiledClass('mydummypackage.B') => [
					superclass.assertEquals(A)
					val b = declaredConstructors.head.newInstance(#[1, 2] as Object, true);
					#[1, 2].assertListEquals(A.getDeclaredMethod('getN').invoke(b));
					true.assertEquals(getDeclaredMethod('getF').invoke(b))
					#["n", "f"].assertListEquals(getMethod("getAttributeNames").invoke(b));
				]
			]
		]
	}
	
	@Test
	def void testFunction() {
		'''
		namespace mydummypackage
		
		func SimpleFunc:
		  inputs: inp int (1..1)
		  output: result number (1..2)
		  assign-output: 1 + inp
		'''.compile[
			getCompiledClass => [c |
				c.declaredConstructor.newInstance => [
					#[NougaNumber.valueOf(42)].assertListEquals(c.getDeclaredMethod(evaluationName, int).invoke(it, 41))
				]
			]
		]
	}
	
	@Test
	def void testCoercions() {
		evaluateExpression('number (1..1)', '42')[NougaNumber.valueOf(42).assertEquals(it)]
		evaluateExpression('int (0..1)', 'empty')[assertNull]
		evaluateExpression('int (0..*)', 'empty')[#[].assertListEquals(it)]
		evaluateExpression('int (0..*)', '1')[#[1].assertListEquals(it)]
		evaluateExpression('number (0..*)', '42')[#[NougaNumber.valueOf(42)].assertListEquals(it)]
	
		evaluateExpression('number (1..1)', '3 / 5')[NougaNumber.valueOf(0.6).assertEquals(it)];
		evaluateExpression('number (5..5)', '[[1, 2], [3.14, 5], 7]')[#[1.0, 2.0, 3.14, 5.0, 7.0].map[NougaNumber::valueOf(it)].assertEquals(it)]
	}
	
	@Test
	def void testLiterals() {
		evaluateExpression('boolean (1..1)', 'True')[true.assertEquals(it)];
		evaluateExpression('number (1..1)', '42.0')[NougaNumber.valueOf(42).assertEquals(it)];
		evaluateExpression('number (1..1)', '-.1')[NougaNumber.valueOf(-0.1).assertEquals(it)];
		evaluateExpression('number (1..1)', '3.')[NougaNumber.valueOf(3.0).assertEquals(it)];
		evaluateExpression('number (1..1)', '42.0e-3')[NougaNumber.valueOf(42.0e-3).assertEquals(it)];
		evaluateExpression('number (1..1)', '42.0e+5')[NougaNumber.valueOf(42.0e+5).assertEquals(it)];
		evaluateExpression('number (1..1)', '42.0E2')[NougaNumber.valueOf(42.0e2).assertEquals(it)];
		<Integer>evaluateExpression('int (1..1)', '42')[42.assertEquals(it)];
		evaluateExpression('nothing (0..0)', 'empty')[assertNull];
	}
	
	@Test
	def void testList() {
		evaluateExpression('int (3..3)', '[1, 2, 3]')[#[1, 2, 3].assertListEquals(it)];
		evaluateExpression('int (3..3)', '[1, [2, 3]]')[#[1, 2, 3].assertListEquals(it)];
		<Integer>evaluateExpression('int (1..1)', '[1]')[1.assertEquals(it)];
		evaluateExpression('A (2..2)', '[A {n: 1}, C {n: 2}]')[#[#[1], #[2]].assertListEquals(it.map[it.class.getMethod("getN").invoke(it)])]
		evaluateExpression('nothing (0..0)', '[]')[assertNull];
	}
	
	@Test
	def void testBooleanOperators() {
		evaluateExpression('boolean (1..1)', 'False or True')[true.assertEquals(it)]
		evaluateExpression('boolean (1..1)', 'False and True')[false.assertEquals(it)]
		evaluateExpression('boolean (1..1)', 'not True')[false.assertEquals(it)]
	}
	
	@Test
	def void testExistExpression() {
		evaluateExpression('boolean (1..1)', '(if True then empty else 0) exists')[false.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if False then empty else 0) exists')[true.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if True then empty else 0) single exists')[false.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if False then [1, 2] else 0) single exists')[true.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if True then [1, 2] else empty) multiple exists')[true.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if False then [1, 2] else empty) multiple exists')[false.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if True then empty else 0) is absent')[true.assertEquals(it)]
		evaluateExpression('boolean (1..1)', '(if False then empty else 0) is absent')[false.assertEquals(it)]
	}
	
	@Test
	def void testContainsExpression() {
		evaluateExpression('boolean (1..1)', '5 contains empty')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[3, 5, 6] contains [6, 3]')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[6, 3] contains [3, 5, 6]')[false.assertEquals(it)];
	}
	
	@Test
	def void testDisjointExpression() {
		evaluateExpression('boolean (1..1)', '5 disjoint empty')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[3, 5, 6] disjoint [6, 3]')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[6, 3] disjoint 5')[true.assertEquals(it)];
	}
	
	@Test
	def void testComparisonOperation() {
		evaluateExpression('boolean (1..1)', '1 = 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] = [1, 2]')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', 'empty = empty')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] = if True then 1 else [1, 2]')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] = [2, 1]')[false.assertEquals(it)];
		
		val a1 = 'A {n: [1, 2]}'
		val a2 = 'A {n: 1}'
		val b1 = '''B {a: «a1»}'''
		val b2 = '''B {a: «a2»}'''
		val c = 'C {n: 1}'
		evaluateExpression('boolean (1..1)', '''«a1» = «a1»''')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«b1» = «b1»''')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«a1» = «c»''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«a1» = «a2»''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«b1» = «b2»''')[false.assertEquals(it)];
		
		evaluateExpression('boolean (1..1)', '1.0 = 1.00')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '1 = 1.0')[true.assertEquals(it)];
		
		evaluateExpression('boolean (1..1)', '1 <> 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] <> [1, 3]')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', 'empty <> empty')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] <> if True then 1 else [1, 2]')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] <> [4, 3]')[true.assertEquals(it)];
		
		evaluateExpression('boolean (1..1)', 'empty all = 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '1 all = 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 1] all = 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] all = 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', 'empty all <> 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '1 all <> 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] all <> 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[2, 2] all <> 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', 'empty any = 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '1 any = 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] any = 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[2, 2] any = 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', 'empty any <> 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '1 any <> 1')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 2] any <> 1')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '[1, 1] any <> 1')[false.assertEquals(it)];
	}
	
	@Test
	def void testArithmeticOperation() {
		<Integer>evaluateExpression('int (1..1)', '5 + 12')[17.assertEquals(it)];
		<Integer>evaluateExpression('int (1..1)', '5 - 12')[(-7).assertEquals(it)];
		<Integer>evaluateExpression('int (1..1)', '5 * 12')[60.assertEquals(it)];
		
		evaluateExpression('number (1..1)', '5.0 + 12.250')[NougaNumber.valueOf(17.25).assertEquals(it)];
		evaluateExpression('number (1..1)', '5.0 - 5.001')[NougaNumber.valueOf(-0.001).assertEquals(it)];
		evaluateExpression('number (1..1)', '5.0 * 12.25')[NougaNumber.valueOf(61.250).assertEquals(it)];
		evaluateExpression('number (1..1)', '3.5 / 5.00')[NougaNumber.valueOf(0.7).assertEquals(it)];
	}
	
	@Test
	def void testCountExpression() {
		<Integer>evaluateExpression('int (1..1)', 'empty count')[0.assertEquals(it)];
		<Integer>evaluateExpression('int (1..1)', '0 count')[1.assertEquals(it)];
		<Integer>evaluateExpression('int (1..1)', '[-1, 7] count')[2.assertEquals(it)];
	}
	
	@Test
	def void testProjectionExpression() {
		evaluateExpression('int (1..2)', 'A {n: 1} -> n')[#[1].assertListEquals(it)];
		evaluateExpression('int (1..2)', 'C {n: [1, 2]} -> n')[#[1, 2].assertListEquals(it)];
		evaluateExpression('int (3..6)', '[A {n: 1}, A {n: [2, 3]}, A {n: 4}] -> n')[#[1, 2, 3, 4].assertListEquals(it)];
		evaluateExpression('int (3..3)', '[D {n: 1}, D {n: 2}, D {n: 3}] -> n')[#[1, 2, 3].assertListEquals(it)];
		evaluateExpression('int (0..2)', '(if True then empty else A {n: 1}) -> n')[#[].assertListEquals(it)];
	}
	
	@Test
	def void testConditionalExpression() {
		evaluateExpression('int (1..2)', 'if True then 1 else [1, 2]')[#[1].assertListEquals(it)];
		evaluateExpression('int (1..2)', 'if False then 1 else [1, 2]')[#[1, 2].assertListEquals(it)];
	}
	
	@Test
	def void testFunctionCall() {
		'''
		namespace mydummypackage
		
		func Add:
		  inputs:
		    a int (1..1)
		    b int (0..*)
		  output: result int (1..1)
		  assign-output: a + b count
		
		func Test:
		  inputs:
		  output: result int (1..1)
		  assign-output: Add(3, [1, 2, 3, 4])
		'''.compile[
			getCompiledClass('mydummypackage.functions.Test') => [c |
				val injector = Guice.createInjector(new AbstractModule() {override configure() {}});
				val test = injector.getInstance(c);
				7.assertEquals(c.getDeclaredMethod(evaluationName).invoke(test))
			]
		]
	}
	
	@Test
	def void testRecursion() {
		'''
		namespace mydummypackage
		
		func Fac:
		  inputs:
		    n int (1..1)
		  output: result int (1..1)
		  assign-output: if n = 0 then 1 else n * Fac(n-1)
		'''.compile[
			getCompiledClass('mydummypackage.functions.Fac') => [c |
				val injector = Guice.createInjector(new AbstractModule() {override configure() {}});
				val test = injector.getInstance(c);
				val fac = c.getDeclaredMethod(evaluationName, int);
				6.assertEquals(fac.invoke(test, 3));
				24.assertEquals(fac.invoke(test, 4));
			]
		]
	}
	
	@Test
	def void testOnlyElement() {
		<Integer>evaluateExpression('int (0..1)', '1 only-element')[1.assertEquals(it)];
		<Integer>evaluateExpression('int (0..1)', '[1, 2] only-element')[assertNull];
		<Integer>evaluateExpression('int (0..1)', 'empty only-element')[assertNull];
	}
	
	@Test
	def void testOnlyExists() {
		val e1 = 'E {f1: True, f2: empty, f3: empty}';
		val e2 = 'E {f1: True, f2: True, f3: empty}';
		val e3 = 'E {f1: True, f2: True, f3: [True, False]}';
		val e4 = 'E {f1: empty, f2: [True, False], f3: empty}';
		val e5 = 'E {f1: empty, f2: empty, f3: [False, True]}';
		val e6 = 'E {f1: empty, f2: True, f3: [True, False]}';
		evaluateExpression('boolean (1..1)', '''«e1»->f1 only exists''')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e1»->f2 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e1»->f3 only exists''')[false.assertEquals(it)];
		
		evaluateExpression('boolean (1..1)', '''«e2»->f1 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e3»->f1 only exists''')[false.assertEquals(it)];
		
		evaluateExpression('boolean (1..1)', '''«e4»->f2 only exists''')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e4»->f3 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e5»->f2 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e5»->f3 only exists''')[true.assertEquals(it)];
		
		evaluateExpression('boolean (1..1)', '''«e6»->f1 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e6»->f2 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''«e6»->f3 only exists''')[false.assertEquals(it)];
	
		val f1 = 'F {f1: True, f2: empty, f3: empty, f4: empty}';
		val f2 = 'F {f1: True, f2: empty, f3: empty, f4: True}';
		val g1 = 'G {f1: True, f2: empty, f3: empty, f4: True}';
		evaluateExpression('boolean (1..1)', '''(if True then «f1» else «e1»)->f1 only exists''')[true.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''(if True then «f2» else «e1»)->f1 only exists''')[false.assertEquals(it)];
		evaluateExpression('boolean (1..1)', '''(if True then «g1» else «e1»)->f1 only exists''')[false.assertEquals(it)];
	}
	
	private def <T> evaluateExpression(CharSequence outputType, CharSequence expression, IAcceptor<T> accept) {
		val source = '''
		namespace mydummypackage
		
		type A:
			n int (1..2)
		type B:
			a A (1..1)
		type C extends A:
		type D:
			n int (1..1)
		type E:
		    f1 boolean (0..1)
		    f2 boolean (0..*)
		    f3 boolean (0..2)
		type F extends E:
			f4 boolean (0..1)
		type G extends E:
			f4 boolean (1..1)
		
		func Test:
		  inputs:
		  output: result «outputType»
		  assign-output: «expression»
		'''
		val model = source.parse;
		val pexpr = (model.elements.last as Function).operation;
		pexpr.assertWellTyped;
		model.assertNoErrors;
		source.compile[
			getCompiledClass('mydummypackage.functions.Test') => [c |
				c.declaredConstructor.newInstance => [
					accept.accept(c.getDeclaredMethod(evaluationName).invoke(it) as T)
				]
			]
		]
	}
	private def assertListType(Type t, Type listType) {
		val tp = t as ParameterizedType;
		List.assertEquals(tp.rawType)
		val classType = tp.actualTypeArguments.get(0) as WildcardType
		val genericClass = classType.upperBounds.get(0)
		listType.assertEquals(genericClass)
	}
	private def assertListEquals(List<?> expected, Object actual) {
		expected.assertIterableEquals(actual as Iterable<?>)
	}
}