
import '../Models/product.dart';
import '../Models/product_color.dart';

// Danh sách danh mục sản phẩm
final List<String> productCategories = [
  'Tất cả giày',
  'Giày nam',
  'Giày nữ',
  'Running',
  'Jordan',
  'Lifestyle',
  'Giày trẻ em',
];

// Danh sách 13 sản phẩm
final List<Product> productList = [
  // 1. Jordan 1 Low Alt Kids
  Product(
    id: 1,
    productCode: 'AJ1LOWALT-K',
    name: 'Jordan 1 Low Alt Kids',
    slug: 'jordan-1-low-alt-kids',
    price: 1800000,
    description: 'Jordan 1 Low Alt được thiết kế dành cho trẻ em.',
    categories: ['Tất cả giày', 'Giày trẻ em', 'Jordan', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/AJ1LOWALT-K/white_side.jpg',
        topImage: 'assets/images/products/AJ1LOWALT-K/white_top.jpg',
        sizes: ['29', '30', '31', '32', '33', '34'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/AJ1LOWALT-K/black_side.jpg',
        topImage: 'assets/images/products/AJ1LOWALT-K/black_top.jpg',
        sizes: ['29', '30', '31', '32', '33', '34'],
      ),
      ProductColor(
        name: 'Đỏ',
        sideImage: 'assets/images/products/AJ1LOWALT-K/red_side.jpg',
        topImage: 'assets/images/products/AJ1LOWALT-K/red_top.jpg',
        sizes: ['29', '30', '31', '32', '33', '34'],
      ),
    ],
  ),

  // 2. Air Jordan 1 Mid Kids
  Product(
    id: 2,
    productCode: 'AJ1MID-K',
    name: 'Air Jordan 1 Mid Kids',
    slug: 'air-jordan-1-mid-kids',
    price: 2200000,
    description: 'Thiết kế Air Jordan 1 Mid cổ điển dành cho trẻ em.',
    categories: ['Tất cả giày', 'Giày trẻ em', 'Jordan', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/AJ1MID-K/white_side.jpg',
        topImage: 'assets/images/products/AJ1MID-K/white_top.jpg',
        sizes: ['28', '29', '30', '31', '32'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/AJ1MID-K/black_side.jpg',
        topImage: 'assets/images/products/AJ1MID-K/black_top.jpg',
        sizes: ['28', '29', '30', '31', '32'],
      ),
      ProductColor(
        name: 'Đỏ',
        sideImage: 'assets/images/products/AJ1MID-K/red_side.jpg',
        topImage: 'assets/images/products/AJ1MID-K/red_top.jpg',
        sizes: ['28', '29', '30', '31', '32'],
      ),
    ],
  ),

  // 3. Nike Air Force 1 '07
  Product(
    id: 3,
    productCode: 'NK-AF107-M',
    name: "Nike Air Force 1 '07",
    slug: 'nike-air-force-1-07',
    price: 2929000,
    description: 'Mẫu Nike Air Force 1 cổ điển với phong cách vượt thời gian.',
    categories: ['Tất cả giày', 'Giày nam', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-AF107-M/white_side.jpg',
        topImage: 'assets/images/products/NK-AF107-M/white_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-AF107-M/black_side.jpg',
        topImage: 'assets/images/products/NK-AF107-M/black_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Xám',
        sideImage: 'assets/images/products/NK-AF107-M/grey_side.jpg',
        topImage: 'assets/images/products/NK-AF107-M/grey_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
    ],
  ),

  // 4. Nike Air Force 1 '07 Essential
  Product(
    id: 4,
    productCode: 'NK-AF1ESS-W',
    name: "Nike Air Force 1 '07 Essential",
    slug: 'nike-air-force-1-07-essential',
    price: 2929000,
    description: 'Mẫu giày thể thao nữ thời trang, phù hợp sử dụng hằng ngày.',
    categories: ['Tất cả giày', 'Giày nữ', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-AF1ESS-W/white_side.jpg',
        topImage: 'assets/images/products/NK-AF1ESS-W/white_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-AF1ESS-W/black_side.jpg',
        topImage: 'assets/images/products/NK-AF1ESS-W/black_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Hồng',
        sideImage: 'assets/images/products/NK-AF1ESS-W/pink_side.jpg',
        topImage: 'assets/images/products/NK-AF1ESS-W/pink_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
    ],
  ),

  // 5. Nike Air Max 90
  Product(
    id: 5,
    productCode: 'NK-AM90-M',
    name: 'Nike Air Max 90',
    slug: 'nike-air-max-90',
    price: 3699000,
    description: 'Công nghệ đệm Air Max đặc trưng cùng thiết kế cổ điển.',
    categories: ['Tất cả giày', 'Giày nam', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-AM90-M/white_side.jpg',
        topImage: 'assets/images/products/NK-AM90-M/white_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-AM90-M/black_side.jpg',
        topImage: 'assets/images/products/NK-AM90-M/black_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Xám',
        sideImage: 'assets/images/products/NK-AM90-M/grey_side.jpg',
        topImage: 'assets/images/products/NK-AM90-M/grey_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
    ],
  ),

  // 6. Nike Air Max Muse
  Product(
    id: 6,
    productCode: 'NK-AMMUSE-W',
    name: 'Nike Air Max Muse',
    slug: 'nike-air-max-muse',
    price: 4199000,
    description: 'Thiết kế Air Max hiện đại, phù hợp sử dụng hằng ngày.',
    categories: ['Tất cả giày', 'Giày nữ', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-AMMUSE-W/white_side.jpg',
        topImage: 'assets/images/products/NK-AMMUSE-W/white_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-AMMUSE-W/black_side.jpg',
        topImage: 'assets/images/products/NK-AMMUSE-W/black_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Hồng',
        sideImage: 'assets/images/products/NK-AMMUSE-W/pink_side.jpg',
        topImage: 'assets/images/products/NK-AMMUSE-W/pink_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
    ],
  ),

  // 7. Nike Cortez SE
  Product(
    id: 7,
    productCode: 'NK-CORTEZSE-W',
    name: 'Nike Cortez SE',
    slug: 'nike-cortez-se',
    price: 2499000,
    description: 'Mẫu giày Nike mang cảm hứng thiết kế chạy bộ cổ điển.',
    categories: ['Tất cả giày', 'Giày nữ', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-CORTEZSE-W/white_side.jpg',
        topImage: 'assets/images/products/NK-CORTEZSE-W/white_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-CORTEZSE-W/black_side.jpg',
        topImage: 'assets/images/products/NK-CORTEZSE-W/black_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Hồng',
        sideImage: 'assets/images/products/NK-CORTEZSE-W/pink_side.jpg',
        topImage: 'assets/images/products/NK-CORTEZSE-W/pink_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
    ],
  ),

  // 8. Nike P-6000
  Product(
    id: 8,
    productCode: 'NK-P6000-M',
    name: 'Nike P-6000',
    slug: 'nike-p-6000',
    price: 2799000,
    description: 'Mẫu giày mang phong cách cổ điển với lớp đệm êm ái.',
    categories: ['Tất cả giày', 'Giày nam', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-P6000-M/white_side.jpg',
        topImage: 'assets/images/products/NK-P6000-M/white_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-P6000-M/black_side.jpg',
        topImage: 'assets/images/products/NK-P6000-M/black_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Xám',
        sideImage: 'assets/images/products/NK-P6000-M/grey_side.jpg',
        topImage: 'assets/images/products/NK-P6000-M/grey_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
    ],
  ),

  // 9. Nike Pegasus 42
  Product(
    id: 9,
    productCode: 'NK-PEG42-M',
    name: 'Nike Pegasus 42',
    slug: 'nike-pegasus-42',
    price: 3699000,
    description: 'Lớp đệm đàn hồi, phù hợp cho việc chạy bộ hằng ngày.',
    categories: ['Tất cả giày', 'Giày nam', 'Chạy bộ'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-PEG42-M/whte_side.jpg',
        topImage: 'assets/images/products/NK-PEG42-M/white_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-PEG42-M/black_side.jpg',
        topImage: 'assets/images/products/NK-PEG42-M/black_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Xanh Dương',
        sideImage: 'assets/images/products/NK-PEG42-M/blue_side.jpg',
        topImage: 'assets/images/products/NK-PEG42-M/blue_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
    ],
  ),

  // 10. Nike Shox NZ
  Product(
    id: 10,
    productCode: 'NK-SHOXNZ-M',
    name: 'Nike Shox NZ',
    slug: 'nike-shox-nz',
    price: 3299000,
    description: 'Công nghệ đệm Nike Shox nổi bật cùng thiết kế thể thao.',
    categories: ['Tất cả giày', 'Giày nam', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-SHOXNZ-M/white_side.jpg',
        topImage: 'assets/images/products/NK-SHOXNZ-M/white_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-SHOXNZ-M/black_side.jpg',
        topImage: 'assets/images/products/NK-SHOXNZ-M/black_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Xám',
        sideImage: 'assets/images/products/NK-SHOXNZ-M/grey_side.jpg',
        topImage: 'assets/images/products/NK-SHOXNZ-M/grey_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
    ],
  ),

  // 11. Nike V5 RNR Kids
  Product(
    id: 11,
    productCode: 'NK-V5RNR-K',
    name: 'Nike V5 RNR Kids',
    slug: 'nike-v5-rnr-kids',
    price: 1599000,
    description: 'Giày thể thao êm ái, phù hợp sử dụng hằng ngày cho trẻ em.',
    categories: ['Tất cả giày', 'Giày trẻ em', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-V5RNR-K/white_side.jpg',
        topImage: 'assets/images/products/NK-V5RNR-K/white_top.jpg',
        sizes: ['28', '29', '30', '31', '32', '33'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-V5RNR-K/black_side.jpg',
        topImage: 'assets/images/products/NK-V5RNR-K/black_top.jpg',
        sizes: ['28', '29', '30', '31', '32', '33'],
      ),
      ProductColor(
        name: 'Xanh Dương',
        sideImage: 'assets/images/products/NK-V5RNR-K/blue_side.jpg',
        topImage: 'assets/images/products/NK-V5RNR-K/blue_top.jpg',
        sizes: ['28', '29', '30', '31', '32', '33'],
      ),
    ],
  ),

  // 12. Nike V5 RNR Premium
  Product(
    id: 12,
    productCode: 'NK-V5RNRPRE-W',
    name: 'Nike V5 RNR Premium',
    slug: 'nike-v5-rnr-premium',
    price: 2299000,
    description: 'Giày thể thao cao cấp với thiết kế hiện đại, phù hợp sử dụng hằng ngày.',
    categories: ['Tất cả giày', 'Giày nữ', 'Phong cách thường ngày'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-V5RNRPRE-W/white_side.jpg',
        topImage: 'assets/images/products/NK-V5RNRPRE-W/white_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-V5RNRPRE-W/black_side.jpg',
        topImage: 'assets/images/products/NK-V5RNRPRE-W/black_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
      ProductColor(
        name: 'Hồng',
        sideImage: 'assets/images/products/NK-V5RNRPRE-W/pink_side.jpg',
        topImage: 'assets/images/products/NK-V5RNRPRE-W/pink_top.jpg',
        sizes: ['35', '36', '37', '38', '39'],
      ),
    ],
  ),

  // 13. Nike Vomero 18
  Product(
    id: 13,
    productCode: 'NK-VOM18-M',
    name: 'Nike Vomero 18',
    slug: 'nike-vomero-18',
    price: 4299000,
    description: 'Lớp đệm tối đa mang lại trải nghiệm chạy bộ thoải mái.',
    categories: ['Tất cả giày', 'Giày nam', 'Chạy bộ'],
    colors: [
      ProductColor(
        name: 'Trắng',
        sideImage: 'assets/images/products/NK-VOM18-M/white_side.jpg',
        topImage: 'assets/images/products/NK-VOM18-M/white_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Đen',
        sideImage: 'assets/images/products/NK-VOM18-M/black_side.jpg',
        topImage: 'assets/images/products/NK-VOM18-M/black_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
      ProductColor(
        name: 'Xanh Dương',
        sideImage: 'assets/images/products/NK-VOM18-M/blue_side.jpg',
        topImage: 'assets/images/products/NK-VOM18-M/blue_top.jpg',
        sizes: ['39', '40', '41', '42', '43', '44'],
      ),
    ],
  ),
];
