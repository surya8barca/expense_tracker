import 'package:expense_tracker/common/custom_appbar.dart';
import 'package:expense_tracker/constants/constants.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

TimeOfDay parseTime(String timeStr) {
  final parts = timeStr.split(RegExp(r'[: ]'));

  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);
  String period = parts[2].toUpperCase();

  if (period == "PM" && hour != 12) {
    hour += 12;
  } else if (period == "AM" && hour == 12) {
    hour = 0;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

class ExpenseAddUpdate extends StatefulWidget {
  final bool addExpense;
  final String entryType;
  final ExpenseModel existingData;
  const ExpenseAddUpdate(
      {super.key,
      required this.addExpense,
      required this.entryType,
      required this.existingData});

  @override
  State<ExpenseAddUpdate> createState() => _ExpenseAddUpdateState();
}

class _ExpenseAddUpdateState extends State<ExpenseAddUpdate> {
  MyExpenseData expenseListdata = MyExpenseData();

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  TextEditingController amountController = TextEditingController();
  TextEditingController descController = TextEditingController();

  String? categorySelected;
  DateTime dateSelected = DateTime.now();
  TimeOfDay timeSelected = TimeOfDay.now();
  String paymentModeSelected = 'Cash';
  final List<String> dateFilterList = AppConstants().dateFilterList;
  final List<String> expenseCategories = AppConstants().expenseCategories;
  final List<String> expenseTypeFilterList =
      AppConstants().expenseTypeFilterList;
  final List<String> paymentTypeFilterList =
      AppConstants().paymentTypeFilterList;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateSelected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != dateSelected) {
      setState(() {
        dateSelected = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeSelected,
    );

    if (picked != null && picked != timeSelected) {
      setState(() {
        timeSelected = picked;
      });
    }
  }

  bool validateEntries() {
    if (amountController.text.isNotEmpty && descController.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // dialog background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // rounded corners
        ),
        title: const Center(
          child: Text(
            'Caution!',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.addExpense) {
      amountController = TextEditingController(
          text: widget.existingData.expenseAmount.toString());
      descController =
          TextEditingController(text: widget.existingData.expenseDesc);
      if (expenseCategories.contains(widget.existingData.expenseCategory)) {
        categorySelected = widget.existingData.expenseCategory;
      }
      dateSelected = formatter.parse(widget.existingData.expenseDate);
      timeSelected = parseTime(widget.existingData.expenseTime);
      paymentModeSelected = widget.existingData.expensePaymentMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseService = Provider.of<MyExpenseData>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.06;
    final buttonFontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: CustomAppBar(
          title: widget.addExpense ? 'Add Expense' : 'Update Expense'),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //heading
          children: [
            Text(
              widget.addExpense
                  ? widget.entryType == 'in'
                      ? 'Cash In'
                      : 'Cash Out'
                  : 'Update Entry',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: widget.addExpense
                    ? widget.entryType == 'in'
                        ? Colors.green
                        : Colors.red
                    : Colors.blueAccent,
              ),
            ),
            Divider(),
            SizedBox(height: screenHeight * 0.005),
            //time and date
            Padding(
              padding: EdgeInsets.all(padding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                            "${dateSelected.day}-${dateSelected.month}-${dateSelected.year}"),
                        onPressed: () => _selectDate(context),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text("${timeSelected.format(context)}"),
                        onPressed: () => _pickTime(context),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  //amount form field
                  Text(
                    'Amount*',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.currency_rupee, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Padding(
              padding: EdgeInsets.all(padding / 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description*',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  TextFormField(
                    controller: descController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.description, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Padding(
              padding: EdgeInsets.all(padding / 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: categorySelected,
                    hint:
                        Text(categorySelected == null ? 'Select Category' : ''),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    items: expenseCategories
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        categorySelected = value;
                      });
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Wrap(
              spacing: 8, // space between chips
              children: paymentTypeFilterList.map((option) {
                final isSelected = option == paymentModeSelected;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  shadowColor: Colors.black26,
                  elevation: isSelected ? 4 : 1,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      paymentModeSelected = selected ? option : '';
                    });
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.lightBlue[50],
                );
              }).toList(),
            ),
            SizedBox(height: screenHeight * 0.005),
            Divider(),
            SizedBox(height: screenHeight * 0.005),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (validateEntries()) {
                    if (widget.addExpense) {
                      ExpenseModel newExpense = ExpenseModel(
                          expenseDesc: descController.text,
                          expenseType: widget.entryType,
                          expenseAmount: int.parse(amountController.text),
                          expenseDate: formatter.format(dateSelected),
                          expensePaymentMethod: paymentModeSelected,
                          expenseTime: timeSelected.format(context),
                          expenseCategory: categorySelected ?? 'Uncategorized');
                      expenseService.addExpense(newExpense);
                    } else {
                      widget.existingData.expenseDesc = descController.text;
                      widget.existingData.expenseAmount =
                          int.parse(amountController.text);
                      widget.existingData.expenseDate =
                          formatter.format(dateSelected);
                      widget.existingData.expensePaymentMethod =
                          paymentModeSelected;
                      widget.existingData.expenseTime =
                          timeSelected.format(context);
                      widget.existingData.expenseCategory =
                          categorySelected ?? 'Uncategorized';
                      expenseService.updateExpense(widget.existingData);
                    }

                    Navigator.pop(context);
                  } else {
                    showAlert(context, 'Amount and Description are mandatory');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.addExpense
                      ? widget.entryType == 'in'
                          ? Colors.green
                          : Colors.red
                      : Colors.blueAccent, // dark button
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    widget.addExpense ? 'Add Expense' : 'Update Expense',
                    style: TextStyle(
                        fontSize: buttonFontSize, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
