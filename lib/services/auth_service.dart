import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // تسجيل الدخول
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // جلب الـ Role من جدول profiles الذي أنشأناه
        final userData = await supabase
            .from('profiles')
            .select('role')
            .eq('id', response.user!.id)
            .single();

        return userData['role']; // سيعود بـ student أو professor
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
