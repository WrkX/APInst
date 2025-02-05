#!/bin/bash

# Array of directories in the correct install order
meta_packages=(
    "wrkx-base-meta"
    "wrkx-desktop-meta"
    "wrkx-gaming-meta"
    "wrkx-misc-meta"
)

# Loop through the packages and install them from the repository
for package in "${meta_packages[@]}"; do
    echo "Installing $package..."

    # Check if the package is in the custom repository
    if [[ "$package" == "wrkx-base-meta" ]]; then
        # Use pacman for base-meta (from repo)
        sudo pacman -S --noconfirm "$package" || { echo "Installation failed for $package"; exit 1; }
    else
        # Use yay for AUR packages (install from the AUR)
        yay -S --noconfirm "$package" || { echo "Installation failed for $package"; exit 1; }
    fi

    echo "$package installed successfully."
done

echo "All packages installed successfully!"
