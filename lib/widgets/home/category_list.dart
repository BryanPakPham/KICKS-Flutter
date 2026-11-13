
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryList({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              selectedColor: Colors.black,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: selectedCategory == category
                    ? Colors.white
                    : Colors.black,
                fontSize: 12,
              ),
              onSelected: (selected) {
                onCategoryChanged(category);
              },
            ),
          );
        },
      ),
    );
  }
}
