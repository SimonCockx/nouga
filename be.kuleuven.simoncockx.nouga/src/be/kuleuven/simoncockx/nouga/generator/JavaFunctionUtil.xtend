package be.kuleuven.simoncockx.nouga.generator

import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.FunctionCallExpression
import be.kuleuven.simoncockx.nouga.nouga.InstantiationExpression
import be.kuleuven.simoncockx.nouga.nouga.DataType

class JavaFunctionUtil {
	@Inject
	extension JavaNameUtil
	@Inject
	extension JavaTypeUtil
	@Inject
	extension JavaExpressionUtil
	
	def CharSequence toJavaFunction(Function func) {
		'''
		«func.gatherEntityDependencies.join(System.lineSeparator)[
			'''import «toQualifiedName»;'''
		]»
		
		@ImplementedBy(«func.toClassName».«func.toClassName»Default.class)
		public class «func.toClassName» {
			«func.gatherFunctionDependencies.join(System.lineSeparator)[
			'''@Inject protected «toClassName» «toDependencyFieldName(func)»;'''
			]»
			
			public «func.output.listType.toJavaType» «evaluationName»(«func.inputs.join(', ')['''«listType.toJavaType» «toVarName»''']») {
				return «func.operation.toJavaExpression(func.output.listType)»;
			}
			
			static final class «func.toClassName»Default extends «func.toClassName» { }
		}
		'''
	}
	
	private def gatherFunctionDependencies(Function func) {
		func.eAllContents.filter(FunctionCallExpression).map[function].toSet
	}
	private def gatherEntityDependencies(Function func) {
		val outputDep = if (func.output.listType.itemType instanceof DataType) {
			#{(func.output.listType.itemType as DataType).data}
		} else #{};
		func.eAllContents.filter(InstantiationExpression).map[type].toSet
		+ func.inputs.map[listType.itemType].filter(DataType).map[data].toSet
		+ outputDep
	}
}