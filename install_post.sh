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
sudo systemctl enable NetworkManager.service


# Create zshenv file so I can put .zshrc in config folder #
###########################################################
ZSHENV_FILE="/etc/zsh/zshenv"

# Ensure /etc/zsh directory exists
if [ ! -d "/etc/zsh" ]; then
    echo "Creating /etc/zsh directory..."
    sudo mkdir -p /etc/zsh
fi

# Write the export statement to the file
echo 'export ZDOTDIR="$HOME"/.config/zsh' | sudo tee "$ZSHENV_FILE" > /dev/null

# Set appropriate permissions (readable by all, writable only by root)
sudo chmod 644 "$ZSHENV_FILE"

# Confirm the changes
echo "Created $ZSHENV_FILE with the following content:"
sudo cat "$ZSHENV_FILE"
############################################################

# Zsh als Standard-Shell für den aktuellen Benutzer setzen #
############################################################
echo "Setze Zsh als Standard-Shell für den Benutzer $USER..."
############################################################

# FStab entries #
#############################################################
sudo mkdir -p /games

# Auto create FSTAB for home labeled partition
UUID=$(lsblk -o UUID,LABEL | grep 'home' | awk '{print $1}')

# Check if UUID was found
if [ -z "$UUID" ]; then
    echo "Error: No partition with label 'home' found."
    exit 1
fi

# Append the entry to /etc/fstab (adjust the mount point and file system type as needed)
echo "UUID=$UUID  /home	btrfs		defaults,noatime,autodefrag,compress=zstd 0 0" | sudo tee -a /etc/fstab

echo "Entry for 'home' added to /etc/fstab."

# Auto create FSTAB for games or steam labeled partition
UUID=$(lsblk -o UUID,LABEL | grep -E 'games|steam' | awk '{print $1}')

# Check if UUID was found
if [ -z "$UUID" ]; then
    echo "Error: No partition with label 'games' or 'steam' found."
    exit 1
fi

# Append the entry to /etc/fstab (adjust the mount point and file system type as needed)
echo "UUID=$UUID  /games  ntfs-3g  defaults,locale=en_US.UTF-8,uid=1000,gid=1000,umask=0022 0 2" | sudo tee -a /etc/fstab

echo "Entry for 'games' or 'steam' added to /etc/fstab."
########################################################################

# Setup SDDM Theme #
########################################################################
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF_FILE="$SDDM_CONF_DIR/theme.conf"
THEME_NAME="catppuccin-frappe"   # Replace this with your desired theme name

# Ensure the SDDM configuration directory exists
if [ ! -d "$SDDM_CONF_DIR" ]; then
    echo "Creating $SDDM_CONF_DIR..."
    sudo mkdir -p "$SDDM_CONF_DIR"
fi

# Create the SDDM configuration file with the theme settings
echo "[Theme]
Current=$THEME_NAME" | sudo tee "$SDDM_CONF_FILE" > /dev/null

# Set proper permissions
sudo chmod 644 "$SDDM_CONF_FILE"

# Confirm the configuration
echo "SDDM theme configuration created at $SDDM_CONF_FILE with the following content:"
sudo cat "$SDDM_CONF_FILE"
#####################################################################

# Create paccache timer
###################################################################
TIMER_FILE="/etc/systemd/system/paccache.timer"

# Create the systemd timer file
echo "Creating paccache.timer..."
sudo tee "$TIMER_FILE" > /dev/null <<EOF
[Unit]
Description=Clean-up old pacman pkg cache

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=multi-user.target
EOF

# Set appropriate permissions
sudo chmod 644 "$TIMER_FILE"

# Reload systemd to recognize the new timer
sudo systemctl daemon-reload

# Enable and start the timer
echo "Enabling and starting paccache.timer..."
sudo systemctl enable paccache.timer
#####################################################################

# Final settings #
# ###################################################################
sudo usermod -aG gamemode,wheel $(whoami)
chsh -s "$(which zsh)" "$USER"
######################################################################
