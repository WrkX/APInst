# Define the path for the systemd timer file
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
sudo systemctl enable --now paccache.timer

# Show the status of the timer
echo "Timer status:"
sudo systemctl status paccache.timer
