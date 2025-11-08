// ignore_for_file: avoid_print

import 'dart:io';

import 'package:expense_tracker/common/displayAlert.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;

  const CustomAppBar({
    Key? key,
    this.leading,
    required this.title,
  }) : super(key: key);

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
            'Are you sure you want to delete everything? This action cannot be undone.',
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
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 4,
      actions: title == 'home'
          ? [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.appBarTheme.backgroundColor ??
                      (isDark ? Colors.white : Colors.grey[900]),
                ),
                onSelected: (String value) async {
                  if (value == 'import') {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['csv', 'xlsx']);
                    if (result != null && result.files.single.path != null) {
                      File file = File(result.files.single.path!);
                      await expenseService.importData(file);
                      AlertHelper.showAlert(
                          context: context,
                          title: 'Completed!',
                          message: 'Data is imported!!');
                    }
                  } else if (value == 'export') {
                    final success = await expenseService.exportData();
                    AlertHelper.showAlert(
                        context: context,
                        title: success ? 'Completed!' : 'Failed',
                        message: success
                            ? 'Data is exported!!'
                            : 'Error while exporting data!!');
                  } else if (value == 'deleteAll') {
                    showDeleteConfirmationDialog(context, () async {
                      await expenseService.deleteAll();
                    });
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'import',
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text('Import Data'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.file_download, color: Colors.greenAccent),
                        SizedBox(width: 10),
                        Text('Export Data'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'deleteAll',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete Data'),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : [],
      backgroundColor: theme.appBarTheme.backgroundColor ??
          (isDark ? Colors.grey[900] : Colors.white),
      iconTheme: theme.iconTheme,
      title: Text(
        title == 'home' ? 'Expense Tracker' : title,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.w600,
          color: theme.appBarTheme.titleTextStyle?.color ??
              (isDark ? Colors.white : Colors.black),
        ),
      ),
      centerTitle: true,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
