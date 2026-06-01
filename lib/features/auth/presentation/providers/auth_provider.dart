import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository});

  Future<void> recuperarContrasena(String email) async {
    try {
      await repository.recuperarContrasena(email);
    } catch (e) {
      rethrow;
    }
  }
}