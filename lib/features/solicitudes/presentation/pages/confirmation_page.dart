import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  final String folio;
  final String email;

  const ConfirmationPage({super.key, required this.folio, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 120,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Solicitud Enviada con Éxito!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4A4B22)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Folio de seguimiento: #$folio',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black), 
              ),
              const SizedBox(height: 8),
              Text(
                'Hemos enviado un desglose estimativo al correo:\n$email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Descargando comprobante en PDF...')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Descargar Resumen PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A4B22), 
                  side: const BorderSide(color: Color(0xFF4A4B22)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/', 
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4B22),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}