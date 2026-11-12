
import 'package:flutter/material.dart';

import '../data/product_data.dart';
import '../Models/product.dart';

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

      // Lọc danh mục
      final matchesCategory = selectedCategory == 'All Shoes' ||
          product.categories.contains(selectedCategory);

      // Tìm kiếm theo tên
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'NIKE STORE',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DANH MỤC SẢN PHẨM
              const Text(
                'CATEGORIES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productCategories.length,
                  itemBuilder: (context, index) {
                    final category = productCategories[index];

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
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 2. TÌM KIẾM VÀ LỌC
              Row(
                children: [
                  // Thanh tìm kiếm
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search shoes...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Nút Filter
                  IconButton(
                    onPressed: _showFilterOptions,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ],
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

              // Hiển thị sản phẩm dạng 2 cột
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

                    return _buildProductCard(
                      product,
                      productIndex,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. BẢNG LỌC VÀ SẮP XẾP
  void _showFilterOptions() {
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

              // Mặc định
              RadioListTile<String>(
                title: const Text('Default'),
                value: 'Default',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
              ),

              // Giá thấp đến cao
              RadioListTile<String>(
                title: const Text('Price: Low to High'),
                value: 'Low to High',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
              ),

              // Giá cao đến thấp
              RadioListTile<String>(
                title: const Text('Price: High to Low'),
                value: 'High to Low',
                groupValue: selectedSort,
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                  });
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // 5. THẺ SẢN PHẨM
  Widget _buildProductCard(Product product, int index) {
    final isFavorite = favoriteProducts.contains(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hình ảnh và icon yêu thích
        SizedBox(
          height: 500,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey.shade100,
                child: Image.asset(
                  product.colors.first.sideImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                ),
              ),

              // Nút yêu thích
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        favoriteProducts.remove(index);
                      } else {
                        favoriteProducts.add(index);
                      }
                    });
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tên sản phẩm
        const SizedBox(height: 4),

        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        // Giá sản phẩm
        Text(
          '${product.price} VND',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
