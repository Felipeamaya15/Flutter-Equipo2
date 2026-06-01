import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  AppUser? getCurrentUser();

  Future<void> recuperarContrasena(String email);
}