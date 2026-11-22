
import 'package:flutter/material.dart';

import '../Models/address.dart';
import '../services/address_service.dart';
import 'address_form_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final AddressService _addressService = AddressService();

  late final Stream<List<ShippingAddress>> _addressesStream;

  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _addressesStream = _addressService.watchAddresses();
  }

  // ==========================================
  // 1. MỞ MÀN HÌNH THÊM / CHỈNH SỬA ĐỊA CHỈ
  // ==========================================
  Future<void> _openAddressForm({
    ShippingAddress? address,
  }) async {
    if (_isBusy) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(
          address: address,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _showMessage(
        address == null
            ? 'Thêm địa chỉ thành công!'
            : 'Cập nhật địa chỉ thành công!',
      );
    }
  }

  // ==========================================
  // 2. ĐẶT ĐỊA CHỈ MẶC ĐỊNH
  // ==========================================
  Future<void> _setDefaultAddress(
    ShippingAddress address,
  ) async {
    if (_isBusy || address.isDefault) return;

    setState(() => _isBusy = true);

    try {
      await _addressService.setDefaultAddress(address.id);

      if (!mounted) return;

      _showMessage('Đã cập nhật địa chỉ mặc định!');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Không thể đặt địa chỉ mặc định.',
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  // ==========================================
  // 3. XÓA ĐỊA CHỈ
  // ==========================================
  Future<void> _deleteAddress(
    ShippingAddress address,
  ) async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'XÓA ĐỊA CHỈ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa địa chỉ '
            'giao hàng này không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'HỦY',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('XÓA'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true || _isBusy) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      await _addressService.deleteAddress(address.id);

      if (!mounted) return;

      _showMessage('Đã xóa địa chỉ thành công!');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Không thể xóa địa chỉ. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  // ==========================================
  // 4. THÔNG BÁO
  // ==========================================
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
      ),
    );
  }

  // ==========================================
  // 5. GIAO DIỆN THẺ ĐỊA CHỈ
  // ==========================================
  Widget _buildAddressCard(ShippingAddress address) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? Colors.black
              : const Color(0xFFE0E0E0),
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÊN NGƯỜI NHẬN VÀ NHÃN MẶC ĐỊNH
          Row(
            children: [
              Expanded(
                child: Text(
                  address.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MẶC ĐỊNH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // SỐ ĐIỆN THOẠI
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  address.phoneNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ĐỊA CHỈ GIAO HÀNG
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${address.streetAddress}, '
                  '${address.ward}, '
                  '${address.province}',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          // GHI CHÚ
          if (address.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_outlined,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    address.note,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          const Divider(
            color: Color(0xFFEEEEEE),
          ),

          // CÁC NÚT THAO TÁC
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _isBusy
                    ? null
                    : () => _openAddressForm(
                          address: address,
                        ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                ),
                label: const Text('Chỉnh sửa'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),

              TextButton.icon(
                onPressed: _isBusy
                    ? null
                    : () => _deleteAddress(address),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 17,
                ),
                label: const Text('Xóa'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                ),
              ),

              if (!address.isDefault)
                TextButton(
                  onPressed: _isBusy
                      ? null
                      : () => _setDefaultAddress(address),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Đặt mặc định',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. GIAO DIỆN CHƯA CÓ ĐỊA CHỈ
  // ==========================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFF3F3F3),
              child: Icon(
                Icons.location_off_outlined,
                size: 42,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'CHƯA CÓ ĐỊA CHỈ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Hãy thêm địa chỉ giao hàng đầu tiên '
              'để thuận tiện khi mua sắm tại KICKS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 7. GIAO DIỆN CHÍNH
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'KICKS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                const Text(
                  'ĐỊA CHỈ CỦA TÔI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Quản lý địa chỉ giao hàng của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 26),

                // NÚT THÊM ĐỊA CHỈ
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () => _openAddressForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                    ),
                    label: const Text(
                      'THÊM ĐỊA CHỈ MỚI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // DANH SÁCH ĐỊA CHỈ FIRESTORE
                Expanded(
                  child: StreamBuilder<List<ShippingAddress>>(
                    stream: _addressesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Không thể tải danh sách địa chỉ.\n'
                            'Vui lòng kiểm tra kết nối Firebase.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final addresses =
                          snapshot.data ?? [];

                      if (addresses.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),
                        itemCount: addresses.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildAddressCard(
                            addresses[index],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
