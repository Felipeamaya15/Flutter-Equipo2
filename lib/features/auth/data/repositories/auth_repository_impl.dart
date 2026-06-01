import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;

  AuthRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await datasource.signIn(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user == null) {
      throw Exception('No se pudo iniciar sesión');
    }

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await datasource.register(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user == null) {
      throw Exception('No se pudo registrar el usuario');
    }

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  @override
  Future<void> signOut() {
    return datasource.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final user = datasource.getCurrentUser();

    if (user == null) return null;

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  @override
  Future<void> recuperarContrasena(String email) async {
    try {
      await datasource.recuperarContrasena(email);
    } catch (e) {
      rethrow;
    }
  }
}