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
import org.eclipse.xtext.EcoreUtil2
import be.kuleuven.simoncockx.nouga.nouga.Function

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
		var result = e.toUnsafeJavaExpression;
		val safeResult = result.addCoercions(actualType, expectedType);
		return safeResult;
	}
	private def CharSequence addCoercions(CharSequence expr, ListType actual, ListType expected) {
		var result = expr;
		if (actual.itemType instanceof BuiltInType) {
			if ((actual.itemType as BuiltInType).type == BuiltInTypeEnum.INT) {
				val exp = (expected.itemType as BuiltInType).type;
				if (exp == BuiltInTypeEnum.NUMBER) {
					result = '''??lib.coerceIntToNumber??(??result??)''';
				}
			} else if ((actual.itemType as BuiltInType).type == BuiltInTypeEnum.NOTHING) {
				if (!expected.itemType.typesAreEqual(actual.itemType)) {
					if (expected.isListType) {
						result = '''??lib.empty??()''';
					} else {
						result = '''null'''
					}
					return result;
				}
			}
		}
		if (!actual.isListType && expected.isListType) {
			result = '''??lib.coerceItemToList??(??result??)''';
		}
		return result;
	}
	
	/**
	 * Guarantee: given that expression e has type t,
	 * the type of toUnsafeJavaExpression(e) equals t.toJavaType()
	 */
	def dispatch CharSequence toUnsafeJavaExpression(BooleanLiteral e) {
		e.value.toString
	}
	def dispatch CharSequence toUnsafeJavaExpression(NumberLiteral e) {
		'''new ??NougaNumber.simpleName??("??e.value??")'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(IntLiteral e) {
		e.value
	}
	def dispatch CharSequence toUnsafeJavaExpression(VariableReference e) {
		e.reference.toVarName
	}

	def dispatch CharSequence toUnsafeJavaExpression(OrExpression e) {
		toBinaryJavaExpression(lib.or, e.left, e.right, singleBoolean)
	}
	def dispatch CharSequence toUnsafeJavaExpression(AndExpression e) {
		toBinaryJavaExpression(lib.and, e.left, e.right, singleBoolean)
	}
	def dispatch CharSequence toUnsafeJavaExpression(NotExpression e) {
		'''??lib.not??(??e.expression.toJavaExpression(singleBoolean)??)'''
	}
	
	def dispatch CharSequence toUnsafeJavaExpression(ArithmeticOperation e) {
		toBinaryJavaExpression(
			switch (e.operator) {
				case '+': lib.add
				case '-': lib.subtract
				case '*': lib.multiply
				case '/': lib.divide
			}, e.left, e.right, e.staticType)
	}
	
	def dispatch CharSequence toUnsafeJavaExpression(InstantiationExpression e) {
		'''new ??e.type.toClassName??(??e.type.allAttributes.join(', ')[attr | toJavaExpression(e.values.findFirst[key == attr].value, attr.listType)]??)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(ProjectionExpression e) {
		if (e.onlyExists) {
			'''??lib.onlyExists??(??e.receiver.toUnsafeJavaExpression??, "??e.attribute.name??")'''
		} else {
			val t = e.receiver.staticType;
			val basic = t.itemType as DataType;
			val className = basic.data.toClassName;
			val getter = e.attribute.toGetterName;
			if (t.isListType) {
				val expected = createListType(t.itemType.clone, 0);
				if (e.attribute.listType.isListType) {
					'''??lib.flatProject??(??e.receiver.toJavaExpression(expected)??, ??className??::??getter??)'''
				} else {
					'''??lib.project??(??e.receiver.toJavaExpression(expected)??, ??className??::??getter??)'''
				}
			} else {
				val ^default = if (e.attribute.listType.isListType) {
					'''??lib.empty??()'''
				} else {
					'''null'''
				}
				'''??lib.applyOrDefault??(??e.receiver.toUnsafeJavaExpression??, ??className??::??getter??, ??^default??)'''
			}
		}
	}
	
	def dispatch CharSequence toUnsafeJavaExpression(ExistsExpression e) {
		val arg = e.argument.toUnsafeJavaExpression
		if (e.single) {
			'''??lib.singleExists??(??arg??)'''
		} else if (e.multiple) {
			'''??lib.multipleExists??(??arg??)'''
		} else {
			'''??lib.exists??(??arg??)'''
		}
	}
	def dispatch CharSequence toUnsafeJavaExpression(AbsentExpression e) {
		val arg = e.argument.toUnsafeJavaExpression
		'''??lib.isAbsent??(??arg??)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(CountExpression e) {
		val arg = e.argument.toUnsafeJavaExpression
		'''??lib.count??(??arg??)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(OnlyElementExpression e) {
		val argType = e.argument.staticType;
		val arg = e.argument.toJavaExpression(createListType(argType.itemType.clone, 0));
		'''??lib.onlyElement??(??arg??)'''
	}
	
	def dispatch CharSequence toUnsafeJavaExpression(ComparisonOperation e) {
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
	def dispatch CharSequence toUnsafeJavaExpression(ContainsExpression e) {
		toComparableBinaryJavaExpression(lib.contains, e.left, e.right)
	}
	def dispatch CharSequence toUnsafeJavaExpression(DisjointExpression e) {
		toComparableBinaryJavaExpression(lib.disjoint, e.left, e.right)
	}
		
	def dispatch CharSequence toUnsafeJavaExpression(ListLiteral e) {
		if (e.staticType.isListType) {
			val isListOfSingleValues = e.elements.forall[!it.staticType.isListType];
			if (isListOfSingleValues) {
				'''??lib.list??(??e.elements.join(', ')[toJavaExpression(createListType(e.staticType.itemType.clone, 1, 1))]??)'''
			} else {
				'''??lib.list??(??e.elements.join(', ')[toJavaExpression(createListType(e.staticType.itemType.clone, 0))]??)'''
			}
		} else if (e.staticType.constraint.sup == 0) {
			return '''(Void)null'''; // empty list
		} else {
			val singleElement = e.elements.findFirst[it.staticType.constraint.sup == 1];
			singleElement.toJavaExpression(e.staticType)
		}
	}
	def dispatch CharSequence toUnsafeJavaExpression(ConditionalExpression e) {
		'''??lib.libName??.<??e.staticType.toReferenceJavaType??>ifThenElse(??toJavaExpression(e.^if, singleBoolean)??, () -> ??toJavaExpression(e.ifthen, e.staticType)??, () -> ??toJavaExpression(e.elsethen, e.staticType)??)'''
	}
	def dispatch CharSequence toUnsafeJavaExpression(FunctionCallExpression e) {
		val context = EcoreUtil2.getContainerOfType(e, Function)
		'''??e.function.toEvaluationName(context)??(??(0..<e.args.size).join(', ')[idx | toJavaExpression(e.args.get(idx), e.function.inputs.get(idx).listType)]??)'''
	}
	
	
	private def CharSequence toBinaryJavaExpression(CharSequence func, Expression left, Expression right, ListType expectedType) {
		'''??func??(??left.toJavaExpression(expectedType)??, ??right.toJavaExpression(expectedType)??)'''
	}
	private def CharSequence toComparableBinaryJavaExpression(CharSequence func, Expression left, Expression right) {
		val leftBasicType = left.staticType.itemType;
		val rightBasicType = right.staticType.itemType;
		val basicSuperType = join(leftBasicType, rightBasicType);
		'''??func??(??toJavaExpression(left, createListType(basicSuperType, 0))??, ??toJavaExpression(right, createListType(basicSuperType.clone, 0))??)'''
	}
	private def CharSequence toSingleComparableBinaryJavaExpression(CharSequence func, Expression left, Expression right) {
		val leftBasicType = left.staticType.itemType;
		val rightBasicType = right.staticType.itemType;
		val basicSuperType = join(leftBasicType, rightBasicType);
		'''??func??(??toJavaExpression(left, createListType(basicSuperType, 0))??, ??toJavaExpression(right, createListType(basicSuperType.clone, 1, 1))??)'''
	}
}
