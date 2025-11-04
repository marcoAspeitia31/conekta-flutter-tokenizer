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

8. **Habilita la plataforma Android en el proyecto (si es necesario):**
   
   Si al ejecutar `flutter devices` ves tu dispositivo pero `flutter run` dice "No supported devices connected", necesitas habilitar Android en el proyecto:
   
   ```bash
   cd /home/marcoaspeitia/Proyects/conekta-flutter-tokenizer
   flutter create --platforms=android --project-name=conekta_flutter_tokenizer .
   ```
   
   **Nota:** Si el nombre de tu directorio tiene guiones (como `conekta-flutter-tokenizer`), usa el parámetro `--project-name` con el nombre del paquete de tu `pubspec.yaml` (con guiones bajos).
   
   Esto generará los archivos necesarios para Android sin modificar tu código existente.

9. **Instala Java y configura JAVA_HOME (requerido para compilar Android):**
   
   Flutter necesita Java para compilar aplicaciones Android. Instálalo en WSL2:
   
   ```bash
   # Instalar Java JDK 17 (recomendado para Flutter)
   sudo apt update
   sudo apt install -y openjdk-17-jdk
   ```
   
   **Configura JAVA_HOME:**
   
   ```bash
   # Encuentra la ruta de Java
   java -XshowSettings:properties -version 2>&1 | grep 'java.home'
   # O simplemente:
   which java
   ```
   
   **Agrega JAVA_HOME a tu perfil de shell:**
   
   ```bash
   # Para zsh (tu shell actual)
   echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.zshrc
   echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.zshrc
   source ~/.zshrc
   ```
   
   **Verifica la instalación:**
   ```bash
   java -version
   echo $JAVA_HOME
   ```
   
   Deberías ver la versión de Java y la ruta de JAVA_HOME.

10. **Configura ANDROID_HOME para usar tu SDK instalado:**
   
   Si instalaste el Android SDK en `~/android-sdk`, configura Flutter para usarlo:
   
   ```bash
   # Agregar ANDROID_HOME a tu perfil de shell
   echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
   source ~/.zshrc
   ```
   
   **Instala los componentes necesarios del SDK:**
   
   ```bash
   # Instalar Platform 34 y Build-Tools 30.0.3 (requeridos por el proyecto)
   $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-34" "build-tools;30.0.3"
   ```
   
   **Configura el proyecto para usar tu SDK:**
   
   Edita o crea el archivo `android/local.properties` en tu proyecto:
   
   ```bash
   cd /home/marcoaspeitia/Proyects/conekta-flutter-tokenizer
   echo "sdk.dir=$HOME/android-sdk" > android/local.properties
   echo "flutter.sdk=$(flutter --version | head -1 | awk '{print $2}')" >> android/local.properties
   ```
   
   O edítalo manualmente para que contenga:
   ```
   sdk.dir=/home/marcoaspeitia/android-sdk
   ```
   
   **Verifica la configuración:**
   ```bash
   echo $ANDROID_HOME
   flutter doctor -v
   ```
   
   Flutter debería detectar tu SDK y las licencias aceptadas.

11. **Ejecuta la app:**
   ```bash
   flutter run
   ```
   
   O si quieres especificar el dispositivo:
   ```bash
   flutter run -d 192.168.100.41:5555
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

### Si `flutter run` dice "No supported devices connected" pero `flutter devices` muestra tu dispositivo:
- El proyecto no tiene configurada la plataforma Android
- Ejecuta: `flutter create --platforms=android --project-name=conekta_flutter_tokenizer .`
- Esto generará los archivos necesarios sin modificar tu código
- Luego intenta `flutter run` nuevamente

### Si `flutter create` da error "is not a valid Dart package name":
- El nombre del directorio tiene guiones pero Dart requiere guiones bajos
- Usa el parámetro `--project-name` con el nombre correcto de tu `pubspec.yaml`
- Ejemplo: `flutter create --platforms=android --project-name=conekta_flutter_tokenizer .`

### Si `flutter run` da error "JAVA_HOME is not set" o "no 'java' command could be found":
- Java no está instalado o JAVA_HOME no está configurado
- Instala Java JDK 17: `sudo apt install -y openjdk-17-jdk`
- Configura JAVA_HOME en tu `.zshrc` o `.bashrc`:
  ```bash
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.zshrc
  echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.zshrc
  source ~/.zshrc
  ```
- Verifica con: `java -version` y `echo $JAVA_HOME`

### Si `flutter run` da error "The SDK directory is not writable (/usr/lib/android-sdk)":
- El SDK en `/usr/lib/android-sdk` no tiene permisos de escritura
- **Solución:** Configura el proyecto para usar tu SDK en `~/android-sdk`:
  1. Configura `ANDROID_HOME`:
     ```bash
     echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.zshrc
     echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
     echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
     source ~/.zshrc
     ```
  2. Instala los componentes necesarios:
     ```bash
     $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-34" "build-tools;30.0.3"
     ```
  3. **Edita `android/local.properties`** para apuntar a tu SDK:
     ```
     sdk.dir=/home/marcoaspeitia/android-sdk
     ```
- Verifica con: `echo $ANDROID_HOME` y `flutter doctor -v`

### Si `flutter run` da error sobre licencias no aceptadas:
- Si instalaste el SDK en `~/android-sdk`, acepta las licencias:
  ```bash
  yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
  ```
- Si Flutter está usando `/usr/lib/android-sdk`, copia las licencias:
  ```bash
  sudo mkdir -p /usr/lib/android-sdk/licenses
  sudo cp ~/android-sdk/licenses/* /usr/lib/android-sdk/licenses/
  ```
- O mejor aún, configura `ANDROID_HOME` para usar tu SDK (ver solución anterior)

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

