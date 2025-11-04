import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/card_data.dart';

/// Servicio para tokenizar tarjetas usando WebView con el SDK de JavaScript de Conekta
/// 
/// Esta es la forma recomendada por Conekta para cumplir con PCI compliance
class ConektaWebViewService {
  final String publicKey;

  ConektaWebViewService({required this.publicKey});

  /// Genera el HTML con el SDK de Conekta para tokenizar
  String _generateTokenizationHTML(CardData cardData) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Conekta Tokenizer</title>
    <script type="text/javascript" src="https://cdn.conekta.io/js/latest/conekta.js"></script>
</head>
<body>
    <script>
        // Configurar la clave pública
        Conekta.setPublicKey('$publicKey');
        
        // Datos de la tarjeta
        const cardData = {
            card: {
                name: "${cardData.name}",
                number: "${cardData.number.replaceAll(RegExp(r'[\s-]'), '')}",
                exp_month: "${cardData.expMonth}",
                exp_year: "${cardData.expYear}",
                cvc: "${cardData.cvc}"
            }
        };
        
        // Crear el token
        Conekta.Token.create(cardData, 
            function success(token) {
                // Enviar el token exitoso al Flutter
                window.flutter_inappwebview.callHandler('onTokenSuccess', {
                    id: token.id,
                    livemode: token.livemode,
                    used: token.used,
                    card: token.card
                });
            },
            function error(error) {
                // Enviar el error al Flutter
                window.flutter_inappwebview.callHandler('onTokenError', {
                    message: error.message_to_purchaser || error.message,
                    code: error.code,
                    details: error
                });
            }
        );
    </script>
</body>
</html>
''';
  }

  /// Crea un WebView para tokenizar la tarjeta
  /// 
  /// Retorna el widget WebView configurado
  Widget createTokenizationWebView({
    required CardData cardData,
    required Function(ConektaToken) onSuccess,
    required Function(String) onError,
  }) {
    final htmlContent = _generateTokenizationHTML(cardData);
    final base64Content = base64Encode(utf8.encode(htmlContent));

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadRequest(
        Uri.dataFromString(
          htmlContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      )
      ..addJavaScriptChannel(
        'TokenChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            
            if (data['type'] == 'success') {
              final token = ConektaToken.fromJson(data['token']);
              onSuccess(token);
            } else if (data['type'] == 'error') {
              onError(data['message'] ?? 'Error desconocido');
            }
          } catch (e) {
            onError('Error al procesar la respuesta: $e');
          }
        },
      );

    return WebViewWidget(controller: controller);
  }

  /// Método alternativo usando JavaScript para comunicarse con Flutter
  /// 
  /// Este método inyecta JavaScript para interceptar las llamadas de Conekta
  Future<ConektaToken?> tokenizeWithWebView(
    CardData cardData,
    BuildContext context,
  ) async {
    return showDialog<ConektaToken>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Tokenizando tarjeta...'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

