#!/bin/bash

# Script para conectar dispositivo Android desde WSL2

echo "🔌 Conectando dispositivo Android..."

# Verificar si adb está instalado
if ! command -v adb &> /dev/null; then
    echo "❌ adb no está instalado. Instalando..."
    sudo apt update
    sudo apt install -y android-tools-adb
fi

# Verificar dispositivos conectados vía USB
echo "📱 Verificando dispositivos USB..."
USB_DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)

if [ "$USB_DEVICES" -eq 0 ]; then
    echo "⚠️  No se encontraron dispositivos USB conectados."
    echo ""
    echo "Para conectar vía TCP/IP:"
    echo "1. Conecta tu celular a Windows con USB"
    echo "2. En Windows PowerShell, ejecuta: adb tcpip 5555"
    echo "3. Obtén la IP de tu celular (Configuración → Wi-Fi)"
    echo "4. Ejecuta: adb connect <IP>:5555"
    echo ""
    read -p "¿Tienes la IP de tu celular? (s/n): " tiene_ip
    
    if [ "$tiene_ip" = "s" ] || [ "$tiene_ip" = "S" ]; then
        read -p "Ingresa la IP del celular: " ip_celular
        echo "🔗 Conectando a $ip_celular:5555..."
        adb connect "$ip_celular:5555"
        
        if [ $? -eq 0 ]; then
            echo "✅ ¡Conectado exitosamente!"
            adb devices
        else
            echo "❌ Error al conectar. Verifica que:"
            echo "   - El celular esté en la misma red Wi-Fi"
            echo "   - Hayas ejecutado 'adb tcpip 5555' desde Windows"
            echo "   - La IP sea correcta"
        fi
    fi
else
    echo "✅ Dispositivo(s) USB detectado(s):"
    adb devices
fi

# Verificar con Flutter
echo ""
echo "🔍 Verificando dispositivos Flutter..."
flutter devices

echo ""
echo "✅ Listo! Ahora puedes ejecutar: flutter run"

