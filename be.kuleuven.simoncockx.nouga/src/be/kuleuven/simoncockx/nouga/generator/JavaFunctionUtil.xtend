package be.kuleuven.simoncockx.nouga.generator

import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Function
import be.kuleuven.simoncockx.nouga.nouga.FunctionCallExpression
import be.kuleuven.simoncockx.nouga.nouga.DataConstructionExpression

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
			'''@Inject «toClassName» «toVarName»;'''
			]»
			
			public «func.output.type.toJavaType» «evaluationName»(«func.inputs.join(', ')['''«type.toJavaType» «toVarName»''']») {
				return «func.operation.toJavaExpression(func.output.type)»;
			}
			
			private static final class «func.toClassName»Default extends «func.toClassName» { }
		}
		'''
	}
	
	private def gatherFunctionDependencies(Function func) {
		func.eAllContents.filter(FunctionCallExpression).map[function].toSet
	}
	private def gatherEntityDependencies(Function func) {
		func.eAllContents.filter(DataConstructionExpression).map[type].toSet
	}
}