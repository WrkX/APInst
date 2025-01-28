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
makepkg -si

# Pacman-Hook für NVIDIA einrichten

HOOK_PATH="/etc/pacman.d/hooks"
HOOK_FILE="$HOOK_PATH/nvidia.hook"

# Hook-Verzeichnis erstellen, falls nicht vorhanden
if [ ! -d "$HOOK_PATH" ]; then
  echo "Erstelle Hook-Verzeichnis: $HOOK_PATH"
  sudo mkdir -p "$HOOK_PATH"
fi

# Pacman-Hook erstellen
echo "Erstelle Pacman-Hook unter: $HOOK_FILE"
sudo cat > "$HOOK_FILE" <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
# Uncomment the installed NVIDIA package
#Target=nvidia
Target=nvidia-open
#Target=nvidia-lts
# If running a different kernel, modify below to match
Target=linux

[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

# Erfolgreich abgeschlossen
echo "Installation abgeschlossen. NVIDIA-Treiber sind jetzt installiert."
