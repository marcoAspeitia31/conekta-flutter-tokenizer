# Conekta Flutter Tokenizer

Aplicación Flutter para tokenizar tarjetas de crédito usando Conekta.

## Características

- ✅ Tokenización de tarjetas usando la API de Conekta
- ✅ Validación completa de datos de tarjeta
- ✅ Integración opcional con backend para registrar tokens
- ✅ Interfaz de usuario intuitiva y moderna
- ✅ Soporte para guardar credenciales (opcional)

## Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Clave pública de Conekta (Public Key)

## Instalación

1. Clona el repositorio o navega al directorio del proyecto:
```bash
cd conekta-flutter-tokenizer
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## Configuración

### Clave Pública de Conekta

Necesitas obtener tu clave pública de Conekta desde el [Panel de Conekta](https://panel.conekta.com).

### Configuración del Backend (Opcional)

Si deseas que los tokens se envíen automáticamente a tu backend después de crearlos, configura:

- **URL del Backend**: La URL base de tu API (ej: `https://conekta-payments.local`)
- **Usuario**: Usuario para autenticación Basic Auth
- **Contraseña**: Contraseña para autenticación Basic Auth

## Uso

1. **Pantalla de Configuración**: Al iniciar la app, ingresa tu clave pública de Conekta y opcionalmente las credenciales del backend.

2. **Pantalla de Tokenización**: 
   - Ingresa los datos de la tarjeta:
     - Nombre del titular
     - Número de tarjeta
     - Mes y año de expiración
     - CVC
   - Presiona "Tokenizar Tarjeta"
   - El token se creará y se mostrará en pantalla
   - Si configuraste el backend, el token se enviará automáticamente

3. **Copiar Token**: Puedes copiar el token al portapapeles usando el botón "Copiar Token"

## Tarjetas de Prueba

Para pruebas, puedes usar estas tarjetas de prueba de Conekta:

- **Tarjeta exitosa**: `4242424242424242`
- **Tarjeta rechazada**: `4000000000000002`
- **Fondos insuficientes**: `4000000000009995`

Para todas las tarjetas de prueba:
- **Exp Month**: `12`
- **Exp Year**: Año futuro (ej: `2025`)
- **CVC**: Cualquier 3 dígitos (ej: `123`)

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/
│   └── card_data.dart          # Modelos de datos (CardData, ConektaToken)
├── services/
│   ├── conekta_token_service.dart    # Servicio para crear tokens
│   └── conekta_webview_service.dart  # Servicio alternativo con WebView
├── screens/
│   └── tokenize_card_screen.dart      # Pantalla principal de tokenización
└── widgets/
    └── card_form_widget.dart         # Widget del formulario de tarjeta
```

## Integración con Backend

El servicio `ConektaTokenService` incluye el método `sendTokenToBackend()` que envía el token a tu backend usando Basic Auth.

### Ejemplo de uso en código:

```dart
final tokenService = ConektaTokenService(publicKey: 'tu_clave_publica');

// Crear token
final token = await tokenService.createToken(cardData);

// Enviar al backend
await tokenService.sendTokenToBackend(
  tokenId: token.id,
  backendUrl: 'https://conekta-payments.local',
  username: 'equipoTISK',
  password: 'gO8oeXie8HDwj5K4',
);
```

## Notas Importantes

⚠️ **PCI Compliance**: 
- Los tokens se crean directamente desde la app usando la API de Conekta
- Los datos de la tarjeta nunca pasan por tu servidor
- Conekta maneja toda la seguridad y cumplimiento PCI

⚠️ **Seguridad**:
- Nunca almacenes la clave privada (Secret Key) en la app móvil
- Solo usa la clave pública (Public Key) en el frontend
- La contraseña del backend no se guarda automáticamente por seguridad

## Dependencias

- `http`: Para hacer peticiones HTTP a la API de Conekta
- `webview_flutter`: Para implementación alternativa con WebView (opcional)
- `shared_preferences`: Para guardar credenciales (opcional)

## Licencia

Este proyecto es para uso interno.

## Soporte

Para más información sobre la API de Conekta, consulta la [documentación oficial](https://developers.conekta.com/).

