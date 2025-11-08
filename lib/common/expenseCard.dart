import 'package:expense_tracker/add_expense.dart';
import 'package:expense_tracker/common/displayAlert.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
  });

  void showDeleteConfirmationDialog(
      BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              'Confirm Deletion',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this item? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Delete Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                onDelete();
                AlertHelper.showAlert(
                    context: context,
                    title: 'Success!',
                    message: 'Expense Deleted!!');
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseService = Provider.of<MyExpenseData>(context);
    expenseService.sortByDate();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.03;
    final titleFontSize = screenWidth * 0.05;
    final countFontSize = screenWidth * 0.04;
    final extraDetailsFontSize = screenWidth * 0.04;
    final iconButtonSize = screenWidth * 0.05;
    return ListView.builder(
        itemCount: expenseService.filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense =
              context.watch<MyExpenseData>().filteredExpenses[index];
          final isIncome = expense.expenseType == 'in';
          final color = isIncome ? Colors.green : Colors.red;
          bool showDateHeader = index == 0 ||
              expenseService.filteredExpenses[index - 1].expenseDate !=
                  expense.expenseDate;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader)
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    children: [
                      Text(
                        expense.expenseDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Expanded(
                        child: Divider(thickness: 1.2, indent: 10),
                      ),
                    ],
                  ),
                ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹ ${NumberFormat('#,##0.00').format(expense.expenseAmount)}",
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ExpenseAddUpdate(
                                                  addExpense: false,
                                                  entryType:
                                                      expense.expenseType,
                                                  existingData: expense)));
                                },
                                icon:
                                    Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                onPressed: () {
                                  showDeleteConfirmationDialog(context, () {
                                    expense.delete();
                                  });
                                },
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete',
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      if (expense.expenseDesc.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              expense.expenseDesc,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expense.expenseCategory,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: screenHeight * 0.010),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment,
                                  size: iconButtonSize, color: Colors.grey),
                              SizedBox(height: screenWidth * 0.005),
                              Text(
                                expense.expensePaymentMethod,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: extraDetailsFontSize),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: iconButtonSize, color: Colors.grey),
                              SizedBox(height: screenWidth * 0.005),
                              Text(
                                expense.expenseTime,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: countFontSize),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
