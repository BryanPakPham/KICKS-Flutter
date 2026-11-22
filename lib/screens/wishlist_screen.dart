
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/product.dart';
import '../data/product_data.dart';
import '../services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();

  final Set<int> _removingIds = {};

  // Định dạng giá tiền Việt Nam
  String _formatPrice(double price) {
    final number = price.round().toString();

    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return '$formatted ₫';
  }

  // Bỏ sản phẩm khỏi Wishlist
  Future<void> _removeProduct(Product product) async {
    if (_removingIds.contains(product.id)) return;

    setState(() {
      _removingIds.add(product.id);
    });

    try {
      await _wishlistService.removeFromWishlist(product.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã bỏ ${product.name} khỏi danh sách yêu thích',
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể bỏ yêu thích. Vui lòng thử lại.',
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _removingIds.remove(product.id);
        });
      }
    }
  }

  // Giao diện khi chưa đăng nhập hoặc Wishlist trống
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFF3F3F3),
              child: Icon(
                icon,
                size: 44,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thẻ hiển thị sản phẩm yêu thích
  Widget _buildProductCard(Product product) {
    final imagePath = product.colors.isNotEmpty
        ? product.colors.first.sideImage
        : '';

    final isRemoving = _removingIds.contains(product.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Row(
        children: [
          // HÌNH ẢNH SẢN PHẨM
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 112,
              height: 112,
              color: const Color(0xFFF5F5F5),
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 32,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // THÔNG TIN SẢN PHẨM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productCode,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // NÚT BỎ YÊU THÍCH
          IconButton(
            tooltip: 'Bỏ yêu thích',
            onPressed: isRemoving
                ? null
                : () => _removeProduct(product),
            icon: isRemoving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.favorite,
                    color: Colors.black,
                    size: 25,
                  ),
          ),
        ],
      ),
    );
  }

  // Nội dung Wishlist theo tài khoản Firebase
  Widget _buildWishlistContent() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }

        if (authSnapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'KHÔNG THỂ TẢI TÀI KHOẢN',
            description: 'Vui lòng thử lại sau.',
          );
        }

        // CHƯA ĐĂNG NHẬP
        if (authSnapshot.data == null) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'ĐĂNG NHẬP ĐỂ XEM YÊU THÍCH',
            description:
                'Vui lòng vào tab Account để đăng nhập '
                'và quản lý những đôi giày bạn yêu thích.',
          );
        }

        // ĐÃ ĐĂNG NHẬP - ĐỌC WISHLIST TỪ FIRESTORE
        return StreamBuilder<Set<int>>(
          stream: _wishlistService.watchWishlistIds(),
          builder: (context, wishlistSnapshot) {
            if (wishlistSnapshot.connectionState ==
                    ConnectionState.waiting &&
                !wishlistSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }

            if (wishlistSnapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'KHÔNG THỂ TẢI WISHLIST',
                description:
                    'Vui lòng kiểm tra kết nối Internet '
                    'hoặc quyền truy cập Firebase.',
              );
            }

            final wishlistIds =
                wishlistSnapshot.data ?? <int>{};

            // Chỉ lấy các sản phẩm thật trong product_data.dart
            final favoriteProducts = productList
                .where(
                  (product) => wishlistIds.contains(product.id),
                )
                .toList();

            if (favoriteProducts.isEmpty) {
              return _buildEmptyState(
                icon: Icons.favorite_border,
                title: 'CHƯA CÓ SẢN PHẨM YÊU THÍCH',
                description:
                    'Những đôi giày bạn yêu thích sẽ '
                    'xuất hiện tại đây.\n'
                    'Hãy khám phá sản phẩm tại tab Home.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${favoriteProducts.length} sản phẩm yêu thích',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: favoriteProducts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        favoriteProducts[index],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  const Text(
                    'DANH SÁCH YÊU THÍCH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Những đôi giày bạn yêu thích tại KICKS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 26),

                  Expanded(
                    child: _buildWishlistContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
