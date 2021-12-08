package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.RootElement
import be.kuleuven.simoncockx.nouga.nouga.Data
import static extension javax.lang.model.SourceVersion.*
import be.kuleuven.simoncockx.nouga.lib.Nouga
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.Attribute
import be.kuleuven.simoncockx.nouga.nouga.Named
import com.google.common.collect.ImmutableList
import java.util.List
import com.google.inject.Inject
import com.google.inject.ImplementedBy
import be.kuleuven.simoncockx.nouga.nouga.Model
import be.kuleuven.simoncockx.nouga.lib.NougaNumber

class JavaNameUtil {
	public final String imports = '''
	import «Nouga.canonicalName»;
	import «NougaNumber.canonicalName»;
	import «ImmutableList.canonicalName»;
	import «List.canonicalName»;
	import «Inject.canonicalName»;
	import «ImplementedBy.canonicalName»;
	'''
	public final String evaluationName = "evaluate"
	public final String functionsSubpackage = "functions"
	
	def packageToPath(String ^package) {
		^package.replace(".", "/")
	}
	
	def toQualifiedName(RootElement elem) {
		'''«toPackage(elem)».«toClassName(elem)»'''
	}
	
	def dispatch toPackage(Data elem) {
		(elem.eContainer as Model).name
	}
	def dispatch toPackage(Function elem) {
		'''«(elem.eContainer as Model).name».«functionsSubpackage»'''
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
