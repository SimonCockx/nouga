package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.RootElement
import be.kuleuven.simoncockx.nouga.nouga.Data
import static extension javax.lang.model.SourceVersion.*
import be.kuleuven.simoncockx.nouga.lib.Nouga
import be.kuleuven.simoncockx.nouga.nouga.Function
import java.math.BigDecimal
import be.kuleuven.simoncockx.nouga.nouga.Attribute
import be.kuleuven.simoncockx.nouga.nouga.Named

class JavaNameUtil {
	public final String basePackage = "mydummypackage"
	public final String functionsPackage = '''«basePackage».functions'''
	public final String imports = '''
	import «Nouga.canonicalName»;
	import «BigDecimal.canonicalName»;
	'''
	public final String evaluationName = "evaluate"
	
	def packageToPath(String ^package) {
		^package.replace(".", "/")
	}
	
	def dispatch toQualifiedName(Data elem) {
		'''«basePackage».«toClassName(elem)»'''
	}
	def dispatch toQualifiedName(Function elem) {
		'''«functionsPackage».«toClassName(elem)»'''
	}
	
	def toPath(RootElement elem) {
		elem.toQualifiedName.toString.packageToPath + '.java'
	}
	
	def toClassName(Named elem) {
		if (elem.name.isName) {
			return elem.name
		}
		// Escape names that correspond to keywords
		return elem.name + '_'
	}
	def toVarName(Named attr) {
		val n = attr.name.uncapitalize;
		if (n.isName) {
			return n
		}
		// Escape names that correspond to keywords
		return n + '_'
	}
	def toGetterName(Attribute attr) {
		'''get«attr.name.capitalize»'''
	}
	def toEvaluationName(Function func) {
		'''«func.toVarName».«evaluationName»'''
	}
	
	private def String capitalize(String str) {
		str.substring(0, 1).toUpperCase() + str.substring(1);
	}
	private def String uncapitalize(String str) {
		str.substring(0, 1).toLowerCase() + str.substring(1);
	}
}
