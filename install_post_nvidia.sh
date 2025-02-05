#!/bin/bash
# Add Nvidia mkinit config
cd /boot/loader/entries || { echo "Directory not found!"; exit 1; }

# List all .conf files
conf_files=(*.conf)

# Check if any .conf files exist
if [ ${#conf_files[@]} -eq 0 ]; then
    echo "No .conf files found in /boot/loader/entries."
    exit 1
fi

echo "Updating the following boot entries:"
printf '%s\n' "${conf_files[@]}"

# Check kernel version
kernel_version=$(uname -r | cut -d'-' -f1)
major_version=$(echo "$kernel_version" | cut -d'.' -f1)
minor_version=$(echo "$kernel_version" | cut -d'.' -f2)

# Loop through all .conf files
for filename in "${conf_files[@]}"; do
    echo "Processing $filename..."

    # Append 'nvidia-drm.modeset=1' if it's not already present
    sudo sed -i '/^options /{
        /nvidia-drm.modeset=1/! s/$/ nvidia-drm.modeset=1/
    }' "$filename"

    # Add 'nvidia-drm.fbdev=1' if kernel is 6.11 or newer
    if (( major_version > 6 )) || (( major_version == 6 && minor_version >= 11 )); then
        sudo sed -i '/^options /{
            /nvidia-drm.fbdev=1/! s/$/ nvidia-drm.fbdev=1/
        }' "$filename"
    fi

    echo "Updated $filename successfully."
done

echo "All .conf files have been updated."

# Path to mkinitcpio.conf
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Ensure the file exists
if [ ! -f "$MKINITCPIO_CONF" ]; then
    echo "Error: $MKINITCPIO_CONF not found!"
    exit 1
fi

# List of NVIDIA modules to append
NVIDIA_MODULES=("nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm")

# Function to append NVIDIA modules if not present
append_modules() {
    for module in "${NVIDIA_MODULES[@]}"; do
        if ! grep -q "MODULES=.*\b$module\b" "$MKINITCPIO_CONF"; then
            sudo sed -i "/^MODULES=/ s/)/ $module)/" "$MKINITCPIO_CONF"
            echo "Added $module to MODULES=()."
        else
            echo "$module is already present in MODULES=()."
        fi
    done
}

# Function to remove 'kms' from HOOKS=()
remove_kms_hook() {
    if grep -q "HOOKS=.*\bkms\b" "$MKINITCPIO_CONF"; then
        sudo sed -i '/^HOOKS=/ s/\bkms\b//g' "$MKINITCPIO_CONF"
        sudo sed -i '/^HOOKS=/ s/  / /g' "$MKINITCPIO_CONF"  # Clean double spaces
        sudo sed -i '/^HOOKS=/ s/ (/(/' "$MKINITCPIO_CONF"  # Clean space after '('
        sudo sed -i '/^HOOKS=/ s/) )/)/' "$MKINITCPIO_CONF" # Clean trailing ') '
        echo "Removed 'kms' from HOOKS=()."
    else
        echo "'kms' not found in HOOKS=()."
    fi
}

# Apply changes
append_modules
remove_kms_hook

# Regenerate initramfs
echo "Regenerating initramfs with mkinitcpio..."
sudo mkinitcpio -P

echo "Configuration updated successfully!"

# Define the hook file path
HOOK_FILE="/etc/pacman.d/hooks/nvidia.hook"

# Create the directory if it doesn't exist
sudo mkdir -p /etc/pacman.d/hooks

# Create the nvidia.hook file and write the content to it
echo "Creating nvidia.hook..."

sudo tee "$HOOK_FILE" > /dev/null <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
# You can remove package(s) that don't apply to your config, e.g. if you only use nvidia-open you can remove nvidia-lts as a Target
Target=nvidia
Target=nvidia-open
Target=nvidia-lts
# If running a different kernel, modify below to match
Target=linux

[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

# Set appropriate permissions for the hook file
sudo chmod 644 "$HOOK_FILE"

echo "nvidia.hook created successfully at $HOOK_FILE"
