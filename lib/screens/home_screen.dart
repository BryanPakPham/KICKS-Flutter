
import 'package:flutter/material.dart';

import '../data/product_data.dart';
import '../Models/product.dart';
import '../widgets/home/category_list.dart';
import '../widgets/home/search_filter.dart';
import '../widgets/home/product_card.dart';
import '../widgets/home/filter_bottom_sheet.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Danh mục đang được chọn
  String selectedCategory = 'All Shoes';

  // Danh sách sản phẩm yêu thích
  Set<int> favoriteProducts = {};

  // Chuỗi tìm kiếm
  String searchQuery = '';

  // Controller tìm kiếm
  final TextEditingController searchController = TextEditingController();

  // Kiểu sắp xếp giá
  String selectedSort = 'Default';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc sản phẩm theo danh mục và từ khóa
    final List<MapEntry<int, Product>> filteredProducts =
    productList.asMap().entries.where((entry) {
      final product = entry.value;

      final matchesCategory = selectedCategory == 'All Shoes' ||
          product.categories.contains(selectedCategory);

      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      return matchesCategory && matchesSearch;
    }).toList();

    // Sắp xếp giá
    if (selectedSort == 'Low to High') {
      filteredProducts.sort(
            (a, b) => a.value.price.compareTo(b.value.price),
      );
    } else if (selectedSort == 'High to Low') {
      filteredProducts.sort(
            (a, b) => b.value.price.compareTo(a.value.price),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // Thanh tiêu đề
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 35,
          fit: BoxFit.contain,
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DANH MỤC
              const Text(
                'CATEGORIES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              CategoryList(
                categories: productCategories,
                selectedCategory: selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 20),

              // 2. TÌM KIẾM VÀ LỌC
              SearchFilter(
                controller: searchController,
                searchQuery: searchQuery,
                onSearchChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                onClear: () {
                  setState(() {
                    searchController.clear();
                    searchQuery = '';
                  });
                },
                onFilterTap: () {
                  showFilterOptions(
                    context: context,
                    selectedSort: selectedSort,
                    onSortChanged: (value) {
                      setState(() {
                        selectedSort = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 25),

              // 3. DANH SÁCH SẢN PHẨM
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALL PRODUCTS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredProducts.length} Products',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Hiển thị sản phẩm
              if (filteredProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No products found'),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final productEntry = filteredProducts[index];
                    final product = productEntry.value;
                    final productIndex = productEntry.key;

                    return ProductCard(
                      product: product,
                      isFavorite: favoriteProducts.contains(productIndex),
                      onFavoriteTap: () {
                        setState(() {
                          if (favoriteProducts.contains(productIndex)) {
                            favoriteProducts.remove(productIndex);
                          } else {
                            favoriteProducts.add(productIndex);
                          }
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: product,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
