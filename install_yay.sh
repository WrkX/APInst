#!/bin/bash

# Prüfen, ob yay installiert ist
if command -v yay &> /dev/null; then
  echo "yay ist bereits installiert."
  exit 0
fi

echo "yay wird installiert..."

# Benötigte Abhängigkeiten installieren (falls nicht vorhanden)
sudo pacman -S --needed base-devel git --noconfirm

# Temporäres Verzeichnis für die Installation erstellen
TEMP_DIR=$(mktemp -d)
echo "Temporäres Verzeichnis erstellt: $TEMP_DIR"

# Wechsel in das temporäre Verzeichnis
cd "$TEMP_DIR" || exit 1

# yay-Repository klonen und installieren
git clone https://aur.archlinux.org/yay.git
cd yay || exit 1
makepkg -si --noconfirm

# Temporäres Verzeichnis löschen
cd ~
rm -rf "$TEMP_DIR"

# Installation überprüfen
if command -v yay &> /dev/null; then
  echo "yay wurde erfolgreich installiert."
else
  echo "Fehler bei der Installation von yay."
  exit 1
fi
