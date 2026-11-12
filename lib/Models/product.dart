
import 'product_color.dart';

class Product {
  final int id;
  final String productCode;
  final String name;
  final String slug;
  final double price;
  final String description;
  final List<String> categories;
  final List<ProductColor> colors;

  Product({
    required this.id,
    required this.productCode,
    required this.name,
    required this.slug,
    required this.price,
    required this.description,
    required this.categories,
    required this.colors,
  });
}
