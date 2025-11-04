import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/tokenize_card_screen.dart';
// import 'utils/config.dart'; // Descomenta si quieres usar configuración hardcodeada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conekta Tokenizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConfigurationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Pantalla de configuración inicial
class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _publicKeyController = TextEditingController();
  final _backendUrlController = TextEditingController();
  final _backendUserController = TextEditingController();
  final _backendPassController = TextEditingController();
  bool _saveCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPublicKey = prefs.getString('conekta_public_key');
    final savedBackendUrl = prefs.getString('backend_url');
    final savedBackendUser = prefs.getString('backend_user');

    if (savedPublicKey != null) {
      _publicKeyController.text = savedPublicKey;
    }
    if (savedBackendUrl != null) {
      _backendUrlController.text = savedBackendUrl;
    }
    if (savedBackendUser != null) {
      _backendUserController.text = savedBackendUser;
    }
  }

  Future<void> _saveCredentials() async {
    if (_saveCredentials) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('conekta_public_key', _publicKeyController.text);
      await prefs.setString('backend_url', _backendUrlController.text);
      await prefs.setString('backend_user', _backendUserController.text);
      // Nota: No guardamos la contraseña por seguridad
    }
  }

  void _navigateToTokenizer() {
    if (_publicKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa la clave pública de Conekta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _saveCredentials();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TokenizeCardScreen(
          publicKey: _publicKeyController.text.trim(),
          backendUrl: _backendUrlController.text.trim().isEmpty
              ? null
              : _backendUrlController.text.trim(),
          backendUsername: _backendUserController.text.trim().isEmpty
              ? null
              : _backendUserController.text.trim(),
          backendPassword: _backendPassController.text.trim().isEmpty
              ? null
              : _backendPassController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración de Conekta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _publicKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Clave Pública de Conekta *',
                        hintText: 'key_...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración del Backend (Opcional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Si configuras el backend, el token se enviará automáticamente después de crearlo.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _backendUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL del Backend',
                        hintText: 'https://conekta-payments.local',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _backendUserController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario (Basic Auth)',
                        hintText: 'equipoTISK',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _backendPassController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña (Basic Auth)',
                        hintText: '••••••••',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Guardar credenciales'),
              value: _saveCredentials,
              onChanged: (value) {
                setState(() {
                  _saveCredentials = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _navigateToTokenizer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continuar a Tokenización',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _backendUrlController.dispose();
    _backendUserController.dispose();
    _backendPassController.dispose();
    super.dispose();
  }
}

