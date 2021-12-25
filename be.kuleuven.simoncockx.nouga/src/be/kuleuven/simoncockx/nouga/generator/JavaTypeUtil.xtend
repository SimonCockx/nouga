package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.ListType
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType
import be.kuleuven.simoncockx.nouga.nouga.DataType
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum
import be.kuleuven.simoncockx.nouga.lib.NougaNumber

class JavaTypeUtil {
	@Inject
	extension JavaNameUtil
	
	def boolean isListType(ListType t) {
		t.constraint.unbounded || t.constraint.sup != 1
	}
	def boolean isPrimitiveType(ListType t) {
		if (t.isListType || t.constraint.inf == 0) {
			return false;
		}
		val b = t.itemType;
		if (b instanceof BuiltInType) {
			if (b.type == BuiltInTypeEnum.BOOLEAN || b.type == BuiltInTypeEnum.INT) {
				return true;
			}
		}
		return false;
	}
	def toJavaType(ListType t) {
		if (t.isListType) {
			return '''List<? extends «t.itemType.toReferenceJavaType»>'''
		} else if (t.isPrimitiveType) {
			return (t.itemType as BuiltInType).toPrimitiveJavaType
		}
		return t.itemType.toReferenceJavaType
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
