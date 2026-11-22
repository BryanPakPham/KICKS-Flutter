
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy tài khoản đang đăng nhập
  User? get currentUser => _auth.currentUser;

  // Theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // Đăng ký tài khoản mới
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    return credential;
  }

  // Đăng nhập
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ĐỔI MẬT KHẨU FIREBASE
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw StateError('Người dùng chưa đăng nhập bằng email');
    }

    // Xác thực lại bằng mật khẩu hiện tại
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // Cập nhật mật khẩu mới trên Firebase
    await user.updatePassword(newPassword);
  }

}
