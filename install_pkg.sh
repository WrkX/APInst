#!/bin/bash

# Prüfen, ob `yay` installiert ist
if ! command -v yay &> /dev/null; then
  echo "Error: yay ist nicht installiert. Bitte installiere yay zuerst."
  exit 1
fi

# Prüfen, ob die Datei pkg.lst existiert
if [ ! -f "pkg.lst" ]; then
  echo "Error: Die Datei pkg.lst wurde nicht gefunden."
  exit 1
fi

# Durch die Datei pkg.lst iterieren und Pakete installieren
while IFS= read -r paket || [ -n "$paket" ]; do
  if [ -n "$paket" ]; then
    echo "Installiere: $paket"
    yay -Sy --noconfirm "$paket"
  fi
done < "pkg.lst"

echo "Alle Pakete wurden verarbeitet."
