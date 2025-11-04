import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_data.dart';

/// Servicio para crear tokens de Conekta
/// 
/// NOTA: Este servicio hace la petición directamente a la API de Conekta.
/// Para cumplir con PCI compliance, Conekta prefiere que uses su SDK JavaScript
/// en un WebView. Sin embargo, este método funciona para casos de uso específicos.
class ConektaTokenService {
  String publicKey;
  final String? baseUrl;

  ConektaTokenService({
    required this.publicKey,
    this.baseUrl,
  });

  /// Crea un token de tarjeta usando la API de Conekta
  /// 
  /// Retorna el token si es exitoso, o lanza una excepción si hay error
  Future<ConektaToken> createToken(CardData cardData) async {
    // Validar datos de la tarjeta
    if (!cardData.isValid()) {
      throw Exception('Todos los campos de la tarjeta son requeridos');
    }

    if (!cardData.isValidCardNumber()) {
      throw Exception('Número de tarjeta inválido');
    }

    if (!cardData.isValidCvc()) {
      throw Exception('CVC inválido');
    }

    if (!cardData.isValidExpMonth()) {
      throw Exception('Mes de expiración inválido (debe ser 01-12)');
    }

    if (!cardData.isValidExpYear()) {
      throw Exception('Año de expiración inválido');
    }

    try {
      final url = Uri.parse('https://api.conekta.io/tokens');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.conekta-v2.1.0+json',
          'Authorization': 'Bearer $publicKey',
        },
        body: jsonEncode({
          'card': cardData.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ConektaToken.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? 
                           errorData['details']?[0]?['message'] ?? 
                           'Error al crear el token';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Envía el token al backend para registrarlo
  Future<Map<String, dynamic>> sendTokenToBackend({
    required String tokenId,
    required String backendUrl,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$backendUrl/Api/V1/tokens');
      
      // Crear credenciales Basic Auth
      final credentials = base64Encode(utf8.encode('$username:$password'));
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
        body: jsonEncode({
          'token_id': tokenId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? 'Error al enviar token al backend');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

