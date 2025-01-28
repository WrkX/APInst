#!/bin/bash

# NVIDIA-Treiber von Frogging Family automatisch installieren

# Überprüfen, ob `git` und `base-devel` installiert sind
echo "Prüfen, ob benötigte Pakete installiert sind..."
sudo pacman -S --needed base-devel git --noconfirm

# Temporäres Verzeichnis erstellen
TEMP_DIR="$HOME"
echo "Temporäres Verzeichnis erstellt: $TEMP_DIR"

# Repository klonen
echo "Klonen des Frogging-Family-Repositorys..."
cd "$TEMP_DIR" || exit 1
git clone https://github.com/Frogging-Family/nvidia-all.git

# In das geklonte Verzeichnis wechseln
cd nvidia-all || exit 1

# Installationsprozess starten
echo "Starten des Paketierungsprozesses..."
makepkg -si --noconfirm
