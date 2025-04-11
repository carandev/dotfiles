#!/bin/bash

echo "🚀 Instalando libinput y xorg-xinput..."
sudo pacman -Syu --noconfirm libinput xorg-xinput

echo "📝 Creando configuración en /etc/X11/xorg.conf.d/40-libinput.conf..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/40-libinput.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOF

echo "✅ Configuración completada."

echo "🔁 Reinicia tu sesión gráfica (o el sistema) para aplicar los cambios."

