class Filters {
  String? selectedDateFilter;
  String? selectedCategoryFilter;
  String? selectedExpenseTypeFilter;
  String? selectedPaymentOptionFilter;

  bool get hasAnyFilter =>
      selectedDateFilter != null ||
      selectedCategoryFilter != null ||
      selectedExpenseTypeFilter != null ||
      selectedPaymentOptionFilter != null;

  void clearAll() {
    selectedDateFilter = null;
    selectedCategoryFilter = null;
    selectedExpenseTypeFilter = null;
    selectedPaymentOptionFilter = null;
  }
}
