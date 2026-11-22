
import 'package:flutter/material.dart';
import '../Models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wishlist_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedColorIndex = 0;
  String? selectedSize;
  bool showTopImage = false;

  final WishlistService _wishlistService = WishlistService();

  final Stream<User?> _authStream =
      FirebaseAuth.instance.authStateChanges();

  Stream<Set<int>>? _wishlistStream;
  String? _wishlistUserId;

  bool _isUpdatingFavorite = false;

  // Giữ stream Wishlist ổn định
  Stream<Set<int>> _getWishlistStream(String uid) {
    if (_wishlistUserId != uid) {
      _wishlistUserId = uid;
      _wishlistStream = _wishlistService.watchWishlistIds();
    }

    return _wishlistStream!;
  }

  // Thêm hoặc bỏ yêu thích sản phẩm
  Future<void> _toggleFavorite() async {
    if (_isUpdatingFavorite) return;

    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng đăng nhập để yêu thích sản phẩm',
          ),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingFavorite = true;
    });

    try {
      await _wishlistService.toggleWishlist(widget.product);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể cập nhật yêu thích. Vui lòng thử lại.',
          ),
          backgroundColor: Colors.black,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Màu sắc đang chọn
    final selectedColor = product.colors[selectedColorIndex];

    // Ảnh đang hiển thị
    final currentImage = showTopImage
        ? selectedColor.topImage
        : selectedColor.sideImage;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'PRODUCT DETAILS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),

        // NÚT YÊU THÍCH
        actions: [
          StreamBuilder<User?>(
            stream: _authStream,
            builder: (context, authSnapshot) {
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) {
                return IconButton(
                  tooltip: 'Yêu thích sản phẩm',
                  onPressed: _toggleFavorite,
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.black,
                  ),
                );
              }

              return StreamBuilder<Set<int>>(
                stream: _getWishlistStream(user.uid),
                builder: (context, wishlistSnapshot) {
                  final isFavorite = wishlistSnapshot.data
                          ?.contains(widget.product.id) ??
                      false;

                  return IconButton(
                    tooltip: isFavorite
                        ? 'Bỏ yêu thích'
                        : 'Thêm vào yêu thích',
                    onPressed:
                        _isUpdatingFavorite ? null : _toggleFavorite,
                    icon: _isUpdatingFavorite
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Colors.black,
                          ),
                  );
                },
              );
            },
          ),

          const SizedBox(width: 8),
        ],

      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CỘT BÊN TRÁI: HÌNH ẢNH
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Container(
                    height: 500,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: Image.asset(
                      currentImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Chọn góc nhìn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Side View'),
                        selected: !showTopImage,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(
                          color: !showTopImage
                              ? Colors.white
                              : Colors.black,
                        ),
                        onSelected: (value) {
                          setState(() {
                            showTopImage = false;
                          });
                        },
                      ),

                      const SizedBox(width: 10),

                      ChoiceChip(
                        label: const Text('Top View'),
                        selected: showTopImage,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(
                          color: showTopImage
                              ? Colors.white
                              : Colors.black,
                        ),
                        onSelected: (value) {
                          setState(() {
                            showTopImage = true;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 30),

            // CỘT BÊN PHẢI: THÔNG TIN SẢN PHẨM
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Giá
                  Text(
                    '${product.price} VND',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mô tả
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CHỌN MÀU
                  const Text(
                    'SELECT COLOR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      product.colors.length,
                          (index) {
                        final color = product.colors[index];

                        return ChoiceChip(
                          label: Text(color.name),
                          selected: selectedColorIndex == index,
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(
                            color: selectedColorIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (value) {
                            setState(() {
                              selectedColorIndex = index;
                              selectedSize = null;
                              showTopImage = false;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CHỌN SIZE
                  const Text(
                    'SELECT SIZE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: selectedColor.sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: selectedSize == size,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(
                          color: selectedSize == size
                              ? Colors.white
                              : Colors.black,
                        ),
                        onSelected: (value) {
                          setState(() {
                            selectedSize = size;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 35),

                  // ADD TO CART
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedSize == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a size!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} added to cart!',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
