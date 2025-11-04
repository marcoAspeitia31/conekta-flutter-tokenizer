/// Archivo de configuración para la aplicación
/// 
/// Puedes crear un archivo config.dart con tus credenciales
/// y luego importarlo en lugar de pedirlas al usuario.
/// 
/// IMPORTANTE: Nunca subas este archivo a un repositorio público
/// si contiene credenciales reales.

class AppConfig {
  // Clave pública de Conekta (obtenla desde https://panel.conekta.com)
  static const String conektaPublicKey = 'key_EonEUrFrtJ6DqUMrDPCrhfQ';

  // Configuración del backend (opcional)
  static const String? backendUrl = 'https://conekta-payments.local';
  static const String? backendUsername = 'equipoTISK';
  static const String? backendPassword = 'gO8oeXie8HDwj5K4';

  // Determina si usar la configuración hardcodeada o pedirla al usuario
  static const bool useHardcodedConfig = false;
}

