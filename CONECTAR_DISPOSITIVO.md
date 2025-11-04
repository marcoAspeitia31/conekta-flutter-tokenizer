# Guía para Conectar Dispositivo Físico Android

## Opción 1: Conectar desde Windows (Recomendado para WSL2)

Como estás en WSL2, la forma más fácil es conectar el dispositivo desde Windows y luego conectarlo vía TCP/IP.

### Pasos:

1. **Instala ADB en Windows (si no lo tienes):**
   
   Tienes dos opciones:
   
   **Opción A: Instalar Android SDK Platform Tools (Recomendado)**
   
   - Descarga desde: https://developer.android.com/tools/releases/platform-tools
   - Extrae el archivo ZIP (por ejemplo, a `C:\platform-tools`)
   - Agrega la ruta al PATH de Windows:
     - Busca "Variables de entorno" en Windows
     - Edita la variable `Path` del usuario
     - Agrega la ruta donde extrajiste (ej: `C:\platform-tools`)
   - Reinicia PowerShell o CMD
   
   **Opción B: Instalar usando Chocolatey (si lo tienes instalado)**
   ```powershell
   choco install adb
   ```
   
   **Opción C: Instalar usando winget (Windows 10/11)**
   ```powershell
   winget install Google.PlatformTools
   ```
   
   **Verifica la instalación:**
   ```powershell
   adb version
   ```
   Deberías ver la versión de ADB.

2. **Conecta tu celular Android a tu PC Windows con USB**

3. **Habilita Depuración USB en tu celular:**
   - Ve a `Configuración` → `Acerca del teléfono`
   - Toca 7 veces en "Número de compilación" para activar opciones de desarrollador
   - Ve a `Configuración` → `Opciones de desarrollador`
   - Activa "Depuración USB"

4. **En Windows, abre PowerShell o CMD y ejecuta:**
   ```powershell
   adb devices
   ```
   Deberías ver tu dispositivo listado.

5. **Obtén la IP de tu celular (desde Windows):**
   ```powershell
   adb tcpip 5555
   adb shell ip addr show wlan0
   ```
   O ve a: Configuración → Wi-Fi → (tu red) → IP

6. **Desde WSL2, conéctate por TCP/IP:**
   ```bash
   cd /home/marcoaspeitia/Proyects/conekta-flutter-tokenizer
   adb connect <IP_DEL_CELULAR>:5555
   # Ejemplo: adb connect 192.168.1.100:5555
   ```

7. **Verifica la conexión:**
   ```bash
   adb devices
   flutter devices
   ```

8. **Ejecuta la app:**
   ```bash
   flutter run
   ```

---

## Opción 2: Habilitar Linux Desktop (Rápido para pruebas)

Si quieres probar la app en Linux desktop mientras configuras el dispositivo:

### Instalar dependencias:
```bash
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev
```

### Habilitar Linux en el proyecto:
```bash
cd /home/marcoaspeitia/Proyects/conekta-flutter-tokenizer
flutter create --platforms=linux .
```

### Ejecutar en Linux:
```bash
flutter run -d linux
```

---

## Opción 3: Usar Emulador Android

Si prefieres usar un emulador:

### Ver emuladores disponibles:
```bash
flutter emulators
```

### Iniciar un emulador:
```bash
flutter emulators --launch <nombre_emulador>
```

### O crear uno nuevo:
```bash
# Primero instala Android Studio y SDK
# Luego desde Android Studio: Tools → Device Manager → Create Device
```

---

## Solución de Problemas

### Si `adb` no se reconoce en PowerShell/CMD (error "no se reconoce como nombre de cmdlet"):
- Ve al paso 1 de la Opción 1 para instalar ADB en Windows
- Asegúrate de agregar ADB al PATH y reiniciar PowerShell/CMD
- Verifica con `adb version`

### Si `adb devices` no muestra nada en WSL2:
1. Instala `adb` en Windows también (ver paso 1 de la Opción 1)
2. Conecta desde Windows primero
3. Luego usa `adb connect` desde WSL2

### Si el dispositivo aparece como "unauthorized":
- Acepta el diálogo de "Permitir depuración USB" en tu celular
- Revisa que la depuración USB esté activada

### Si necesitas reinstalar adb en WSL2/Linux:
```bash
sudo apt install android-tools-adb android-tools-fastboot
```

---

## Verificación Rápida

```bash
# Verificar dispositivos conectados
adb devices

# Ver dispositivos Flutter
flutter devices

# Si todo está bien, ejecutar
flutter run
```

