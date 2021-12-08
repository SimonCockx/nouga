package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.Type
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType
import be.kuleuven.simoncockx.nouga.nouga.DataType
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum
import be.kuleuven.simoncockx.nouga.lib.NougaNumber

class JavaTypeUtil {
	@Inject
	extension JavaNameUtil
	
	def boolean isListType(Type t) {
		t.cardinality.unbounded || t.cardinality.sup != 1
	}
	def boolean isPrimitiveType(Type t) {
		if (t.isListType || t.cardinality.inf == 0) {
			return false;
		}
		val b = t.basicType;
		if (b instanceof BuiltInType) {
			if (b.type == BuiltInTypeEnum.BOOLEAN || b.type == BuiltInTypeEnum.INT) {
				return true;
			}
		}
		return false;
	}
	def toJavaType(Type t) {
		if (t.isListType) {
			return '''List<? extends «t.basicType.toReferenceJavaType»>'''
		} else if (t.isPrimitiveType) {
			return (t.basicType as BuiltInType).toPrimitiveJavaType
		}
		return t.basicType.toReferenceJavaType
	}
	
	def dispatch toReferenceJavaType(BuiltInType t) {
		switch (t.type) {
			case BOOLEAN:
				Boolean.simpleName
			case NUMBER:
				NougaNumber.simpleName
			case INT:
				Integer.simpleName
			case NOTHING:
				Void.simpleName
		}
	}
	def dispatch toReferenceJavaType(DataType t) {
		t.data.toClassName
	}
	def toPrimitiveJavaType(BuiltInType t) {
		switch (t.type) {
			case BOOLEAN:
				boolean.simpleName
			case INT:
				int.simpleName
			default:
				throw new IllegalArgumentException('''Type «t.type» does not have a corresponding primitive type.''')
		}
	}
}
