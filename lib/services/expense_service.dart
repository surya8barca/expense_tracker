import 'dart:io';

import 'package:csv/csv.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/filters.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class MyExpenseData extends ChangeNotifier {
  late Box<ExpenseModel> _expensesBox = Hive.box('expenses');
  bool _isLoading = false;
  int netExpense = 0;
  int totalIn = 0;
  int totalOut = 0;
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  List<ExpenseModel> lastFilteredExpenses = [];
  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseModel> get filteredExpenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  Filters _filters = Filters();
  Filters get filters => _filters;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  @override
  void notifyListeners() {
    sortByDate();
    _calculateNumber();
    super.notifyListeners();
  }

  Future<void> init() async {
    _expenses = _expensesBox.values.toList();
    _filteredExpenses = List.from(_expenses);
    if (!_filteredExpenses.isEmpty) {
      _filters.selectedDateFilter = 'This Month';
    }
    notifyListeners();

    _expensesBox.listenable().addListener(() {
      _expenses = _expensesBox.values.toList();
      _filteredExpenses = List.from(_expenses);
      if (_filters.hasAnyFilter) {
        applyFilter(_filters);
      }
      notifyListeners();
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesBox.add(expense);
    notifyListeners();
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    await expense.delete();
    notifyListeners();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await expense.save();
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _expensesBox.clear();
    notifyListeners();
  }

  void applyFilter(Filters filters) {
    print("total expense:" + _expenses.length.toString());
    lastFilteredExpenses = _filteredExpenses;
    _filteredExpenses = _expenses.where((e) {
      final matchesDate = filters.selectedDateFilter == null ||
          (timelineFilterApply(filters.selectedDateFilter!, e));

      final matchesCategory = filters.selectedCategoryFilter == null ||
          e.expenseCategory == filters.selectedCategoryFilter;

      final matchesExpenseType = filters.selectedExpenseTypeFilter == null ||
          filters.selectedExpenseTypeFilter!
              .toLowerCase()
              .contains(e.expenseType);

      final matchesPaymentType = filters.selectedPaymentOptionFilter == null ||
          e.expensePaymentMethod == filters.selectedPaymentOptionFilter;

      return matchesDate &&
          matchesCategory &&
          matchesExpenseType &&
          matchesPaymentType;
    }).toList();

    print("before filter:" + _filteredExpenses.length.toString());
    notifyListeners();
  }

  bool timelineFilterApply(String timeline, ExpenseModel expense) {
    bool matches = false;
    DateTime today = DateTime.now();
    String todayDate = _formatter.format(today);
    int thisMonth = today.month;
    int thisYear = today.year;

    switch (timeline) {
      case 'Today':
        matches = (expense.expenseDate == todayDate);
      case 'This Month':
        matches = (int.parse(expense.expenseDate.split("-")[1]) == thisMonth);
      case 'Last Month':
        matches =
            (int.parse(expense.expenseDate.split("-")[1]) == thisMonth - 1);
      case 'This Year':
        matches = (int.parse(expense.expenseDate.split("-")[2]) == thisYear);
      default:
        matches = false;
    }
    return matches;
  }

  void clearAllFilters() {
    _filteredExpenses = List.from(_expenses);
    notifyListeners();
  }

  void _calculateNumber() {
    int netExpenseLocal = 0;
    int totalInLocal = 0;
    int totalOutLocal = 0;
    for (final expense in _filteredExpenses) {
      if (expense.expenseType == 'out') {
        totalOutLocal += expense.expenseAmount;
      } else {
        totalInLocal += expense.expenseAmount;
      }
    }
    netExpenseLocal = totalInLocal - totalOutLocal;
    netExpense = netExpenseLocal;
    totalIn = totalInLocal;
    totalOut = totalOutLocal;
  }

  void sortByDate({bool ascending = false}) {
    _filteredExpenses.sort((a, b) {
      final dateA = _formatter.parse(a.expenseDate);
      final dateB = _formatter.parse(b.expenseDate);
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }

  List<ExpenseModel> get expenseList => _expensesBox.values.toList();

  Future<void> importData(File importFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawFile = await importFile.readAsString();
      List<List<dynamic>> rows = const CsvToListConverter().convert(rawFile);
      List<ExpenseModel> importedExpenses = rows.skip(1).map((row) {
        return ExpenseModel.fromCsv(row.map((e) => e.toString()).toList());
      }).toList();
      await _expensesBox.addAll(importedExpenses);
      notifyListeners();
    } catch (e) {
      print('Error loading CSV: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
