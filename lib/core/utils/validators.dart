class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'El correo ingresado no es válido';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es obligatorio';
    }

    final phoneRegex = RegExp(r'^\d{9}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'El teléfono debe tener 9 dígitos';
    }

    return null;
  }

  static String? futureDate(DateTime? date) {
    if (date == null) {
      return 'Por favor selecciona la fecha de tu evento';
    }

    final today = DateTime.now();

    if (!date.isAfter(today)) {
      return 'La fecha debe ser futura';
    }

    final maxDate = DateTime(today.year + 1, today.month, today.day);

    if (date.isAfter(maxDate)) {
      return 'La fecha no puede superar los 12 meses';
    }

    return null;
  }
}