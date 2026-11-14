import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../l10n.dart';

/// كل عمليات تسجيل الدخول في مكان واحد.
/// كل دالة بترجع null لو نجحت، أو رسالة الخطأ (بلغة التطبيق) لو فشلت.
class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get user => _auth.currentUser;


  static Future<String?> signIn(String email, String password) =>
      _run(() => _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password));

  static Future<String?> register(String email, String password) =>
      _run(() => _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password));
  static const _webClientId = '540108580634-27253vho69bgv1t38rcdbaevbcpfpvlh.apps.googleusercontent.com';
  static bool _gInit = false;

  static Future<String?> google() {
    return _run(() async {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
        return;
      }
      final gs = GoogleSignIn.instance;
      if (!_gInit) {
        await gs.initialize(serverClientId: _webClientId);
        _gInit = true;
      }
      final account = await gs.authenticate();
      final idToken = account.authentication.idToken;
      await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken));
    });
  }
  static Future<String?> resetPassword(String email) =>
      _run(() => _auth.sendPasswordResetEmail(email: email.trim()));

  static Future<void> signOut() => _auth.signOut();
  static Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return tr('تم إلغاء تسجيل الدخول', 'Sign-in was cancelled.');
      }
      return tr('تعذّر الدخول بجوجل (${e.code.name})',
          'Google sign-in failed (${e.code.name}).');
    } catch (e) {
      debugPrint('Auth error: $e');
      return tr('حدث خطأ غير متوقع، حاول مرة أخرى',
          'Something went wrong. Please try again.');
    }
  }

  static String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return tr('البريد الإلكتروني غير صحيح', 'That email address looks invalid.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return tr('البريد أو كلمة المرور غير صحيحة',
            'Incorrect email or password.');
      case 'email-already-in-use':
        return tr('هذا البريد مسجّل بالفعل، جرّب تسجيل الدخول',
            'This email already has an account. Try logging in.');
      case 'weak-password':
        return tr('كلمة المرور ضعيفة (6 أحرف على الأقل)',
            'Password is too weak (at least 6 characters).');
      case 'network-request-failed':
        return tr('تحقق من اتصالك بالإنترنت', 'Check your internet connection.');
      case 'too-many-requests':
        return tr('محاولات كثيرة، حاول لاحقاً', 'Too many attempts. Try again later.');
      case 'popup-closed-by-user':
      case 'canceled':
      case 'cancelled-popup-request':
        return tr('تم إلغاء تسجيل الدخول', 'Sign-in was cancelled.');
      default:
        return tr('تعذّر إكمال العملية ($code)', 'Could not complete this ($code).');
    }
  }
}