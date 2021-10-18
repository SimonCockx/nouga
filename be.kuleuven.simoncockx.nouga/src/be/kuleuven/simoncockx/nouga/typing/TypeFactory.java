package be.kuleuven.simoncockx.nouga.typing;

import be.kuleuven.simoncockx.nouga.nouga.BasicType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum;
import be.kuleuven.simoncockx.nouga.nouga.Cardinality;
import be.kuleuven.simoncockx.nouga.nouga.NougaFactory;
import be.kuleuven.simoncockx.nouga.nouga.Type;

public class TypeFactory {
	public final Cardinality single;
	public final BuiltInType boolean_;
	public final BuiltInType number;
	public final BuiltInType int_;
	public final Type singleBoolean;
	public final Type singleNumber;
	public final Type singleInt;

	public TypeFactory() {
		this.single = createCardinality(1, 1);
		this.boolean_ = createBuiltInType(BuiltInTypeEnum.BOOLEAN);
		this.number = createBuiltInType(BuiltInTypeEnum.NUMBER);
		this.int_ = createBuiltInType(BuiltInTypeEnum.INT);
		this.singleBoolean = createType(boolean_, 1, 1);
		this.singleNumber = createType(number, 1, 1);
		this.singleInt = createType(int_, 1, 1);
	}
	
	public BuiltInType createBuiltInType(BuiltInTypeEnum builtInType) {
		BuiltInType t = NougaFactory.eINSTANCE.createBuiltInType();
		t.setType(builtInType);
		return t;
	}
	
	private Type createType(BasicType basicType, int inf, int sup) {
		Type type = NougaFactory.eINSTANCE.createType();
		type.setBasicType(basicType);
		type.setCardinality(createCardinality(inf, sup));
		return type;
	}

	private Cardinality createCardinality(int inf, int sup) {
		Cardinality card = NougaFactory.eINSTANCE.createCardinality();
		card.setInf(inf);
		card.setSup(sup);
		return card;
	}
}
