package be.kuleuven.simoncockx.nouga.typing;

import be.kuleuven.simoncockx.nouga.nouga.BasicType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum;
import be.kuleuven.simoncockx.nouga.nouga.Cardinality;
import be.kuleuven.simoncockx.nouga.nouga.Data;
import be.kuleuven.simoncockx.nouga.nouga.DataType;
import be.kuleuven.simoncockx.nouga.nouga.NougaFactory;
import be.kuleuven.simoncockx.nouga.nouga.Type;

public class TypeFactory {
	
	public BuiltInType createBuiltInType(BuiltInTypeEnum builtInType) {
		BuiltInType t = NougaFactory.eINSTANCE.createBuiltInType();
		t.setType(builtInType);
		return t;
	}
	
	public DataType createDataType(Data data) {
		DataType t = NougaFactory.eINSTANCE.createDataType();
		t.setData(data);
		return t;
	}
	
	public Type createType(BasicType basicType, Cardinality c) {
		Type type = NougaFactory.eINSTANCE.createType();
		type.setBasicType(basicType);
		type.setCardinality(c);
		return type;
	}

	public Cardinality createCardinality(int inf, int sup) {
		Cardinality card = NougaFactory.eINSTANCE.createCardinality();
		card.setInf(inf);
		card.setSup(sup);
		return card;
	}
	public Cardinality createUnboundedCardinality(int inf) {
		Cardinality card = NougaFactory.eINSTANCE.createCardinality();
		card.setInf(inf);
		card.setUnbounded(true);
		return card;
	}
	
	// Convenience functions
	public Type createType(BuiltInTypeEnum builtInType, int inf, int sup) {
		return createType(createBuiltInType(builtInType), createCardinality(inf, sup));
	}
	public Type createType(Data data, int inf, int sup) {
		return createType(createDataType(data), createCardinality(inf, sup));
	}
	public Type createType(BasicType basicType, int inf, int sup) {
		return createType(basicType, createCardinality(inf, sup));
	}
	public Type createType(BuiltInTypeEnum builtInType, int inf) {
		return createType(createBuiltInType(builtInType), createUnboundedCardinality(inf));
	}
	public Type createType(Data data, int inf) {
		return createType(createDataType(data), createUnboundedCardinality(inf));
	}
	
	public Cardinality getSingle() {
		return createCardinality(1, 1);
	}
	public BuiltInType getBoolean() {
		return createBuiltInType(BuiltInTypeEnum.BOOLEAN);
	}
	public BuiltInType getNumber() {
		return createBuiltInType(BuiltInTypeEnum.NUMBER);
	}
	public BuiltInType getInt() {
		return createBuiltInType(BuiltInTypeEnum.INT);
	}
	public BuiltInType getNothing() {
		return createBuiltInType(BuiltInTypeEnum.NOTHING);
	}
	public Type getSingleBoolean() {
		return createType(getBoolean(), getSingle());
	}
	public Type getSingleNumber() {
		return createType(getNumber(), getSingle());
	}
	public Type getSingleInt() {
		return createType(getInt(), getSingle());
	}
	public Type getEmptyNothing() {
		return createType(getNothing(), 0, 0);
	}
}
