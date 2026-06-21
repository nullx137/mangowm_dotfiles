#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME_DIR/.config"
WALLPAPER_DIR="$HOME_DIR/Pictures/wallpapers"
WALLPAPER_PATH="$WALLPAPER_DIR/wallpaper.jpg"
SDDM_THEME_DIR="/usr/share/sddm/themes/gruvscure-sddm-theme"

echo "======================================"
echo "  MangoWM Gruvbox Dotfiles Installer"
echo "======================================"
echo ""
echo "Choose your distribution:"
echo "  1) Arch Linux"
echo "  2) Void Linux"
read -rp "Enter choice [1-2]: " DISTRO_CHOICE

case "$DISTRO_CHOICE" in
    1|arch|Arch|"Arch Linux")
        DISTRO="arch"
        ;;
    2|void|Void|"Void Linux")
        DISTRO="void"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Selected: $DISTRO"
echo ""

backup_config() {
    if [ -d "$1" ] || [ -f "$1" ]; then
        local backup="${1}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up $1 -> $backup"
        cp -r "$1" "$backup" || true
    fi
}

install_pkg_arch() {
    local pkg="$1"
    if pacman -Si "$pkg" >/dev/null 2>&1; then
        echo "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg" || echo "Warning: failed to install $pkg"
    else
        echo "Package not found in repos: $pkg (may be in AUR)"
    fi
}

install_pkg_void() {
    local pkg="$1"
    echo "Installing $pkg..."
    sudo xbps-install -Sy "$pkg" || echo "Warning: failed to install $pkg (may not exist in Void repos)"
}

install_packages() {
    echo "Installing dependencies..."
    if [ "$DISTRO" = "arch" ]; then
        sudo pacman -Sy --noconfirm

        # Core packages from official repos
        local packages=(
            foot
            waybar
            hyprlock
            sddm
            swaybg
            fuzzel
            brightnessctl
            wireplumber
            pipewire-pulse
            fastfetch
            cli-visualizer
            grim
            slurp
            ttf-jetbrains-mono-nerd
            ttf-nerd-fonts-symbols
            swayosd
        )

        for pkg in "${packages[@]}"; do
            install_pkg_arch "$pkg"
        done

        echo ""
        echo "!!! IMPORTANT !!!"
        echo "The following packages are likely in AUR and must be installed manually:"
        echo "  - mangowm"
        echo "  - libinput-gestures (optional, for touchpad gestures)"
        echo ""
        echo "Install them with your AUR helper, e.g.:"
        echo "  yay -S mangowm libinput-gestures"
        echo ""

    elif [ "$DISTRO" = "void" ]; then
        sudo xbps-install -Sy

        local packages=(
            foot
            waybar
            hyprlock
            sddm
            swaybg
            fuzzel
            brightnessctl
            wireplumber
            pipewire
            pipewire-pulse
            fastfetch
            cli-visualizer
            grim
            slurp
            font-jetbrains-mono-ttf
        )

        for pkg in "${packages[@]}"; do
            install_pkg_void "$pkg"
        done

        echo ""
        echo "!!! IMPORTANT !!!"
        echo "MangoWM may not be available in Void Linux repos."
        echo "You may need to build it from source or find it in a third-party repository."
        echo ""
    fi
}

# Install dependencies
install_packages

# Backup existing configs
echo "Backing up existing configs..."
backup_config "$CONFIG_DIR/mango"
backup_config "$CONFIG_DIR/foot"
backup_config "$CONFIG_DIR/waybar"
backup_config "$CONFIG_DIR/hypr"
backup_config "$CONFIG_DIR/environment.d"
backup_config "$CONFIG_DIR/systemd"
backup_config "$CONFIG_DIR/sddm-themes"
backup_config "$CONFIG_DIR/vis"
backup_config "$CONFIG_DIR/fastfetch"

# Copy wallpaper
echo "Copying wallpaper..."
mkdir -p "$WALLPAPER_DIR"
cp "$REPO_DIR/wallpapers/wallpaper.jpg" "$WALLPAPER_PATH"

# Copy configs
echo "Copying configs..."
mkdir -p "$CONFIG_DIR"
cp -r "$REPO_DIR/.config/"* "$CONFIG_DIR/"

# Replace hardcoded /home/null paths with current home
echo "Updating paths in configs..."
find "$CONFIG_DIR" -type f \
    \( -name "*.conf" -o -name "*.ini" -o -name "*.jsonc" -o -name "*.css" -o -name "99-user.conf" \) \
    -exec sed -i "s|/home/null|$HOME_DIR|g" {} \;

# Update wallpaper path in MangoWM and SDDM configs to the installed location
sed -i "s|$HOME_DIR/Downloads/wallpaper.jpg|$WALLPAPER_PATH|g" "$CONFIG_DIR/mango/config.conf" || true
sed -i "s|$HOME_DIR/Downloads/wallpaper.jpg|$WALLPAPER_PATH|g" "$CONFIG_DIR/sddm-themes/gruvscure-sddm-theme/theme.conf" || true

# Install SDDM theme
echo "Installing SDDM theme..."
sudo rm -rf "$SDDM_THEME_DIR"
sudo cp -r "$CONFIG_DIR/sddm-themes/gruvscure-sddm-theme" "$SDDM_THEME_DIR"

# Copy wallpaper into SDDM theme directory so SDDM greeter can read it.
# SDDM runs as the 'sddm' user and cannot access files inside $HOME.
echo "Copying wallpaper into SDDM theme directory..."
sudo cp "$WALLPAPER_PATH" "$SDDM_THEME_DIR/wallpaper.jpg"
sudo chmod 644 "$SDDM_THEME_DIR/wallpaper.jpg"
sudo sed -i "s|backgroundImage=.*|backgroundImage=$SDDM_THEME_DIR/wallpaper.jpg|" "$SDDM_THEME_DIR/theme.conf"

# Verify
echo "SDDM theme installed at: $SDDM_THEME_DIR"
echo "SDDM wallpaper path: $SDDM_THEME_DIR/wallpaper.jpg"

# Configure SDDM
sudo mkdir -p /etc/sddm.conf.d
printf "[Theme]\nCurrent=gruvscure-sddm-theme\n" | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
printf "[General]\nInputMethod=\n" | sudo tee /etc/sddm.conf.d/20-inputmethod.conf >/dev/null

# Add user to input group for touchpad gestures
if ! id -nG "$USER" | grep -qw "input"; then
    echo "Adding $USER to input group (required for touchpad gestures)..."
    sudo usermod -aG input "$USER"
fi

# Enable hyprlock suspend service
echo "Enabling hyprlock suspend service..."
systemctl --user daemon-reload
systemctl --user enable hyprlock-suspend.service || true

# Enable SDDM
if [ "$DISTRO" = "arch" ]; then
    echo "Enabling SDDM..."
    sudo systemctl enable sddm.service || true
elif [ "$DISTRO" = "void" ]; then
    echo "Enable SDDM manually for your init system (Void uses runit)."
fi

echo ""
echo "======================================"
echo "  Installation complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Install MangoWM (and libinput-gestures if on Arch):"
echo "       yay -S mangowm libinput-gestures"
echo "  2. Reboot or log out/in for environment.d and group changes to take effect."
echo "  3. Log in via SDDM to start MangoWM."
echo ""
echo "Wallpaper installed at: $WALLPAPER_PATH"
echo ""
