/// Modelo de datos para la información de la tarjeta
class CardData {
  final String name;
  final String number;
  final String expMonth;
  final String expYear;
  final String cvc;

  CardData({
    required this.name,
    required this.number,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'exp_month': expMonth,
      'exp_year': expYear,
      'cvc': cvc,
    };
  }

  /// Valida que todos los campos estén completos
  bool isValid() {
    return name.isNotEmpty &&
        number.isNotEmpty &&
        expMonth.isNotEmpty &&
        expYear.isNotEmpty &&
        cvc.isNotEmpty;
  }

  /// Valida el formato del número de tarjeta (solo dígitos, 13-19 caracteres)
  bool isValidCardNumber() {
    final cleaned = number.replaceAll(RegExp(r'[\s-]'), '');
    return cleaned.length >= 13 && cleaned.length <= 19 && RegExp(r'^\d+$').hasMatch(cleaned);
  }

  /// Valida el formato del CVC (3-4 dígitos)
  bool isValidCvc() {
    return cvc.length >= 3 && cvc.length <= 4 && RegExp(r'^\d+$').hasMatch(cvc);
  }

  /// Valida el mes de expiración (01-12)
  bool isValidExpMonth() {
    final month = int.tryParse(expMonth);
    return month != null && month >= 1 && month <= 12;
  }

  /// Valida el año de expiración (año actual o futuro)
  bool isValidExpYear() {
    final year = int.tryParse(expYear);
    if (year == null) return false;
    final currentYear = DateTime.now().year;
    return year >= currentYear && year <= currentYear + 20;
  }
}

/// Modelo para la respuesta del token de Conekta
class ConektaToken {
  final String id;
  final bool livemode;
  final bool used;
  final CardInfo? card;

  ConektaToken({
    required this.id,
    required this.livemode,
    required this.used,
    this.card,
  });

  factory ConektaToken.fromJson(Map<String, dynamic> json) {
    return ConektaToken(
      id: json['id'] as String,
      livemode: json['livemode'] as bool? ?? false,
      used: json['used'] as bool? ?? false,
      card: json['card'] != null ? CardInfo.fromJson(json['card']) : null,
    );
  }
}

/// Información de la tarjeta tokenizada
class CardInfo {
  final String name;
  final String last4;
  final String brand;
  final String expMonth;
  final String expYear;

  CardInfo({
    required this.name,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      name: json['name'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      expMonth: json['exp_month']?.toString() ?? '',
      expYear: json['exp_year']?.toString() ?? '',
    );
  }
}

