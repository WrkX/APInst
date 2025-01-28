#!/bin/bash

# Überprüfen, ob Root-Rechte vorhanden sind
if [ "$EUID" -ne 0 ]; then
  echo "Bitte führe das Skript mit Root-Rechten aus (sudo)."
  exit 1
fi

# Zsh als Standard-Shell für den aktuellen Benutzer setzen
echo "Setze Zsh als Standard-Shell für den Benutzer $USER..."
chsh -s "$(which zsh)" "$USER"

# Oh My Zsh installieren
echo "Installiere Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sudo -u "$USER" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh ist bereits installiert."
fi
