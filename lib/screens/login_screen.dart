
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // =========================
  // XỬ LÝ ĐĂNG NHẬP
  // =========================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Firebase đã đăng nhập thành công.
      // Quay lại Account để hiển thị thông tin.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Đăng nhập thất bại';

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        message = 'Email hoặc mật khẩu không chính xác';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      } else if (e.code == 'too-many-requests') {
        message = 'Bạn thử quá nhiều lần. Hãy thử lại sau';
      } else if (e.code == 'network-request-failed') {
        message = 'Vui lòng kiểm tra kết nối Internet';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // GIAO DIỆN ĐĂNG NHẬP
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'KICKS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,

                children: [
                  // BIỂU TƯỢNG TÀI KHOẢN
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius:
                            BorderRadius.circular(45),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 48,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TIÊU ĐỀ
                  const Text(
                    'ĐĂNG NHẬP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Chào mừng bạn quay trở lại KICKS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // EMAIL
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,

                    decoration: _inputDecoration(
                      hint: 'Nhập email của bạn',
                      icon: Icons.email_outlined,
                    ),

                    validator: (value) {
                      if (value == null ||
                          !RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // MẬT KHẨU
                  const Text(
                    'Mật khẩu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) _login();
                    },

                    decoration: _inputDecoration(
                      hint: 'Nhập mật khẩu',
                      icon: Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // NÚT ĐĂNG NHẬP
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _login,

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
                          : const Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'KICKS - STEP INTO YOUR STYLE',
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

  // KIỂU Ô NHẬP LIỆU DÙNG CHUNG TRONG LOGIN
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
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
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
}
