package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.Expression
import be.kuleuven.simoncockx.nouga.typing.NougaTyping
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.ListType
import be.kuleuven.simoncockx.nouga.typing.TypeUtil
import be.kuleuven.simoncockx.nouga.nouga.ConditionalExpression
import be.kuleuven.simoncockx.nouga.nouga.BooleanLiteral
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum
import be.kuleuven.simoncockx.nouga.typing.TypeFactory
import be.kuleuven.simoncockx.nouga.nouga.NumberLiteral
import be.kuleuven.simoncockx.nouga.nouga.IntLiteral
import be.kuleuven.simoncockx.nouga.nouga.ListLiteral
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
import be.kuleuven.simoncockx.nouga.nouga.InstantiationExpression
import be.kuleuven.simoncockx.nouga.nouga.OnlyElementExpression
import be.kuleuven.simoncockx.nouga.nouga.VariableReference
import be.kuleuven.simoncockx.nouga.nouga.AbsentExpression
import be.kuleuven.simoncockx.nouga.lib.NougaNumber

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
	@Inject
	extension JavaTypeUtil
	
	/**
	 * Guarantee: given that t is a supertype of the type of expression e,
	 * the type of toJavaExpression(e, t) equals t.toJavaType()
	 */
	def CharSequence toJavaExpression(Expression e, ListType expectedType) {
		val actualType = e.staticType;
		var result = e.toUnsafeJavaExpression(actualType);
		val safeResult = result.addCoercions(actualType, expectedType);
		return safeResult;
	}
	private def CharSequence addCoercions(CharSequence expr, ListType actual, ListType expected) {
		var result = expr;
		if (actual.itemType instanceof BuiltInType) {
			if ((actual.itemType as BuiltInType).type == BuiltInTypeEnum.INT) {
				val exp = (expected.itemType as BuiltInType).type;
				if (exp == BuiltInTypeEnum.NUMBER) {
					result = '''«lib.coerceIntToNumber»(«result»)''';
				}
			} else if ((actual.itemType as BuiltInType).type == BuiltInTypeEnum.NOTHING) {
				if (!expected.itemType.typesAreEqual(actual.itemType)) {
					if (expected.isListType) {
						result = '''«lib.empty»()''';
					} else {
						result = '''null'''
					}
					return result;
				}
			}
		}
		if (!actual.isListType && expected.isListType) {
			result = '''«lib.coerceToList»(«result»)''';
		}
		return result;
	}
	
	/**
	 * Guarantee: given that expression e has type t,
	 * the type of toUnsafeJavaExpression(e, t) equals t.toJavaType()
	 */
	def dispatch CharSequence toUnsafeJavaExpression(BooleanLiteral e, ListType type) {
		e.value.toString
	}
	def dispatch CharSequence toUnsafeJavaExpression(NumberLiteral e, ListType type) {
		'''new «NougaNumber.simpleName»("«e.value»")'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(IntLiteral e, ListType type) {
		e.value
	}
	def dispatch CharSequence toUnsafeJavaExpression(VariableReference e, ListType type) {
		e.reference.toVarName
	}
	
	def dispatch CharSequence toUnsafeJavaExpression(ListLiteral e, ListType type) {
		if (type.isListType) {
			val isListOfSingleValues = e.elements.forall[!it.staticType.isListType];
			if (isListOfSingleValues) {
				'''«lib.list»(«e.elements.join(', ')[toJavaExpression(createListType(type.itemType.clone, 1, 1))]»)'''
			} else {
				'''«lib.list»(«e.elements.join(', ')[toJavaExpression(createListType(type.itemType.clone, 0))]»)'''
			}
		} else {
			val singleElement = e.elements.findFirst[!it.staticType.isListType];
			singleElement.toJavaExpression(type)
		}
	}
	def dispatch CharSequence toUnsafeJavaExpression(OrExpression e, ListType type) {
		toBinaryJavaExpression(lib.or, e.left, e.right, singleBoolean)
	}
	def dispatch CharSequence toUnsafeJavaExpression(AndExpression e, ListType type) {
		toBinaryJavaExpression(lib.and, e.left, e.right, singleBoolean)
	}
	def dispatch CharSequence toUnsafeJavaExpression(NotExpression e, ListType type) {
		'''«lib.not»(«e.expression.toJavaExpression(singleBoolean)»)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(ExistsExpression e, ListType type) {
		val arg = e.argument.toUnsafeJavaExpression(e.argument.staticType);
		if (e.single) {
			'''«lib.singleExists»(«arg»)'''
		} else if (e.multiple) {
			'''«lib.multipleExists»(«arg»)'''
		} else {
			'''«lib.exists»(«arg»)'''
		}
	}
	def dispatch CharSequence toUnsafeJavaExpression(AbsentExpression e, ListType type) {
		val arg = e.argument.toUnsafeJavaExpression(e.argument.staticType)
		'''«lib.isAbsent»(«arg»)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(ContainsExpression e, ListType type) {
		toComparableBinaryJavaExpression(lib.contains, e.left, e.right)
	}
	def dispatch CharSequence toUnsafeJavaExpression(DisjointExpression e, ListType type) {
		toComparableBinaryJavaExpression(lib.disjoint, e.left, e.right)
	}
	def dispatch CharSequence toUnsafeJavaExpression(ComparisonOperation e, ListType type) {
		if (e.cardOp == 'all') {
			toSingleComparableBinaryJavaExpression(
				e.operator == '=' ? lib.allEquals : lib.allNotEquals,
				e.left, e.right
			)
		} else if (e.cardOp == 'any') {
			toSingleComparableBinaryJavaExpression(
				e.operator == '=' ? lib.anyEquals : lib.anyNotEquals,
				e.left, e.right
			)
		} else {
			toComparableBinaryJavaExpression(
				e.operator == '=' ? lib.equals : lib.notEquals,
				e.left, e.right
			)
		}
	}
	def dispatch CharSequence toUnsafeJavaExpression(ArithmeticOperation e, ListType type) {
		toBinaryJavaExpression(
			if ((type.itemType as BuiltInType).type == BuiltInTypeEnum.NUMBER) {
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
	def dispatch CharSequence toUnsafeJavaExpression(CountExpression e, ListType type) {
		val arg = e.argument.toUnsafeJavaExpression(e.argument.staticType);
		'''«lib.count»(«arg»)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(ProjectionExpression e, ListType type) {
		val t = e.receiver.staticType;
		if (e.onlyExists) {
			'''«lib.onlyExists»(«e.receiver.toUnsafeJavaExpression(t)», "«e.attribute.name»")'''
		} else {
			val basic = t.itemType as DataType;
			val className = basic.data.toClassName;
			val getter = e.attribute.toGetterName;
			if (t.isListType) {
				if (e.attribute.listType.isListType) {
					'''«lib.flatProject»(«e.receiver.toUnsafeJavaExpression(t)», «className»::«getter»)'''
				} else {
					'''«lib.project»(«e.receiver.toUnsafeJavaExpression(t)», «className»::«getter»)'''
				}
			} else {
				'''«e.receiver.toUnsafeJavaExpression(t)».«getter»()'''
			}
		}
	}
	def dispatch CharSequence toUnsafeJavaExpression(ConditionalExpression e, ListType type) {
		'''«lib.ifThenElse»(«toJavaExpression(e.^if, singleBoolean)», «toJavaExpression(e.ifthen, type)», «toJavaExpression(e.elsethen, type)»)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(FunctionCallExpression e, ListType type) {
		'''«e.function.toEvaluationName»(«(0..<e.args.size).join(', ')[idx | toJavaExpression(e.args.get(idx), e.function.inputs.get(idx).listType)]»)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(InstantiationExpression e, ListType type) {
		'''new «e.type.toClassName»(«e.type.allAttributes.join(', ')[attr | toJavaExpression(e.values.findFirst[key == attr].value, attr.listType)]»)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(OnlyElementExpression e, ListType type) {
		val argType = e.argument.staticType;
		val arg = e.argument.toJavaExpression(createListType(argType.itemType.clone, 0));
		'''«lib.onlyElement»(«arg»)'''
	}
	
	private def CharSequence toBinaryJavaExpression(CharSequence func, Expression left, Expression right, ListType expectedType) {
		'''«func»(«left.toJavaExpression(expectedType)», «right.toJavaExpression(expectedType)»)'''
	}
	private def CharSequence toComparableBinaryJavaExpression(CharSequence func, Expression left, Expression right) {
		val leftBasicType = left.staticType.itemType;
		val rightBasicType = right.staticType.itemType;
		val basicSuperType = join(leftBasicType, rightBasicType);
		'''«func»(«toJavaExpression(left, createListType(basicSuperType, 0))», «toJavaExpression(right, createListType(basicSuperType.clone, 0))»)'''
	}
	private def CharSequence toSingleComparableBinaryJavaExpression(CharSequence func, Expression left, Expression right) {
		val leftBasicType = left.staticType.itemType;
		val rightBasicType = right.staticType.itemType;
		val basicSuperType = join(leftBasicType, rightBasicType);
		'''«func»(«toJavaExpression(left, createListType(basicSuperType, 0))», «toJavaExpression(right, createListType(basicSuperType.clone, 1, 1))»)'''
	}
}
