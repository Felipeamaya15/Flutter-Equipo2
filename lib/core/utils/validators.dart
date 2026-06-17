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

  static String? rut(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El RUT es obligatorio para la facturación';
    }
    
    String cleanRut = value.trim().replaceAll('.', '').replaceAll('-', '').toUpperCase();

    if (cleanRut.length < 8 || cleanRut.length > 9) {
      return 'El RUT ingresado no tiene un largo válido';
    }

    String dvIngresado = cleanRut.substring(cleanRut.length - 1);
    String cuerpoStr = cleanRut.substring(0, cleanRut.length - 1);

    int? cuerpo = int.tryParse(cuerpoStr);
    if (cuerpo == null) {
      return 'El cuerpo del RUT debe contener solo números';
    }

    int suma = 0;
    int multiplicador = 2;

    for (int i = cuerpoStr.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpoStr[i]) * multiplicador;
      multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
    }

    int resto = suma % 11;
    int resultadoDv = 11 - resto;

    String dvEsperado;
    if (resultadoDv == 11) {
      dvEsperado = '0';
    } else if (resultadoDv == 10) {
      dvEsperado = 'K';
    } else {
      dvEsperado = resultadoDv.toString();
    }

    if (dvIngresado != dvEsperado) {
      return 'El RUT ingresado es inválido (Dígito verificador incorrecto)';
    }

    return null;
  }
}