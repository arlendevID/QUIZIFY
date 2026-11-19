class AuthSession {
  AuthSession._();

  static String? token;
  static String? role;
  static Map<String, dynamic>? user;

  static bool get isAuthenticated => token != null && token!.isNotEmpty;

  static bool get isAdmin => role == 'admin';

  static void save({
    required String? authToken,
    required Map<String, dynamic> authUser,
  }) {
    clear();

    final normalizedToken = authToken?.trim();
    token = normalizedToken == null || normalizedToken.isEmpty
        ? null
        : normalizedToken;
    user = Map<String, dynamic>.from(authUser);
    role = user?['role']?.toString().trim().toLowerCase();
  }

  static void clear() {
    token = null;
    role = null;
    user = null;
  }
}
