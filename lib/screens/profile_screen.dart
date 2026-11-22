import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../Models/user_profile.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _userService.getOrCreateProfile();
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
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Không thể tải hồ sơ. '
                  'Vui lòng kiểm tra kết nối hoặc quyền Firestore.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFFF3F3F3),
                        child: Icon(
                          Icons.person_outline,
                          size: 48,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'THÔNG TIN CÁ NHÂN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Thông tin tài khoản KICKS của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _infoField(
                      label: 'Họ và tên',
                      value: profile.fullName.isEmpty
                          ? 'Chưa cập nhật'
                          : profile.fullName,
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    _infoField(
                      label: 'Email',
                      value: profile.email,
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 18),

                    _infoField(
                      label: 'Số điện thoại',
                      value: profile.phoneNumber.isEmpty
                          ? 'Chưa cập nhật'
                          : profile.phoneNumber,
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 30),

                    // NÚT CHỈNH SỬA THÔNG TIN
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                profile: profile,
                              ),
                            ),
                          );

                          if (!context.mounted) return;

                          // Nếu lưu thành công, tải lại dữ liệu Firestore
                          if (updated == true) {
                            setState(() {
                              _profileFuture =
                                  _userService.getOrCreateProfile();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cập nhật thông tin thành công!',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        label: const Text(
                          'CHỈNH SỬA THÔNG TIN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
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

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
