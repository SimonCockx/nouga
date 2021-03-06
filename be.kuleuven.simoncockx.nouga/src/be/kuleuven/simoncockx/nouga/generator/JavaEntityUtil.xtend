package be.kuleuven.simoncockx.nouga.generator

import be.kuleuven.simoncockx.nouga.nouga.Data
import com.google.inject.Inject
import be.kuleuven.simoncockx.nouga.nouga.Attribute
import be.kuleuven.simoncockx.nouga.typing.NougaTyping
import java.util.Arrays

class JavaEntityUtil {
	@Inject
	extension NougaTyping
	@Inject
	extension JavaNameUtil
	@Inject
	extension JavaTypeUtil
	
	def CharSequence toJavaClass(Data data) {
		'''
		public class «data.toClassName» extends «IF data.parent === null»NougaEntity«ELSE»«data.parent.toClassName»«ENDIF» {
			«FOR attr: data.attributes»
			«attr.toJavaField»
			«ENDFOR»
		
			«data.toJavaConstructor»
		
			«FOR attr: data.attributes»
			«attr.toJavaGetter»
			«ENDFOR»
			
			@Override
			public List<String> getAttributeNames() {
				return «Arrays.simpleName».asList(«data.allAttributes.join(", ")['"' + name + '"']»);
			}

			@Override
			public Object getAttributeValue(String attr) {
				switch (attr) {
				«FOR attr: data.attributes»
					case "«attr.name»":
						return this.«attr.toGetterName»();
				«ENDFOR»
					default:
						return super.getAttributeValue(attr);
				}
			}
			
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
		        «IF attr.listType.isPrimitiveType»
		        if (this.«attr.toGetterName»() != other.«attr.toGetterName»()) {
		        	return false;
		        }
				«ELSEIF attr.listType.isListType»
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
		        int hash = «IF data.parent === null»3«ELSE»super.hashCode()«ENDIF»;
		        «FOR attr: data.attributes»
		        «IF attr.listType.isPrimitiveType»
		        hash = 53 * hash + «attr.listType.itemType.toItemReferenceJavaType».hashCode(this.«attr.toGetterName»());
				«ELSEIF attr.listType.isListType»
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
		'''private final «attr.listType.toJavaType» «attr.toVarName»;'''
	}
	def CharSequence toJavaConstructor(Data data) {
		'''
		public «data.toClassName»(«data.allAttributes.join(', ')['''«listType.toJavaType» «toVarName»''']») {
			«IF data.parent !== null»
			super(«data.parent.allAttributes.join(', ')[toVarName]»);
			«ENDIF»
			«data.attributes.join(System.lineSeparator)[
				'''this.«toVarName» = «listType.isListType ? '''ImmutableList.copyOf(«toVarName»)''' : toVarName»;'''
			]»
		}
		'''
	}
	def CharSequence toJavaGetter(Attribute attr) {
		'''
		public «attr.listType.toJavaType» «attr.toGetterName»() {
			return this.«attr.toVarName»;
		}
		'''
	}
}