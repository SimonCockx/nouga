package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.Data
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Attribute
import be.kuleuven.simoncockx.nouga.typing.NougaTyping

class JavaEntityUtil {
	@Inject
	extension NougaTyping
	@Inject
	extension JavaNameUtil
	@Inject
	extension JavaTypeUtil
	
	def CharSequence toJavaClass(Data data) {
		'''
		public class «data.toClassName»«IF data.superType !== null» extends «data.superType.toClassName»«ENDIF» {
			«FOR attr: data.attributes»
			«attr.toJavaField»
			«ENDFOR»
		
			«data.toJavaConstructor»
		
			«FOR attr: data.attributes»
			«attr.toJavaGetter»
			«ENDFOR»
			
			@Override
			public boolean equals(Object obj) {
				if (obj == null) {
		            return false;
		        }
		
		        if (obj.getClass() != this.getClass()) {
		            return false;
		        }
		
		        final «data.toClassName» other = («data.toClassName»)obj;
		        «FOR attr: data.allAttributes»
		        «IF attr.type.isPrimitiveType»
		        if (this.«attr.toGetterName»() != other.«attr.toGetterName»()) {
		        	return false;
		        }
    			«ELSEIF attr.type.isListType»
		        if (!this.«attr.toGetterName»().equals(other.«attr.toGetterName»())) {
		        	return false;
		        }
		        «ELSE»
		        if (this.«attr.toGetterName»() == null ? other.«attr.toGetterName»() != null : !this.«attr.toGetterName»().equals(other.«attr.toGetterName»())) {
		        	return false;
		        }
    			«ENDIF»
    			«ENDFOR»
		
		        return true;
			}
			
			@Override
		    public int hashCode() {
		        int hash = 3;
		        «FOR attr: data.allAttributes»
		        «IF attr.type.isPrimitiveType»
		        hash = 53 * hash + «attr.type.basicType.toReferenceJavaType».hashCode(this.«attr.toGetterName»());
    			«ELSEIF attr.type.isListType»
		        hash = 53 * hash + this.«attr.toGetterName»().hashCode();
		        «ELSE»
		        hash = 53 * hash + (this.«attr.toGetterName»() == null ? 0 : this.«attr.toGetterName»().hashCode());
    			«ENDIF»
    			«ENDFOR»
		        return hash;
		    }
		}
		'''
	}
	
	def CharSequence toJavaField(Attribute attr) {
		'''private final «attr.type.toJavaType» «attr.toVarName»;'''
	}
	def CharSequence toJavaConstructor(Data data) {
		'''
		public «data.toClassName»(«data.allAttributes.join(', ')['''«type.toJavaType» «toVarName»''']») {
			«IF data.superType !== null»
			super(«data.superType.allAttributes.join(', ')[toVarName]»);
			«ENDIF»
			«data.attributes.join(System.lineSeparator)[
				'''this.«toVarName» = «type.isListType ? '''ImmutableList.copyOf(«toVarName»)''' : toVarName»;'''
			]»
		}
		'''
	}
	def CharSequence toJavaGetter(Attribute attr) {
		'''
		public «attr.type.toJavaType» «attr.toGetterName»() {
			return this.«attr.toVarName»;
		}
		'''
	}
}