package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.Expression
import be.kuleuven.simoncockx.nouga.typing.NougaTyping
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Type
import be.kuleuven.simoncockx.nouga.typing.TypeUtil
import be.kuleuven.simoncockx.nouga.nouga.ConditionalExpression
import be.kuleuven.simoncockx.nouga.nouga.BooleanLiteral
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum
import be.kuleuven.simoncockx.nouga.typing.TypeFactory
import be.kuleuven.simoncockx.nouga.nouga.NumberLiteral
import be.kuleuven.simoncockx.nouga.nouga.IntLiteral
import be.kuleuven.simoncockx.nouga.nouga.ListLiteral
import be.kuleuven.simoncockx.nouga.nouga.BasicType
import be.kuleuven.simoncockx.nouga.nouga.OrExpression
import be.kuleuven.simoncockx.nouga.nouga.AndExpression
import be.kuleuven.simoncockx.nouga.nouga.NotExpression
import be.kuleuven.simoncockx.nouga.nouga.ExistsExpression
import be.kuleuven.simoncockx.nouga.nouga.ContainsExpression
import be.kuleuven.simoncockx.nouga.nouga.DisjointExpression
import be.kuleuven.simoncockx.nouga.nouga.ComparisonOperation
import be.kuleuven.simoncockx.nouga.nouga.ArithmeticOperation
import be.kuleuven.simoncockx.nouga.nouga.CountExpression
import be.kuleuven.simoncockx.nouga.nouga.ProjectionExpression
import be.kuleuven.simoncockx.nouga.nouga.DataType
import be.kuleuven.simoncockx.nouga.nouga.FunctionCallExpression
import be.kuleuven.simoncockx.nouga.nouga.DataConstructionExpression
import be.kuleuven.simoncockx.nouga.nouga.OnlyElementExpression

class JavaExpressionUtil {
	@Inject
	extension NougaTyping
	@Inject
	extension TypeUtil
	@Inject
	extension TypeFactory
	@Inject
	JavaLibUtil lib
	@Inject
	extension JavaNameUtil
	
	def CharSequence toJavaExpression(Expression e) {
		toJavaExpression(e, e.type.value)
	}
	def CharSequence toJavaExpression(Expression e, Type expectedType) {
		toJavaExpression(e, expectedType.basicType)
	}
	private def CharSequence toJavaExpression(Expression e, BasicType expectedBasicType) {
		val actualType = e.type.value;
		val unsafeResult = e.toUnsafeJavaExpression(actualType);
		val coercion = findCoercion(actualType.basicType, expectedBasicType);
		if (coercion === null) {
			unsafeResult
		} else {
			'''«coercion»(«unsafeResult»)'''
		}
	}
	private def CharSequence findCoercion(BasicType actual, BasicType expected) {
		if (actual instanceof BuiltInType) {
			if (actual.type == BuiltInTypeEnum.INT) {
				val exp = (expected as BuiltInType).type;
				if (exp == BuiltInTypeEnum.NUMBER) {
					return lib.coerceIntToNumber
				}
			} else if (actual.type == BuiltInTypeEnum.NOTHING) {
				if (!expected.basicTypesAreEqual(actual)) {
					return lib.coerceNothingToAnything
				}
			}
		}
		return null;
	}
	
	def dispatch toUnsafeJavaExpression(BooleanLiteral e, Type type) {
		'''«lib.single»(«e.value»)'''
	}
	def dispatch toUnsafeJavaExpression(NumberLiteral e, Type type) {
		'''«lib.single»(BigDecimal.valueOf("«e.value»"))'''
	}
	def dispatch toUnsafeJavaExpression(IntLiteral e, Type type) {
		'''«lib.single»(«e.value»)'''
	}
	
