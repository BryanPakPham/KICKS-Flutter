
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _currentPasswordController =
      TextEditingController();
  final _newPasswordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  // ==========================================
  // 1. XỬ LÝ ĐỔI MẬT KHẨU
  // ==========================================

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.changePassword(
        currentPassword:
            _currentPasswordController.text,
        newPassword:
            _newPasswordController.text,
      );

      if (!mounted) return;

      // Trả kết quả thành công cho Account
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Không thể đổi mật khẩu';

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Mật khẩu hiện tại không chính xác';
          break;

        case 'weak-password':
          message = 'Mật khẩu mới chưa đủ mạnh';
          break;

        case 'requires-recent-login':
          message =
              'Phiên xác thực đã hết hạn. '
              'Vui lòng đăng nhập lại';
          break;

        case 'too-many-requests':
          message =
              'Thao tác quá nhiều lần. '
              'Vui lòng thử lại sau';
          break;

        case 'network-request-failed':
          message =
              'Vui lòng kiểm tra kết nối Internet';
          break;

        default:
          message =
              'Không thể đổi mật khẩu. Vui lòng thử lại';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Có lỗi xảy ra. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // 2. HIỂN THỊ THÔNG BÁO
  // ==========================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // 3. STYLE Ô NHẬP
  // ==========================================

  InputDecoration _inputDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      prefixIcon: const Icon(
        Icons.lock_outline,
        color: Colors.black54,
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.black54,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding:
          const EdgeInsets.symmetric(
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

  // ==========================================
  // 4. GIẢI PHÓNG CONTROLLERS
  // ==========================================

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================
  // 5. GIAO DIỆN CHÍNH
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
            color: Colors.black,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 380,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // BIỂU TƯỢNG BẢO MẬT
                  const Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor:
                          Color(0xFFF3F3F3),
                      child: Icon(
                        Icons.lock_reset_outlined,
                        size: 48,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'ĐỔI MẬT KHẨU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Cập nhật mật khẩu để bảo vệ '
                    'tài khoản KICKS của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ==============================
                  // MẬT KHẨU HIỆN TẠI
                  // ==============================

                  const Text(
                    'Mật khẩu hiện tại',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        _currentPasswordController,
                    obscureText: _hideCurrentPassword,
                    textInputAction:
                        TextInputAction.next,
                    decoration: _inputDecoration(
                      hint: 'Nhập mật khẩu hiện tại',
                      obscure: _hideCurrentPassword,
                      onToggle: () {
                        setState(() {
                          _hideCurrentPassword =
                              !_hideCurrentPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu hiện tại';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // ==============================
                  // MẬT KHẨU MỚI
                  // ==============================

                  const Text(
                    'Mật khẩu mới',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _hideNewPassword,
                    textInputAction:
                        TextInputAction.next,
                    decoration: _inputDecoration(
                      hint: 'Nhập mật khẩu mới',
                      obscure: _hideNewPassword,
                      onToggle: () {
                        setState(() {
                          _hideNewPassword =
                              !_hideNewPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }

                      if (value ==
                          _currentPasswordController.text) {
                        return 'Mật khẩu mới phải khác mật khẩu cũ';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // ==============================
                  // XÁC NHẬN MẬT KHẨU
                  // ==============================

                  const Text(
                    'Xác nhận mật khẩu mới',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        _confirmPasswordController,
                    obscureText: _hideConfirmPassword,
                    textInputAction:
                        TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) {
                        _changePassword();
                      }
                    },
                    decoration: _inputDecoration(
                      hint: 'Nhập lại mật khẩu mới',
                      obscure: _hideConfirmPassword,
                      onToggle: () {
                        setState(() {
                          _hideConfirmPassword =
                              !_hideConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }

                      if (value !=
                          _newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // ==============================
                  // NÚT XÁC NHẬN
                  // ==============================

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _changePassword,
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
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'XÁC NHẬN ĐỔI MẬT KHẨU',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // NÚT HỦY
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

                  const SizedBox(height: 22),

                  const Text(
                    'KICKS - TỰ TIN THỂ HIỆN PHONG CÁCH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: Colors.grey,
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
