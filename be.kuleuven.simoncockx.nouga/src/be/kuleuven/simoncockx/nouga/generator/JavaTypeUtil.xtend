package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.Type
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType
import be.kuleuven.simoncockx.nouga.nouga.DataType
import java.math.BigDecimal
import com.google.inject.Inject

class JavaTypeUtil {
	@Inject
	extension JavaNameUtil
	
	def toJavaType(Type t) {
		'''List<? extends «t.basicType.toBasicJavaType»>'''
	}
	
	def dispatch toBasicJavaType(BuiltInType t) {
		switch (t.type) {
			case BOOLEAN:
				Boolean.simpleName
			case NUMBER:
				BigDecimal.simpleName
			case INT:
				Integer.simpleName
			case NOTHING:
				Void.simpleName
		}
	}
	def dispatch toBasicJavaType(DataType t) {
		t.data.toClassName
	}
}
