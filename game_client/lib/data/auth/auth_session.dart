/// In-memory auth session.
///
/// Holds the JWT returned by the server after sign in/up. The token is kept
/// only in memory for now — persist with shared_preferences when the app
/// needs to survive restarts.
class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  String? _token;

  String? get token => _token;
  bool get isLogged => _token != null;

  void saveToken(String token) {
    _token = token;
  }

  void clear() {
    _token = null;
  }
}
