#!/bin/bash

PKG_LIST="pkgs.lst"

# Check if the package list exists
if [[ ! -f "$PKG_LIST" ]]; then
    echo "Error: '$PKG_LIST' not found!"
    exit 1
fi

# Read packages into an array
mapfile -t packages < "$PKG_LIST"

# Check if the list is empty
if [[ ${#packages[@]} -eq 0 ]]; then
    echo "The package list is empty."
    exit 1
fi

# Display menu
echo "Package Installation Menu"
echo "=========================="
echo " 0) Install ALL packages"
for i in "${!packages[@]}"; do
    printf " %d) %s\n" "$((i+1))" "${packages[i]}"
done
echo " q) Quit without installing"

# Function to install selected packages using pacman, with fallback to yay
install_package() {
    local pkg="$1"

    # Try installing with pacman first
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "$pkg is already installed."
    else
        # Try installing with pacman
        if ! sudo pacman -S --needed "$pkg"; then
            echo "$pkg not found in the official repositories, attempting to install with yay..."
            # If pacman fails, try installing using yay (AUR)
            if ! yay -S --needed "$pkg"; then
                echo "Failed to install '$pkg' using yay. Skipping."
            fi
        fi
    fi
}

# Function to install selected packages
install_packages() {
    local pkgs=("$@")
    if [[ ${#pkgs[@]} -eq 0 ]]; then
        echo "No packages selected. Exiting."
        exit 0
    fi

    echo "Installing selected packages: ${pkgs[*]}"
    for pkg in "${pkgs[@]}"; do
        install_package "$pkg"
    done
}

# Selection loop
selected_packages=()
while true; do
    read -rp "Select package numbers (e.g., 1 2 3 or 0 to install all, q to quit): " -a choices

    for choice in "${choices[@]}"; do
        # Quit option
        if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
            echo "No packages will be installed. Exiting."
            exit 0
        fi

        # Install all packages
        if [[ "$choice" == "0" ]]; then
            install_packages "${packages[@]}"
            exit 0
        fi

        # Validate numeric input
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#packages[@]} )); then
            pkg="${packages[choice-1]}"

            # Check if already selected
            if [[ " ${selected_packages[*]} " == *" $pkg "* ]]; then
                echo "'$pkg' is already selected."
            else
                selected_packages+=("$pkg")
                echo "'$pkg' added to the installation list."
                install_package "$pkg"  # Install immediately after selection
            fi
        else
            echo "Invalid selection: '$choice'. Please choose valid numbers, 0, or 'q'."
        fi
    done
done
