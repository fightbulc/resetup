#!/usr/bin/env bash

#
# SOURCE CONFIG
#

. $1

#
# RUN TASK
#

echo "- install flatpak and gear lever"

export DEBIAN_FRONTEND=noninteractive

# Install flatpak
echo "  Installing flatpak..."
sudo apt update
sudo apt install -y flatpak

# Install GNOME Software plugin for flatpak
echo "  Installing GNOME Software plugin for flatpak..."
sudo apt install -y gnome-software-plugin-flatpak

# Add Flathub repository
echo "  Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Gear Lever from Flathub
echo "  Installing Gear Lever from Flathub..."
flatpak install -y flathub it.mijorus.gearlever

echo "  ✅ Flatpak and Gear Lever installed successfully"
echo "  💡 Gear Lever is an AppImage manager that can integrate AppImages into your system"
echo "  💡 Remember to add --no-sandbox flag when integrating AppImages that don't support sandboxing"