	def dispatch toUnsafeJavaExpression(ListLiteral e, Type type) {
		'''«lib.list»(«e.elements.join(', ')[toJavaExpression(type.basicType)]»)'''
	}
	def dispatch toUnsafeJavaExpression(OrExpression e, Type type) {
		toBinaryJavaExpression(lib.or, e.left, e.right, singleBoolean)
	}
	def dispatch toUnsafeJavaExpression(AndExpression e, Type type) {
		toBinaryJavaExpression(lib.and, e.left, e.right, singleBoolean)
	}
	def dispatch toUnsafeJavaExpression(NotExpression e, Type type) {
		'''«lib.not»(«e.expression.toJavaExpression(singleBoolean)»)'''
	}
	def dispatch toUnsafeJavaExpression(ExistsExpression e, Type type) {
		if (e.single) {
			'''«lib.singleExists»(«e.argument.toJavaExpression»)'''
		} else if (e.multiple) {
			'''«lib.multipleExists»(«e.argument.toJavaExpression»)'''
		} else {
			'''«lib.exists»(«e.argument.toJavaExpression»)'''
		}
	}
	def dispatch toUnsafeJavaExpression(ContainsExpression e, Type type) {
		toComparableBinaryJavaExpression(lib.contains, e.container, e.contained)
	}
	def dispatch toUnsafeJavaExpression(DisjointExpression e, Type type) {
		toComparableBinaryJavaExpression(lib.contains, e.container, e.disjoint)
	}
	def dispatch toUnsafeJavaExpression(ComparisonOperation e, Type type) {
		toComparableBinaryJavaExpression(
			if (e.operator == '=') {
				if (e.cardOp == 'all') {
					lib.allEquals
				} else if (e.cardOp == 'any') {
					lib.anyEquals
				} else {
					lib.equals
				}
			} else {
				if (e.cardOp == 'all') {
					lib.allNotEquals
				} else if (e.cardOp == 'any') {
					lib.anyNotEquals
				} else {
					lib.notEquals
				}
			}, e.left, e.right)
	}
	def dispatch toUnsafeJavaExpression(ArithmeticOperation e, Type type) {
		toBinaryJavaExpression(
			if ((type.basicType as BuiltInType).type == BuiltInTypeEnum.NUMBER) {
				switch (e.operator) {
					case '+': lib.addNumber
					case '-': lib.subtractNumber
					case '*': lib.multiplyNumber
					case '/': lib.divide
				}
			} else {
				switch (e.operator) {
					case '+': lib.addInt
					case '-': lib.subtractInt
					case '*': lib.multiplyInt
				}
			}, e.left, e.right, type)
	}
	def dispatch toUnsafeJavaExpression(CountExpression e, Type type) {
		'''«lib.count»(«e.argument.toJavaExpression»)'''
	}
	def dispatch toUnsafeJavaExpression(ProjectionExpression e, Type type) {
		val t = e.receiver.type.value as DataType;
		val className = t.data.toClassName;
		val getter = e.attribute.toGetterName;
		if (e.onlyExists) {
			'''«lib.onlyExists»(«e.receiver.toJavaExpression(t)», «className»::«getter», «t.data.attributes.filter[it != e.attribute].join(',')['''«className»::«toGetterName»''']»)'''
		} else {
			'''«lib.project»(«e.receiver.toJavaExpression(t)», «className»::«getter»)'''
		}
	}
	def dispatch toUnsafeJavaExpression(ConditionalExpression e, Type type) {
		'''«lib.ifThenElse»(«toJavaExpression(e.^if, singleBoolean)», «toJavaExpression(e.ifthen, type)», «toJavaExpression(e.elsethen, type)»)'''
	}
	def dispatch toUnsafeJavaExpression(FunctionCallExpression e, Type type) {
		'''«e.function.toEvaluationName»(«(0..<e.args.size).join(', ')[idx | toJavaExpression(e.args.get(idx), e.function.inputs.get(idx).type)]»)'''
	}
	def dispatch toUnsafeJavaExpression(DataConstructionExpression e, Type type) {
		'''«lib.single»(new «e.type.toClassName»(«e.type.attributes.join(', ')[attr | toJavaExpression(e.values.findFirst[key == attr].value, attr.type)]»))'''
	}
	def dispatch toUnsafeJavaExpression(OnlyElementExpression e, Type type) {
		'''«lib.onlyElement»(«e.argument.toJavaExpression»)'''
	}
	
	private def toBinaryJavaExpression(CharSequence func, Expression left, Expression right, Type expectedType) {
		'''«func»(«left.toJavaExpression(expectedType)», «right.toJavaExpression(expectedType)»)'''
	}
	private def toComparableBinaryJavaExpression(CharSequence func, Expression left, Expression right) {
		val leftBasicType = left.type.value.basicType;
		val rightBasicType = right.type.value.basicType;
		val basicSuperType = join(leftBasicType, rightBasicType);
		'''«func»(«toJavaExpression(left, basicSuperType)», «toJavaExpression(right, basicSuperType)»)'''
	}
}
