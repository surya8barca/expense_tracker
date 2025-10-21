import 'package:expense_tracker/common/add_expense_section.dart';
import 'package:flutter/material.dart';

class NoExpenseScreen extends StatelessWidget {
  const NoExpenseScreen({
    super.key,
    required this.screenHeight,
    required this.padding,
    required this.titleFontSize,
  });

  final double screenHeight;
  final double padding;
  final double titleFontSize;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey("empty"),
      child: SizedBox(
        height: screenHeight - kToolbarHeight - 80,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Center(
                child: Text(
                  'No expenses added',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: AddExpenseSection(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
