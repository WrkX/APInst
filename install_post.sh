#!/bin/bash

# Sicherstellen, dass das Skript als root ausgeführt wird
if [[ $EUID -ne 0 ]]; then
  echo "Dieses Skript muss als root ausgeführt werden!"
  exit 1
fi

echo "Aktiviere TRIM-Unterstützung für SSDs..."

# 1. Prüfen, ob der Scheduler "fstrim.timer" verfügbar ist
if systemctl list-timers | grep -q fstrim.timer; then
  echo "Aktiviere den fstrim.timer für periodisches TRIM..."
  systemctl enable fstrim.timer
  systemctl start fstrim.timer
  echo "fstrim.timer wurde aktiviert und gestartet."
else
  echo "Warnung: fstrim.timer ist auf diesem System nicht verfügbar."
fi

# 2. Sofortiges TRIM ausführen
echo "Führe TRIM sofort aus..."
fstrim -av

# 3. Erfolgsmeldung
echo "TRIM wurde aktiviert und auf allen unterstützten Partitionen ausgeführt."

sudo systemctl enable ufw
echo "UFW wurde aktiviert"
