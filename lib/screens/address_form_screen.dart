
import 'package:flutter/material.dart';

import '../Models/address.dart';
import '../services/address_service.dart';

class AddressFormScreen extends StatefulWidget {
  final ShippingAddress? address;

  const AddressFormScreen({
    super.key,
    this.address,
  });

  @override
  State<AddressFormScreen> createState() =>
      _AddressFormScreenState();
}

class _AddressFormScreenState
    extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _wardController;
  late final TextEditingController _provinceController;
  late final TextEditingController _noteController;

  bool _isDefault = false;
  bool _isLoading = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _nameController = TextEditingController(
      text: address?.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: address?.phoneNumber ?? '',
    );
    _streetController = TextEditingController(
      text: address?.streetAddress ?? '',
    );
    _wardController = TextEditingController(
      text: address?.ward ?? '',
    );
    _provinceController = TextEditingController(
      text: address?.province ?? '',
    );
    _noteController = TextEditingController(
      text: address?.note ?? '',
    );

    _isDefault = address?.isDefault ?? false;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final address = ShippingAddress(
        id: widget.address?.id ?? '',
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        streetAddress: _streetController.text.trim(),
        ward: _wardController.text.trim(),
        province: _provinceController.text.trim(),
        note: _noteController.text.trim(),
        isDefault: _isDefault,
        createdAt: widget.address?.createdAt,
      );

      if (_isEditing) {
        await _addressService.updateAddress(address);
      } else {
        await _addressService.addAddress(address);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể lưu địa chỉ. Vui lòng thử lại.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _provinceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.black54),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textInputAction: maxLines > 1
                ? TextInputAction.newline
                : TextInputAction.next,
            decoration: _inputDecoration(
              hint: hint,
              icon: icon,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập thông tin này';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFF3F3F3),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 44,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _isEditing
                        ? 'CHỈNH SỬA ĐỊA CHỈ'
                        : 'THÊM ĐỊA CHỈ MỚI',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Thông tin nhận hàng của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildField(
                    label: 'Họ và tên người nhận',
                    hint: 'Nhập họ và tên',
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: _requiredValidator,
                  ),

                  _buildField(
                    label: 'Số điện thoại',
                    hint: 'Nhập số điện thoại',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (!RegExp(
                        r'^\+?[0-9]{9,15}$',
                      ).hasMatch(phone)) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  _buildField(
                    label: 'Tỉnh / Thành phố',
                    hint: 'Nhập tỉnh hoặc thành phố',
                    icon: Icons.location_city_outlined,
                    controller: _provinceController,
                    validator: _requiredValidator,
                  ),

                  _buildField(
                    label: 'Phường / Xã',
                    hint: 'Nhập phường hoặc xã',
                    icon: Icons.map_outlined,
                    controller: _wardController,
                    validator: _requiredValidator,
                  ),

                  _buildField(
                    label: 'Địa chỉ cụ thể',
                    hint: 'Số nhà, tên đường, tòa nhà...',
                    icon: Icons.home_outlined,
                    controller: _streetController,
                    validator: _requiredValidator,
                  ),

                  _buildField(
                    label: 'Ghi chú (không bắt buộc)',
                    hint: 'Ví dụ: Giao hàng giờ hành chính',
                    icon: Icons.notes_outlined,
                    controller: _noteController,
                    maxLines: 3,
                  ),

                  // Đặt mặc định khi thêm địa chỉ mới.
                  // Khi chỉnh sửa, sử dụng nút đặt
                  // mặc định trên danh sách địa chỉ.
                  if (!_isEditing) ...[
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.black,
                      controlAffinity:
                          ListTileControlAffinity.leading,
                      title: const Text(
                        'Đặt làm địa chỉ mặc định',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'LƯU THAY ĐỔI'
                                  : 'LƯU ĐỊA CHỈ',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'HỦY',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
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
