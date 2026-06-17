import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  // Variable para mostrar el estado de carga al cambiar clave
  bool _isUpdatingPassword = false;
  bool get isUpdatingPassword => _isUpdatingPassword;

  AuthProvider({required this.repository});

  Future<void> recuperarContrasena(String email) async {
    try {
      await repository.recuperarContrasena(email);
    } catch (e) {
      rethrow;
    }
  }

  // AQUÍ ESTÁ EL MÉTODO QUE VS CODE ESTÁ BUSCANDO
  Future<void> actualizarContrasenaTrabajador(String nuevaClave) async {
    if (nuevaClave.trim().length < 6) {
      throw 'La nueva contraseña debe tener al menos 6 caracteres.';
    }

    _isUpdatingPassword = true;
    notifyListeners();

    try {
      await repository.cambiarContrasena(nuevaClave);
    } catch (e) {
      rethrow; 
    } finally {
      _isUpdatingPassword = false;
      notifyListeners();
    }
  }
}