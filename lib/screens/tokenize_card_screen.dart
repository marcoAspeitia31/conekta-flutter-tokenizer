import 'package:flutter/material.dart';
import '../models/card_data.dart';
import '../services/conekta_token_service.dart';
import '../widgets/card_form_widget.dart';

/// Pantalla principal para tokenizar tarjetas
class TokenizeCardScreen extends StatefulWidget {
  final String publicKey;
  final String? backendUrl;
  final String? backendUsername;
  final String? backendPassword;

  const TokenizeCardScreen({
    super.key,
    required this.publicKey,
    this.backendUrl,
    this.backendUsername,
    this.backendPassword,
  });

  @override
  State<TokenizeCardScreen> createState() => _TokenizeCardScreenState();
}

class _TokenizeCardScreenState extends State<TokenizeCardScreen> {
  final _tokenService = ConektaTokenService(publicKey: '');
  bool _isLoading = false;
  String? _tokenId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tokenService.publicKey = widget.publicKey;
  }

  Future<void> _handleTokenize(CardData cardData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _tokenId = null;
    });

    try {
      // Crear el token usando Conekta
      final token = await _tokenService.createToken(cardData);

      setState(() {
        _tokenId = token.id;
        _isLoading = false;
      });

      // Si hay configuración de backend, enviar el token
      if (widget.backendUrl != null &&
          widget.backendUsername != null &&
          widget.backendPassword != null) {
        try {
          await _tokenService.sendTokenToBackend(
            tokenId: token.id,
            backendUrl: widget.backendUrl!,
            username: widget.backendUsername!,
            password: widget.backendPassword!,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Token creado y enviado al backend exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Token creado pero error al enviar al backend: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tokenizar Tarjeta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa los datos de la tarjeta para crear un token seguro. '
                      'Los datos nunca se almacenan en este dispositivo.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Formulario
            CardFormWidget(
              onSubmit: _handleTokenize,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // Mostrar token si se creó exitosamente
            if (_tokenId != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Token Creado Exitosamente',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _tokenId!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Copiar al portapapeles
                          Clipboard.setData(ClipboardData(text: _tokenId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Token copiado al portapapeles'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copiar Token'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Mostrar error si hubo
            if (_errorMessage != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

