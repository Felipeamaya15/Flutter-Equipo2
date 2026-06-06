import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthDatasource({
    required this.firebaseAuth,
  });

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
  // Método para enviar el correo de recuperación de contraseña
  Future<void> recuperarContrasena(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'El correo electrónico no está registrado.';
      } else if (e.code == 'invalid-email') {
        throw 'El formato del correo electrónico es incorrecto.';
      }
      throw 'Error de autenticación: ${e.message}';
    } catch (e) {
      throw 'Ocurrió un error inesperado al procesar la solicitud.';
    }
  }

  //Método para cambiar la contraseña del usuario con sesión activa
  Future<void> cambiarContrasena(String nuevaContrasena) async {
    final User? user = firebaseAuth.currentUser;

    if (user == null) {
      throw 'No se detectó ninguna sesión activa de trabajador.';
    }

    try {
      await user.updatePassword(nuevaContrasena.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Por motivos de seguridad, debes cerrar sesión e iniciar de nuevo para cambiar tu clave.';
      } else if (e.code == 'weak-password') {
        throw 'La contraseña ingresada es muy débil. Intenta con otra.';
      }
      throw 'Error al actualizar: ${e.message}';
    } catch (e) {
      throw 'Ocurrió un error inesperado al procesar el cambio de contraseña.';
    }
  }
}