#!/bin/bash

if [ -f /etc/pacman.conf ] && [ ! -f /etc/pacman.conf.t2.bkp ]; then
    echo -e "\033[0;32m[PACMAN]\033[0m adding extra spice to pacman..."

    sudo cp /etc/pacman.conf /etc/pacman.conf.t2.bkp
    sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf

    sudo pacman -Syyu
    sudo pacman -Fy

else
    echo -e "\033[0;33m[SKIP]\033[0m pacman is already configured..."
fi

MAKEPKG_CONF="/etc/makepkg.conf"
cp $MAKEPKG_CONF ${MAKEPKG_CONF}.bak
sed -i 's/\bdebug\b/!debug/g' $MAKEPKG_CONF

# Define the repository configuration to append
REPO_CONFIG="
[wrkx-arch-repo]
SigLevel = Optional DatabaseOptional
Server = https://wrkx.github.io/wrkx-arch-repo/x86_64
"

# Path to the pacman.conf file
PACMAN_CONF="/etc/pacman.conf"

# Check if the repository is already added
if ! grep -q "\[wrkx-arch-repo\]" "$PACMAN_CONF"; then
  # Append the repository configuration to pacman.conf
  echo "$REPO_CONFIG" | sudo tee -a "$PACMAN_CONF" > /dev/null
  echo "Repository [wrkx-arch-repo] added to pacman.conf."
else
  echo "Repository [wrkx-arch-repo] is already present in pacman.conf."
fi

pacman -Syy
