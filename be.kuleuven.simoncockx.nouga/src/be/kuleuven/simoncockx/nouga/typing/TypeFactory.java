package be.kuleuven.simoncockx.nouga.typing;

import be.kuleuven.simoncockx.nouga.nouga.ListType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInType;
import be.kuleuven.simoncockx.nouga.nouga.BuiltInTypeEnum;
import be.kuleuven.simoncockx.nouga.nouga.CardinalityConstraint;
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
	
	public ListType createListType(Type itemType, CardinalityConstraint c) {
		ListType type = NougaFactory.eINSTANCE.createListType();
		type.setItemType(itemType);
		type.setConstraint(c);
		return type;
	}

	public CardinalityConstraint createConstraint(int inf, int sup) {
		CardinalityConstraint card = NougaFactory.eINSTANCE.createCardinalityConstraint();
		card.setInf(inf);
		card.setSup(sup);
		return card;
	}
	public CardinalityConstraint createUnboundedConstraint(int inf) {
		CardinalityConstraint card = NougaFactory.eINSTANCE.createCardinalityConstraint();
		card.setInf(inf);
		card.setUnbounded(true);
		return card;
	}
	
	// Convenience functions
	public ListType createListType(BuiltInTypeEnum builtInType, int inf, int sup) {
		return createListType(createBuiltInType(builtInType), createConstraint(inf, sup));
	}
	public ListType createListType(Data data, int inf, int sup) {
		return createListType(createDataType(data), createConstraint(inf, sup));
	}
	public ListType createListType(Type itemType, int inf, int sup) {
		return createListType(itemType, createConstraint(inf, sup));
	}
	public ListType createListType(BuiltInTypeEnum builtInType, int inf) {
		return createListType(createBuiltInType(builtInType), createUnboundedConstraint(inf));
	}
	public ListType createListType(Data data, int inf) {
		return createListType(createDataType(data), createUnboundedConstraint(inf));
	}
	public ListType createListType(Type itemType, int inf) {
		return createListType(itemType, createUnboundedConstraint(inf));
	}
	
	public CardinalityConstraint getSingle() {
		return createConstraint(1, 1);
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
	public ListType getSingleBoolean() {
		return createListType(getBoolean(), getSingle());
	}
	public ListType getSingleNumber() {
		return createListType(getNumber(), getSingle());
	}
	public ListType getSingleInt() {
		return createListType(getInt(), getSingle());
	}
	public ListType getEmptyNothing() {
		return createListType(getNothing(), 0, 0);
	}
}
