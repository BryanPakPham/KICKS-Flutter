
import 'package:flutter/material.dart';

void showFilterOptions({
  required BuildContext context,
  required String selectedSort,
  required Function(String) onSortChanged,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FILTER & SORT',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Sort by price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            RadioListTile<String>(
              title: const Text('Default'),
              value: 'Default',
              groupValue: selectedSort,
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Price: Low to High'),
              value: 'Low to High',
              groupValue: selectedSort,
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Price: High to Low'),
              value: 'High to Low',
              groupValue: selectedSort,
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
