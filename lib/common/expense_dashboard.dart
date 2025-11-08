import 'package:expense_tracker/common/custom_appbar.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseDashboard extends StatelessWidget {
  const ExpenseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseService = Provider.of<MyExpenseData>(context);
    final expenses = expenseService.filteredExpenses;

    final Map<String, double> categoryTotals = {};
    final Map<String, double> paymentTotals = {};
    final Map<String, double> dailyTotals = {}; // 👈 new for trend
    double totalExpense = 0;

    for (var e in expenses) {
      final amount = double.tryParse(e.expenseAmount.toString()) ?? 0.0;
      totalExpense += amount;

      categoryTotals[e.expenseCategory] =
          (categoryTotals[e.expenseCategory] ?? 0) + amount;
      paymentTotals[e.expensePaymentMethod] =
          (paymentTotals[e.expensePaymentMethod] ?? 0) + amount;

      final date = e.expenseDate;
      final dateKey = date.toString().split("-")[0];
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
    }

    final categoryData =
        categoryTotals.entries.map((e) => _ChartData(e.key, e.value)).toList();
    final paymentData =
        paymentTotals.entries.map((e) => _ChartData(e.key, e.value)).toList();
    final dailyData = dailyTotals.entries
        .map((e) => _ChartData(e.key, e.value))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label)); // chronological

    return Scaffold(
      appBar: CustomAppBar(title: 'Expense Dashboard'),
      body: _DashboardBody(
        totalExpense: totalExpense,
        categoryData: categoryData,
        paymentData: paymentData,
        dailyData: dailyData,
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final double totalExpense;
  final List<_ChartData> categoryData;
  final List<_ChartData> paymentData;
  final List<_ChartData> dailyData;

  const _DashboardBody({
    required this.totalExpense,
    required this.categoryData,
    required this.paymentData,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Colors.cyanAccent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Total Spent"),
          _totalCard(totalExpense, cardColor),
          const SizedBox(height: 24),
          _sectionTitle("By Category"),
          _pieChart(categoryData, cardColor),
          const SizedBox(height: 24),
          _sectionTitle("By Payment Method"),
          _barChart(paymentData, cardColor),
          const SizedBox(height: 24),
          _sectionTitle("Daily Expense Trend"),
          _lineChart(dailyData, cardColor),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      );

  Widget _totalCard(double totalExpense, Color cardColor) => Card(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              "₹${totalExpense.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
        ),
      );

  Widget _pieChart(List<_ChartData> data, Color cardColor) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SfCircularChart(
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CircularSeries<_ChartData, String>>[
            PieSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData d, _) => d.label,
              yValueMapper: (_ChartData d, _) => d.value,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barChart(List<_ChartData> data, Color cardColor) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<_ChartData, String>>[
            ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData d, _) => d.label,
              yValueMapper: (_ChartData d, _) => d.value,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.green.shade500,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineChart(List<_ChartData> data, Color cardColor) {
    if (data.isEmpty) {
      return const Center(child: Text("No daily data available"));
    }
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            labelRotation: -45,
            majorGridLines: const MajorGridLines(width: 0),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<_ChartData, String>>[
            LineSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData d, _) => d.label,
              yValueMapper: (_ChartData d, _) => d.value,
              color: Colors.blueAccent,
              width: 3,
              markerSettings: const MarkerSettings(isVisible: true),
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  _ChartData(this.label, this.value);
}
