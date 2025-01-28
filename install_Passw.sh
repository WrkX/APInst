#!/bin/bash

# Sicherstellen, dass das Skript als root ausgeführt wird
if [[ $EUID -ne 0 ]]; then
   echo "Dieses Skript muss als root ausgeführt werden!"
   exit 1
fi

# Regel für die Gruppe 'wheel' aktivieren oder rückgängig machen
if ! grep -q "^%wheel ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "Aktiviere NOPASSWD für die Gruppe 'wheel'..."

    # Eine temporäre Datei für die Bearbeitung mit visudo erstellen
    temp_file=$(mktemp)
    cp /etc/sudoers "$temp_file"

    # Zeile hinzufügen oder auskommentierte Zeile aktivieren
    sed -i 's/^#\s*%wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' "$temp_file"

    # Änderungen mit visudo überprüfen und anwenden
    visudo -c -f "$temp_file"
    if [[ $? -eq 0 ]]; then
        cp "$temp_file" /etc/sudoers
        echo "Die Konfiguration wurde erfolgreich aktualisiert."
    else
        echo "Fehler: Die Änderungen an der sudoers-Datei enthalten einen Fehler."
    fi

    # Temporäre Datei entfernen
    rm -f "$temp_file"
else
    echo "Rückgängig machen: Deaktiviere NOPASSWD für die Gruppe 'wheel'..."

    # Eine temporäre Datei für die Bearbeitung mit visudo erstellen
    temp_file=$(mktemp)
    cp /etc/sudoers "$temp_file"

    # Zeile auskommentieren oder entfernen
    sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' "$temp_file"

    # Änderungen mit visudo überprüfen und anwenden
    visudo -c -f "$temp_file"
    if [[ $? -eq 0 ]]; then
        cp "$temp_file" /etc/sudoers
        echo "Die Konfiguration wurde erfolgreich rückgängig gemacht."
    else
        echo "Fehler: Die Änderungen an der sudoers-Datei enthalten einen Fehler."
    fi

    # Temporäre Datei entfernen
    rm -f "$temp_file"
fi
