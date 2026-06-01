import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'El correo ingresado no es válido (usuario@dominio.com)';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);

      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        
        String mensajeError = 'Ocurrió un problem al intentar iniciar sesión.';
        if (e.code == 'user-not-found') {
          mensajeError = 'No existe ninguna cuenta registrada con este correo.';
        } else if (e.code == 'wrong-password') {
          mensajeError = 'La contraseña ingresada es incorrecta.';
        } else if (e.code == 'invalid-credential') {
          mensajeError = 'Credenciales no válidas. Revisa tu correo y contraseña.';
        } else if (e.code == 'network-request-failed') {
          mensajeError = 'Error de red. Verifica tu conexión a internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red.shade800,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showForgotPasswordDialog() {
    final dialogEmailController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Restablecer Contraseña',
                style: TextStyle(color: Color(0xFF4A4B22), fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ingresa tu correo institucional registrado y te enviaremos las instrucciones de recuperación.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: dialogEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      enabled: !isDialogLoading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4B22),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          if (dialogFormKey.currentState!.validate()) {
                            setDialogState(() => isDialogLoading = true);
                            try {
                              final String emailCapturado = dialogEmailController.text.trim();

                              await Provider.of<AuthProvider>(context, listen: false)
                                  .recuperarContrasena(emailCapturado);

                              if (!context.mounted) return;
                              
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enlace enviado. Revisa tu bandeja de entrada.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              String errorMsg = 'Error al procesar la solicitud de recuperación.';
                              if (e.code == 'user-not-found') {
                                errorMsg = 'No se encontró una cuenta institucional con este correo.';
                              } else if (e.code == 'invalid-email') {
                                errorMsg = 'El formato del correo es inválido.';
                              } else if (e.code == 'network-request-failed') {
                                errorMsg = 'Error de conexión. Revisa tu red de datos móvil.';
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg), 
                                  backgroundColor: Colors.red.shade800,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error inesperado: ${e.toString()}'), 
                                  backgroundColor: Colors.red.shade800,
                                ),
                              );
                            } finally {
                              if (context.mounted) {
                                setDialogState(() => isDialogLoading = false);
                              }
                            }
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person_outlined, size: 80, color: Color(0xFF4A4B22)),
                  const SizedBox(height: 16),
                  const Text(
                    'Acceso Trabajadores',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A4B22)),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'La contraseña es obligatoria' : null,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _showForgotPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color(0xFF4A4B22),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4B22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}