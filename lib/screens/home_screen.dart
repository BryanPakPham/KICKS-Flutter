
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/product_data.dart';
import '../Models/product.dart';
import '../services/wishlist_service.dart';

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
  // ==========================================
  // 1. QUẢN LÝ DANH MỤC, TÌM KIẾM, SẮP XẾP
  // ==========================================

  String selectedCategory = 'Tất cả giày';
  String searchQuery = '';
  String selectedSort = 'Default';

  final TextEditingController searchController =
      TextEditingController();

  // ==========================================
  // 2. FIREBASE WISHLIST
  // ==========================================

  final WishlistService _wishlistService =
      WishlistService();

  final Stream<User?> _authStream =
      FirebaseAuth.instance.authStateChanges();

  // Giữ stream ổn định khi Home rebuild
  final Map<String, Stream<Set<int>>> _wishlistStreams = {};

  // Ngăn nhấn trái tim liên tục khi đang lưu
  final Set<int> _updatingFavoriteIds = {};

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // 3. XỬ LÝ THÊM / BỎ YÊU THÍCH
  // ==========================================

  Future<void> _toggleFavorite(
    Product product,
    User? user,
  ) async {
    // Yêu cầu đăng nhập
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng đăng nhập để yêu thích sản phẩm',
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Không xử lý trùng khi đang gửi Firebase
    if (!_updatingFavoriteIds.add(product.id)) {
      return;
    }

    try {
      await _wishlistService.toggleWishlist(product);

      // StreamBuilder sẽ tự cập nhật trái tim
      // khi Firestore thay đổi.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể cập nhật yêu thích. '
            'Vui lòng thử lại.',
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _updatingFavoriteIds.remove(product.id);
    }
  }

  // ==========================================
  // 4. HIỂN THỊ DANH SÁCH SẢN PHẨM
  // ==========================================

  Widget _buildProductGrid(
    List<MapEntry<int, Product>> filteredProducts,
  ) {
    return StreamBuilder<User?>(
    stream: _authStream,
    builder: (context, authSnapshot) {
      final user = FirebaseAuth.instance.currentUser;

        // Chưa đăng nhập:
        // Vẫn xem được sản phẩm nhưng chưa có yêu thích.
        if (user == null) {
          return _buildGrid(
            filteredProducts,
            <int>{},
            null,
          );
        }

        // Theo dõi Wishlist riêng cho tài khoản
        final wishlistStream = _wishlistStreams.putIfAbsent(
          user.uid,
          () => _wishlistService.watchWishlistIds(),
        );

        return StreamBuilder<Set<int>>(
          stream: wishlistStream,
          builder: (context, wishlistSnapshot) {
            final favoriteIds =
                wishlistSnapshot.data ?? <int>{};

            return Column(
              children: [
                if (wishlistSnapshot.hasError)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Không thể đồng bộ danh sách yêu thích. '
                      'Vui lòng kiểm tra Firebase.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),

                _buildGrid(
                  filteredProducts,
                  favoriteIds,
                  user,
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 5. GRID SẢN PHẨM
  // ==========================================

  Widget _buildGrid(
    List<MapEntry<int, Product>> filteredProducts,
    Set<int> favoriteIds,
    User? user,
  ) {
    return GridView.builder(
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
        final product = filteredProducts[index].value;

        return ProductCard(
          product: product,

          // Trái tim lấy trạng thái từ Firestore
          isFavorite: favoriteIds.contains(product.id),

          // Thêm hoặc bỏ yêu thích
          onFavoriteTap: () {
            _toggleFavorite(product, user);
          },

          // Giữ nguyên chức năng mở chi tiết
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(
                  product: product,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 6. GIAO DIỆN HOME CHÍNH
  // ==========================================

  @override
  Widget build(BuildContext context) {
    // Lọc theo danh mục và từ khóa
    final List<MapEntry<int, Product>> filteredProducts =
        productList.asMap().entries.where((entry) {
      final product = entry.value;

      final matchesCategory =
          selectedCategory == 'Tất cả giày' ||
          product.categories.contains(selectedCategory);

      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      return matchesCategory && matchesSearch;
    }).toList();

    // Sắp xếp theo giá
    if (selectedSort == 'Thấp đến cao') {
      filteredProducts.sort(
        (a, b) =>
            a.value.price.compareTo(b.value.price),
      );
    } else if (selectedSort == 'Cao đến thấp') {
      filteredProducts.sort(
        (a, b) =>
            b.value.price.compareTo(a.value.price),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // THANH TIÊU ĐỀ
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
              // ==============================
              // DANH MỤC SẢN PHẨM
              // ==============================

              const Text(
                'DANH MỤC SẢN PHẨM',
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

              // ==============================
              // TÌM KIẾM VÀ LỌC
              // ==============================

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

              // ==============================
              // TIÊU ĐỀ DANH SÁCH SẢN PHẨM
              // ==============================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TẤT CẢ SẢN PHẨM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${filteredProducts.length} sản phẩm',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ==============================
              // DANH SÁCH SẢN PHẨM + WISHLIST
              // ==============================

              if (filteredProducts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('Không tìm thấy sản phẩm nào'),
                  ),
                )
              else
                _buildProductGrid(filteredProducts),
            ],
          ),
        ),
      ),
    );
  }
}
