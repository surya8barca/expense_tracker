import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String expenseDesc;
  @HiveField(1)
  String expenseType;
  @HiveField(2)
  int expenseAmount;
  @HiveField(3)
  String expenseDate;
  @HiveField(4)
  String expensePaymentMethod;
  @HiveField(5)
  String expenseTime;
  @HiveField(6)
  String expenseCategory;

  ExpenseModel({
    required this.expenseDesc,
    required this.expenseType,
    required this.expenseAmount,
    required this.expenseDate,
    required this.expensePaymentMethod,
    required this.expenseTime,
    required this.expenseCategory,
  });

  factory ExpenseModel.fromCsv(List<String> values) {
    String localexpenseType = '';
    int amount = 0;
    if (values[5].toString().isNotEmpty) {
      localexpenseType = 'in';
      amount = int.parse(values[5]);
    }
    if (values[6].toString().isNotEmpty) {
      localexpenseType = 'out';
      amount = int.parse(values[6]);
    }
    return ExpenseModel(
        expenseDesc: values[2],
        expenseType: localexpenseType,
        expenseAmount: amount,
        expenseDate: values[0],
        expensePaymentMethod: values[4],
        expenseTime: values[1],
        expenseCategory: values[3]);
  }
}
