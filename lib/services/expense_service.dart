import 'dart:io';

import 'package:csv/csv.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/filters.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    if (_filteredExpenses.isEmpty) {
      _filters.selectedDateFilter = 'This Month';
    }
    _filteredExpenses = applyFilter(_filters);
    notifyListeners();

    _expensesBox.listenable().addListener(() {
      _expenses = _expensesBox.values.toList();
      _filteredExpenses = applyFilter(_filters);
      notifyListeners();
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesBox.add(expense);
    _refreshFilteredExpenses();
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    await expense.delete();
    _refreshFilteredExpenses();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await expense.save();
    _refreshFilteredExpenses();
  }

  Future<void> deleteAll() async {
    await _expensesBox.clear();
    _refreshFilteredExpenses();
  }

  void _refreshFilteredExpenses() {
    _expenses = _expensesBox.values.toList();
    _filteredExpenses = applyFilter(_filters);
    notifyListeners();
  }

  List<ExpenseModel> applyFilter(Filters filters) {
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
    return _filteredExpenses;
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

      // Parse 12-hour time with AM/PM support
      final timeFormatter = DateFormat('hh:mm a');
      final timeA = timeFormatter.parse(a.expenseTime);
      final timeB = timeFormatter.parse(b.expenseTime);

      // Combine date + time into one DateTime
      final dateTimeA = DateTime(
          dateA.year, dateA.month, dateA.day, timeA.hour, timeA.minute);
      final dateTimeB = DateTime(
          dateB.year, dateB.month, dateB.day, timeB.hour, timeB.minute);

      // Sort so latest (newest) comes on top by default
      return ascending
          ? dateTimeA.compareTo(dateTimeB)
          : dateTimeB.compareTo(dateTimeA);
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

  Future<bool> exportData() async {
    bool successFullyExported = false;
    try {
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isGranted ||
            await Permission.storage.isGranted) {
        } else {
          if (Platform.operatingSystemVersion.contains("Android 13") ||
              Platform.operatingSystemVersion.contains("Android 14")) {
            final photos = await Permission.photos.request();
            final videos = await Permission.videos.request();
            final audio = await Permission.audio.request();
            if (!photos.isGranted && !videos.isGranted && !audio.isGranted) {
              throw Exception("Storage permission not granted");
            }
          } else {
            final status = await Permission.storage.request();
            if (!status.isGranted) {
              throw Exception("Storage permission not granted");
            }
          }
        }
      }
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception("Storage permission not granted");
      }

      final List<List<dynamic>> rows = [
        ['Date', 'Time', 'Remark', 'Category', 'Mode', 'Cash In', 'Cash Out']
      ];

      for (var expense in _expensesBox.values) {
        final isCashIn = expense.expenseType.toLowerCase() == 'in';

        rows.add([
          expense.expenseDate,
          expense.expenseTime,
          expense.expenseDesc,
          expense.expenseCategory,
          expense.expensePaymentMethod,
          isCashIn ? expense.expenseAmount : '',
          isCashIn ? '' : expense.expenseAmount,
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);

      Directory? downloadsDir;

      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final filePath =
          '${downloadsDir.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);

      await file.writeAsString(csvData);
      successFullyExported = true;
    } catch (e) {
      print('❌ Error exporting CSV: $e');
    }
    return successFullyExported;
  }
}
