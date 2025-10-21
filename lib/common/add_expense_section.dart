import 'package:expense_tracker/add_expense.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';

class AddExpenseSection extends StatelessWidget {
  AddExpenseSection({
    super.key,
  });

  final ExpenseModel emptyExpense = new ExpenseModel(
      expenseDesc: '',
      expenseType: '',
      expenseAmount: 0,
      expenseDate: '',
      expensePaymentMethod: '',
      expenseTime: '',
      expenseCategory: '');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonFontSize = screenWidth * 0.035;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpenseAddUpdate(
                            addExpense: true,
                            entryType: 'in',
                            existingData: emptyExpense,
                          )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // dark button
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cash In',
              style: TextStyle(fontSize: buttonFontSize, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpenseAddUpdate(
                            addExpense: true,
                            entryType: 'out',
                            existingData: emptyExpense,
                          )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // accent color
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cash Out',
              style: TextStyle(fontSize: buttonFontSize, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
