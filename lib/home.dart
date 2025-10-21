// ignore_for_file: unused_element

import 'package:expense_tracker/common/add_expense_section.dart';
import 'package:expense_tracker/common/custom_appbar.dart';
import 'package:expense_tracker/common/expenseCard.dart';
import 'package:expense_tracker/common/loadingScreen.dart';
import 'package:expense_tracker/common/no_expense_screen.dart';
import 'package:expense_tracker/common/statsBox.dart';
import 'package:expense_tracker/constants/constants.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expenseService = Provider.of<MyExpenseData>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.045;
    final List<String> dateFilterList = AppConstants().dateFilterList;
    final List<String> expenseCategories = AppConstants().expenseCategories;
    final List<String> expenseTypeFilterList =
        AppConstants().expenseTypeFilterList;
    final List<String> paymentTypeFilterList =
        AppConstants().paymentTypeFilterList;
    var filters = expenseService.filters;
    if (filters.hasAnyFilter) {
      expenseService.applyFilter(filters);
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'home'),
      body: expenseService.isLoading
          ? LoadingScreen()
          : expenseService.expenses.isEmpty
              ? NoExpenseScreen(
                  screenHeight: screenHeight,
                  padding: padding,
                  titleFontSize: titleFontSize)
              : Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      // filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (filters.hasAnyFilter)
                              IconButton(
                                  onPressed: () {
                                    expenseService.clearAllFilters();
                                    filters.clearAll();
                                  },
                                  icon: Icon(Icons.clear_all)),
                            //Date filter
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: filters.selectedDateFilter == null
                                    ? Colors.lightBlue[50]
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: filters.selectedDateFilter,
                                      hint: Text('Select Timeline'),
                                      dropdownColor: Colors.lightBlue[50],
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: Colors.black),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      onChanged: (value) {
                                        setState(() {
                                          filters.selectedDateFilter = value;
                                        });
                                        expenseService.applyFilter(filters);
                                      },
                                      items: dateFilterList
                                          .map((datefilter) => DropdownMenuItem(
                                                value: datefilter,
                                                child: Text(datefilter),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  if (filters.selectedDateFilter != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          filters.selectedDateFilter = null;
                                        });
                                        if (!filters.hasAnyFilter) {
                                          expenseService.clearAllFilters();
                                        } else {
                                          expenseService.applyFilter(filters);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(Icons.clear,
                                            color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            // Category filter
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: filters.selectedCategoryFilter == null
                                    ? Colors.lightBlue[50]
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: filters.selectedCategoryFilter,
                                      hint: Text('Select Category'),
                                      dropdownColor: Colors.lightBlue[50],
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: Colors.black),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      onChanged: (value) {
                                        setState(() {
                                          filters.selectedCategoryFilter =
                                              value!;
                                        });
                                        expenseService.applyFilter(filters);
                                      },
                                      items: expenseCategories
                                          .map((category) => DropdownMenuItem(
                                                value: category,
                                                child: Text(category),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  if (filters.selectedCategoryFilter != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          filters.selectedCategoryFilter = null;
                                        });
                                        if (!filters.hasAnyFilter) {
                                          expenseService.clearAllFilters();
                                        } else {
                                          expenseService.applyFilter(filters);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(Icons.clear,
                                            color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            //Payment option filter
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color:
                                    filters.selectedPaymentOptionFilter == null
                                        ? Colors.lightBlue[50]
                                        : Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value:
                                          filters.selectedPaymentOptionFilter,
                                      hint: Text('Select Payment Type'),
                                      dropdownColor: Colors.lightBlue[50],
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: Colors.black),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      onChanged: (value) {
                                        setState(() {
                                          filters.selectedPaymentOptionFilter =
                                              value!;
                                        });
                                        expenseService.applyFilter(filters);
                                      },
                                      items: paymentTypeFilterList
                                          .map(
                                              (paymentType) => DropdownMenuItem(
                                                    value: paymentType,
                                                    child: Text(paymentType),
                                                  ))
                                          .toList(),
                                    ),
                                  ),
                                  if (filters.selectedPaymentOptionFilter !=
                                      null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          filters.selectedPaymentOptionFilter =
                                              null;
                                        });
                                        if (!filters.hasAnyFilter) {
                                          expenseService.clearAllFilters();
                                        } else {
                                          expenseService.applyFilter(filters);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(Icons.clear,
                                            color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            // Expense Type filter
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: filters.selectedExpenseTypeFilter == null
                                    ? Colors.lightBlue[50]
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: filters.selectedExpenseTypeFilter,
                                      hint: Text('Select Expense Type'),
                                      dropdownColor: Colors.lightBlue[50],
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: Colors.black),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      onChanged: (value) {
                                        setState(() {
                                          filters.selectedExpenseTypeFilter =
                                              value!;
                                        });
                                        expenseService.applyFilter(filters);
                                      },
                                      items: expenseTypeFilterList
                                          .map((type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(type),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  if (filters.selectedExpenseTypeFilter != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          filters.selectedExpenseTypeFilter =
                                              null;
                                        });
                                        if (!filters.hasAnyFilter) {
                                          expenseService.clearAllFilters();
                                        } else {
                                          expenseService.applyFilter(filters);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(Icons.clear,
                                            color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Divider(),
                      //Stats
                      StatsBox(
                          padding: padding,
                          titleFontSize: titleFontSize,
                          netExpense: expenseService.netExpense,
                          totalIn: expenseService.totalIn,
                          totalOut: expenseService.totalOut),
                      SizedBox(height: screenHeight * 0.005),
                      //Entries
                      Expanded(
                        child: ExpenseCard(),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Divider(),
                      //action buttons
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: AddExpenseSection(),
                      )
                    ],
                  ),
                ),
    );
  }
}
