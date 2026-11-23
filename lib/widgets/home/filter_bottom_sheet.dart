
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
              'BỘ LỌC & SẮP XẾP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Sắp xếp theo giá',
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
              title: const Text('Giá: Thấp đến cao'),
              value: 'Thấp đến cao',
              groupValue: selectedSort,
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Giá: Cao đến thấp'),
              value: 'Cao đến thấp',
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
