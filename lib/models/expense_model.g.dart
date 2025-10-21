// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 0;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      expenseDesc: fields[0] as String,
      expenseType: fields[1] as String,
      expenseAmount: fields[2] as int,
      expenseDate: fields[3] as String,
      expensePaymentMethod: fields[4] as String,
      expenseTime: fields[5] as String,
      expenseCategory: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.expenseDesc)
      ..writeByte(1)
      ..write(obj.expenseType)
      ..writeByte(2)
      ..write(obj.expenseAmount)
      ..writeByte(3)
      ..write(obj.expenseDate)
      ..writeByte(4)
      ..write(obj.expensePaymentMethod)
      ..writeByte(5)
      ..write(obj.expenseTime)
      ..writeByte(6)
      ..write(obj.expenseCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
