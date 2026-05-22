#!/bin/bash
# ============================================================================
# Hyprland-Blizz Installation Script
# Version: 2.0 - Modernized for 2026
# Developer: RedBlizard
# Original Date: 10 December 2023
# Updated: May 2026
# ============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# COLOR DEFINITIONS (centralized)
# ============================================================================
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# ============================================================================
# LOG FILE SETUP
# ============================================================================
log_file="$HOME/installation_log.txt"
exec > >(tee -i "$log_file") 2>&1

# ============================================================================
# BANNER
# ============================================================================
show_banner() {
    echo -e "${RED}"
    cat <<"EOF"
██╗░░██╗██╗░░░██╗██████╗░██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░░░░░░░██████╗░██╗░░░░░██╗███████╗███████╗
██║░░██║╚██╗░██╔╝██╔══██╗██╔══██╗██║░░░░░██╔══██║████╗░██║██╔══██╗░░░░░░██╔══██╗██║░░░░░██║╚════██║╚════██║
███████║░╚████╔╝░██████╔╝██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║█████╗██████╦╝██║░░░░░██║░░░███╗░░░███╗░░░
██╔══██║░╚██╔╝░░██╔═══╝░░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║╚════╝██╔══██╗██║░░░░░██║░░██╔═╝░░██╔═╝░░
██║░░██║░░░██║░░░██║░░░░░██║░░██║███████╗██║░░██║██║░╚███║██████╔╝░░░░░░██████╦╝███████╗██║███████╗███████╗
╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░░░░░░░╚═════╝░╚══════╝╚═╝╚══════╝╚══════╝
░░░░░░  ██████╗░███████╗██████╗░██████╗░██╗░░░░░██╗███████╗░█████╗░██████╗░██████╗░  ░░░░░░
░░░░░░  ██╔══██╗██╔════╝██╔══██╗██╔══██╗██║░░░░░██║╚════██║██╔══██╗██╔══██╗██╔══██╗  ░░░░░░
█████╗  ██████╔╝█████╗░░██║░░██║██████╦╝██║░░░░░██║░░░███╔═╝███████║██████╔╝██║░░██║  █████╗
╚════╝  ██╔══██╗██╔══╝░░██║░░██║██╔══██╗██║░░░░░██║░░██╔══╝░░██╔══██║██╔══██╗██║░░██║  ╚════╝
░░░░░░  ██║░░██║███████╗██████╔╝██████╦╝███████╗██║███████╗██║░░██║██║░░██║██████╔╝  ░░░░░░
░░░░░░  ╚═╝░░╚═╝╚══════╝╚═════╝░╚═════╝░╚══════╝╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░  ░░░░░░
EOF
    echo -e "${NC}"
    echo "Install script version 2.0 (2026 Edition)"
    echo "Developed by RedBlizard"
    echo ""
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
show_message() {
    local message="$1"
    local color="${2:-$NC}"
    echo -e "${color}${message}${NC}"
}

# Backup function with proper overwrite handling
backup() {
    local source_dir="$1"
    local dest_dir="$2"
    
    # Remove existing backup to prevent nesting
    if [ -d "$dest_dir" ]; then
        rm -rf "$dest_dir"
    fi
    
    mkdir -p "$(dirname "$dest_dir")"
    cp -r "$source_dir" "$dest_dir"
}

# ============================================================================
# SYSTEM CHECKS
# ============================================================================
check_cpu() {
    show_message "Performing CPU checks..." "$BLUE"
    
    local cpu_vendor
    cpu_vendor=$(grep -m1 "vendor_id" /proc/cpuinfo | awk '{print $3}')
    
    case "$cpu_vendor" in
        "AuthenticAMD")
            show_message "AMD CPU detected." "$GREEN"
            if ! pacman -Qi amd-ucode &> /dev/null; then
                show_message "Installing amd-ucode..." "$YELLOW"
                sudo pacman -S --noconfirm --needed amd-ucode
            fi
            ;;
        "GenuineIntel")
            show_message "Intel CPU detected." "$GREEN"
            if ! pacman -Qi intel-ucode &> /dev/null; then
                show_message "Installing intel-ucode..." "$YELLOW"
                sudo pacman -S --noconfirm --needed intel-ucode
            fi
            ;;
        *)
            show_message "Unknown CPU vendor: $cpu_vendor" "$YELLOW"
            ;;
    esac
}

# ============================================================================
# NVIDIA GPU HANDLING (Dec 2025 Update)
# ============================================================================
install_nvidia_drivers() {
    # Check if Nvidia GPU is present
    if ! lspci | grep -i "NVIDIA" &> /dev/null; then
        show_message "No Nvidia GPU detected. Skipping Nvidia installation." "$BLUE"
        return 0
    fi

    show_message "Nvidia GPU detected!" "$GREEN"
    
    # Detect GPU architecture via device ID
    local gpu_info device_id gpu_generation
    gpu_info=$(lspci -nn | grep -i "NVIDIA" | head -1)
    device_id=$(echo "$gpu_info" | grep -oP '\[\K[0-9a-f]{4}(?=\])' | tail -1)
    
    # Turing+ GPUs (RTX 20xx, 30xx, 40xx, GTX 1650+) = supported by nvidia-open
    # Pascal and older (GTX 10xx, 9xx) = need legacy driver (AUR)
    if [[ "$device_id" =~ ^(1e|1f|2[0-9a-f]) ]]; then
        gpu_generation="turing_or_newer"
    else
        gpu_generation="pascal_or_older"
    fi
    
    show_message "GPU Device ID: $device_id (${gpu_generation})" "$BLUE"
    
    if [[ "$gpu_generation" == "turing_or_newer" ]]; then
        # Modern GPU: nvidia-open from official repo
        show_message "Modern GPU detected → Installing nvidia-open (official repo)" "$GREEN"
        local nvidia_packages=("nvidia-open" "nvidia-utils" "lib32-nvidia-utils" "nvidia-settings" "libva-nvidia-driver")
        
        for package in "${nvidia_packages[@]}"; do
            if pacman -Qi "$package" &> /dev/null; then
                echo "$package is already installed."
            else
                sudo pacman -S --noconfirm --needed "$package" || {
                    show_message "Failed to install $package" "$RED"
                    return 1
                }
            fi
        done
        
    elif [[ "$gpu_generation" == "pascal_or_older" ]]; then
        # Legacy GPU: user choice
        show_message "⚠️  Legacy Nvidia GPU detected (Pascal or older)" "$RED"
        show_message "The official nvidia driver no longer supports your GPU." "$YELLOW"
        echo ""
        echo "Please choose your preferred driver:"
        echo "  1) nvidia-580xx-dkms (Legacy proprietary driver, AUR) - BEST PERFORMANCE"
        echo "  2) nouveau (Open-source driver) - LOWER PERFORMANCE"
        echo "  3) Skip Nvidia installation"
        echo ""
        read -rp "Enter choice [1/2/3]: " legacy_choice
        
        case "$legacy_choice" in
            1)
                show_message "Installing legacy nvidia-580xx-dkms from AUR..." "$BLUE"
                show_message "This may take several minutes to compile!" "$YELLOW"
                local legacy_packages=("nvidia-580xx-dkms" "nvidia-580xx-utils" "lib32-nvidia-580xx-utils" "nvidia-580xx-settings")
                
                for package in "${legacy_packages[@]}"; do
                    "$AUR_HELPER" -S --noconfirm --needed "$package" || {
                        show_message "Failed to install $package" "$RED"
                        return 1
                    }
                done
                ;;
            2)
                show_message "Removing Nvidia packages, using nouveau..." "$BLUE"
                sudo pacman -Rns --noconfirm nvidia nvidia-dkms nvidia-open 2>/dev/null || true
                echo "Nouveau will be used by default."
                ;;
            3)
                echo "Skipping Nvidia driver installation."
                ;;
            *)
                show_message "Invalid choice. Skipping Nvidia installation." "$RED"
                ;;
        esac
    fi
    
    # Configure Dracut for Nvidia (EndeavourOS Titan Neo uses Dracut)
    show_message "Configuring Dracut for Nvidia..." "$BLUE"
    local dracut_conf="/etc/dracut.conf.d/nvidia.conf"
    
    sudo tee "$dracut_conf" > /dev/null << 'EOF'
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOF
    
    # Add kernel parameter for modesetting
    if [ -f "/etc/default/grub" ] && ! grep -q "nvidia-drm.modeset=1" /etc/default/grub 2>/dev/null; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 nvidia-drm.modeset=1"/' /etc/default/grub
    fi
    
    # Regenerate grub config and initramfs
    if command -v grub-mkconfig &> /dev/null; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    sudo dracut -f --regenerate-all 2>/dev/null || sudo mkinitcpio -P 2>/dev/null || true
    
    show_message "Nvidia driver installation complete!" "$GREEN"
}

# ============================================================================
# BOOTLOADER CONFIGURATION
# ============================================================================
configure_bootloader() {
    show_message "Checking bootloader type..." "$BLUE"
    
    # Check for systemd-boot
    if [ -d "/efi/loader/entries" ] && [ -n "$(ls -A /efi/loader/entries/*.conf 2>/dev/null)" ]; then
        show_message "Systemd-boot is in use." "$GREEN"
        # Add nvidia_drm.modeset=1 to kernel parameters
        sudo sed -i 's/ options / options nvidia_drm.modeset=1 /' /efi/loader/entries/*.conf 2>/dev/null || true
        echo "Configuration modified for systemd-boot."
    elif [ -d "/boot/loader/entries" ]; then
        show_message "Systemd-boot detected in /boot." "$GREEN"
        sudo sed -i 's/ options / options nvidia_drm.modeset=1 /' /boot/loader/entries/*.conf 2>/dev/null || true
    elif [ -f "/etc/default/grub" ]; then
        show_message "GRUB detected." "$GREEN"
        # Nvidia modeset is handled in install_nvidia_drivers
    else
        show_message "Could not determine bootloader type." "$YELLOW"
    fi
}

# ============================================================================
# AUR HELPER SETUP
# ============================================================================
AUR_HELPER=""

setup_aur_helper() {
    show_message "Setting up AUR helper..." "$BLUE"
    
    local aur_helpers=("yay" "trizen" "paru")
    local found=false
    
    for helper in "${aur_helpers[@]}"; do
        if command -v "$helper" &> /dev/null; then
            AUR_HELPER="$helper"
            found=true
            show_message "Default AUR helper found: $AUR_HELPER" "$GREEN"
            break
        fi
    done
    
    if ! $found; then
        echo "Select an AUR helper:"
        select aur_helper_option in "${aur_helpers[@]}"; do
            case $REPLY in
                1) AUR_HELPER="yay" ;;
                2) AUR_HELPER="trizen" ;;
                3) AUR_HELPER="paru" ;;
                *) echo "Invalid option. Please try again."; continue ;;
            esac
            break
        done
        
        show_message "Installing $AUR_HELPER..." "$BLUE"
        
        # Clone and build the selected AUR helper
        local temp_dir="/tmp/$AUR_HELPER-build"
        rm -rf "$temp_dir"
        git clone "https://aur.archlinux.org/$AUR_HELPER.git" "$temp_dir"
        cd "$temp_dir"
        makepkg -si --noconfirm
        cd - > /dev/null
        rm -rf "$temp_dir"
    fi
}

# ============================================================================
# SHELL SWITCHING
# ============================================================================
switch_shell() {
    read -p "Choose your new shell:
1. Bash
2. Zsh
3. Fish
Enter the corresponding number (1/2/3): " new_shell_choice
    
    local new_shell=""
    case "$new_shell_choice" in
        1) new_shell="/bin/bash" ;;
        2) new_shell="/bin/zsh" ;;
        3) new_shell="/usr/bin/fish" ;;
        *) echo "Invalid option. Shell remains unchanged."; return ;;
    esac
    
    if [[ -n "$new_shell" ]]; then
        local shell_name="${new_shell##*/}"
        if ! command -v "$shell_name" &> /dev/null; then
            sudo pacman -S --noconfirm --needed "$shell_name"
        fi
        
        if chsh -s "$new_shell"; then
            echo "Shell changed successfully to $shell_name."
        else
            echo "Changing shell failed." >&2
        fi
    fi
}

# ============================================================================
# DOTFILES MANAGEMENT
# ============================================================================
setup_dotfiles() {
    show_message "Setting up dotfiles..." "$BLUE"
    
    local DOTFILES_DIR="$HOME/hyprland-dots"
    mkdir -p "$DOTFILES_DIR"
    
    local REPOS=(
        "https://github.com/RedBlizard/Hyprland-blizz.git"
        "https://github.com/RedBlizard/hypr-welcome.git"
        "https://github.com/RedBlizard/hypr-waybar.git"
    )
    
    export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
    
    # Clone or update repositories
    for repo in "${REPOS[@]}"; do
        local repo_name repo_dir
        repo_name=$(basename "$repo" .git)
        repo_dir="$DOTFILES_DIR/$repo_name"
        
        if [ ! -d "$repo_dir" ]; then
            show_message "Cloning $repo_name repository..." "$BLUE"
            git clone "$repo" "$repo_dir" || {
                show_message "Failed to clone $repo_name repository." "$RED"
                exit 1
            }
        else
            cd "$repo_dir" || exit 1
            show_message "Pulling latest changes from $repo_name..." "$BLUE"
            if ! git pull origin main; then
                show_message "Failed to pull $repo_name repository." "$RED"
                exit 1
            fi
            cd - > /dev/null
        fi
    done
    
    # Ask user if they want to install
    read -rp "$(tput setaf 4)Do you want to start the installation? (Yy/Nn): $(tput sgr0)" update_choice
    
    if [[ ! "$update_choice" =~ ^[Yy]$ ]]; then
        show_message "Installation cancelled by user." "$YELLOW"
        exit 0
    fi
    
    # Backup existing configs
    local username backup_dir
    username=$(whoami)
    backup_dir="/home/$username/.config/backup"
    mkdir -p "$backup_dir"
    
    local folders=("alacritty" "btop" "cava" "dunst" "hypr" "hypr-welcome" "kitty" "Kvantum" 
                   "networkmanager-dmenu" "nwg-look" "pacseek" "pipewire" "qt6ct" "ranger" 
                   "sddm-config-editor" "systemd" "Thunar" "waybar" "wlogout" "wofi" 
                   "xsettingsd" "gtk-2.0" "gtk-3.0" "gtk-4.0" "starship" "swaync")
    
    show_message "Creating backups of existing configurations..." "$YELLOW"
    for folder in "${folders[@]}"; do
        local folder_path="/home/$username/.config/$folder"
        local backup_path="$backup_dir/$folder"
        if [ -d "$folder_path" ]; then
            backup "$folder_path" "$backup_path"
            echo "Backed up: $folder"
        fi
    done
    
    # Copy dotfiles from repositories
    show_message "Installing dotfiles from Hyprland-blizz..." "$BLUE"
    cp -r "$DOTFILES_DIR/Hyprland-blizz"/* ~/ 2>/dev/null || true
    cp -r "$DOTFILES_DIR/Hyprland-blizz"/.icons ~/ 2>/dev/null || true
    cp -r "$DOTFILES_DIR/Hyprland-blizz"/.Kvantum-themes ~/ 2>/dev/null || true
    cp -r "$DOTFILES_DIR/Hyprland-blizz"/.local ~/ 2>/dev/null || true
    cp -r "$DOTFILES_DIR/Hyprland-blizz"/Pictures ~/ 2>/dev/null || true
    cp -r "$DOTFILES_DIR/Hyprland-blizz"/.config ~/ 2>/dev/null || true
    
    show_message "Installing dotfiles from hypr-welcome..." "$BLUE"
    cp -r "$DOTFILES_DIR/hypr-welcome"/.config ~/ 2>/dev/null || true
    
    show_message "Installing dotfiles from hypr-waybar..." "$BLUE"
    cp -r "$DOTFILES_DIR/hypr-waybar"/.config ~/ 2>/dev/null || true
    
    show_message "Dotfiles installation complete!" "$GREEN"
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================
install_packages() {
    show_message "Installing packages..." "$BLUE"
    
    # Enable parallel downloads in pacman
    if [ -f "/etc/pacman.conf" ]; then
        sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf 2>/dev/null || true
    fi
    
    local packages_file="$SCRIPT_DIR/packages-repository.txt"
    
    if [ ! -f "$packages_file" ]; then
        show_message "packages-repository.txt not found!" "$RED"
        return 1
    fi
    
    # Extract and install official Arch packages
    local arch_packages
    arch_packages=$(awk '/^# AUR/ {exit} /^[^#]/ && NF {print $1}' "$packages_file" | tr '\n' ' ')
    
    if [ -n "$arch_packages" ]; then
        show_message "Installing official Arch packages..." "$BLUE"
        sudo pacman -Sy --noconfirm --needed $arch_packages || {
            show_message "Some Arch packages failed to install." "$RED"
        }
    fi
    
    # Extract and install AUR packages
    local aur_packages
    aur_packages=$(awk '/^# AUR/ {p=1; next} /^[^#]/ && NF && p {print $1}' "$packages_file" | tr '\n' ' ')
    
    if [ -n "$aur_packages" ]; then
        show_message "Installing AUR packages..." "$BLUE"
        $AUR_HELPER -S --noconfirm --needed $aur_packages || {
            show_message "Some AUR packages failed to install." "$RED"
        }
    fi
    
    show_message "Package installation complete!" "$GREEN"
}

# ============================================================================
# BTRFS SPECIFIC SETUP
# ============================================================================
setup_btrfs() {
    local filesystem_type
    filesystem_type=$(findmnt -n -o FSTYPE / 2>/dev/null || echo "unknown")
    
    if [ "$filesystem_type" != "btrfs" ]; then
        show_message "Filesystem is not Btrfs. Skipping Btrfs-specific setup." "$BLUE"
        return 0
    fi
    
    show_message "Btrfs filesystem detected. Installing Btrfs tools..." "$GREEN"
    local btrfs_packages=("snapper" "snap-pac" "snapper-rollback" "btrfs-assistant" "btrfsmaintenance")
    
    for package in "${btrfs_packages[@]}"; do
        if ! pacman -Qi "$package" &> /dev/null; then
            $AUR_HELPER -S --noconfirm --needed "$package" || {
                show_message "Failed to install $package" "$YELLOW"
            }
        fi
    done
}

# ============================================================================
# SDDM SETUP
# ============================================================================
setup_sddm() {
    show_message "Setting up SDDM..." "$BLUE"
    
    # Remove GDM if present
    if pacman -Qi gdm &> /dev/null 2>&1; then
        show_message "GDM detected. Removing..." "$YELLOW"
        sudo pacman -Rdd --noconfirm gdm 2>/dev/null || true
    fi
    
    # Disable LightDM if present
    if command -v lightdm &> /dev/null; then
        show_message "Disabling LightDM..." "$YELLOW"
        sudo systemctl disable lightdm 2>/dev/null || true
    fi
    
    # Install SDDM if not present
    if ! pacman -Qi sddm &> /dev/null 2>&1; then
        sudo pacman -S --noconfirm --needed sddm
    fi
    
    # Enable SDDM
    sudo systemctl enable sddm 2>/dev/null || true
    
    # Copy SDDM configuration
    if [ -f "$HOME/hyprland-dots/Hyprland-blizz/sddm.conf" ]; then
        sudo cp -f "$HOME/hyprland-dots/Hyprland-blizz/sddm.conf" /etc/
    fi
    
    # Set SDDM theme
    read -p "Do you want to set the SDDM theme to 'simplicity'? (Yy/Nn): " set_theme
    if [[ "$set_theme" =~ ^[Yy]$ ]]; then
        sudo sed -i "s/^Current=.*/Current=simplicity/" /etc/sddm.conf 2>/dev/null || true
        
        # Copy SDDM theme images
        if [ -d "$HOME/hyprland-dots/Hyprland-blizz/sddm-images" ]; then
            sudo mkdir -p /usr/share/sddm/themes/simplicity/images
            sudo cp -r "$HOME/hyprland-dots/Hyprland-blizz/sddm-images"/* /usr/share/sddm/themes/simplicity/images/ 2>/dev/null || true
        fi
    fi
    
    show_message "SDDM setup complete!" "$GREEN"
}

# ============================================================================
# THEMING SETUP
# ============================================================================
setup_theming() {
    show_message "Setting up themes and icons..." "$BLUE"
    
    # Set Qt environment variables
    if [ -f "/etc/environment" ]; then
        sudo sed -i '/^#*QT_QPA_PLATFORMTHEME=/d' /etc/environment
        sudo sed -i '/^#*QT_STYLE_OVERRIDE=/d' /etc/environment
        echo "QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment >/dev/null
        echo "QT_STYLE_OVERRIDE=kvantum" | sudo tee -a /etc/environment >/dev/null
    fi
    
    # Set Kvantum theme for user
    if command -v kvantummanager &> /dev/null; then
        kvantummanager --set Catppuccin-Frappe-Blue 2>/dev/null || true
    fi
    
    # Set GTK theme
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.wm.preferences theme "Colloid-Dark-Catppuccin" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
    fi
    
    # Set Papirus folder colors
    if command -v papirus-folders &> /dev/null; then
        papirus-folders -C cat-frappe-blue --theme Papirus-Dark 2>/dev/null || true
    fi
    
    # Install Colloid GTK theme
    local GTK_THEME_DIR="$HOME/Colloid-gtk-theme"
    if [ ! -d "$GTK_THEME_DIR" ]; then
        git clone https://github.com/RedBlizard/Colloid-gtk-theme.git "$GTK_THEME_DIR" 2>/dev/null || true
    fi
    
    if [ -d "$GTK_THEME_DIR" ]; then
        cd "$GTK_THEME_DIR"
        sudo ./install.sh --theme all --tweaks catppuccin --dest /usr/share/themes 2>/dev/null || true
        cd - > /dev/null
    fi
    
    # Set cursor theme
    echo "export XCURSOR_THEME=Qogir-dark" | sudo tee -a /etc/environment 2>/dev/null || true
    echo "export XCURSOR_SIZE=24" | sudo tee -a /etc/environment 2>/dev/null || true
    
    show_message "Theming setup complete!" "$GREEN"
}

# ============================================================================
# FONT INSTALLATION
# ============================================================================
install_fonts() {
    show_message "Installing custom fonts..." "$BLUE"
    
    local fonts_temp="/tmp/hypr_blizz_fonts"
    rm -rf "$fonts_temp"
    
    if git clone https://github.com/RedBlizard/hypr-blizz-fonts.git "$fonts_temp" 2>/dev/null; then
        sudo cp -r "$fonts_temp"/* /usr/share/fonts/ 2>/dev/null || true
        sudo fc-cache -f -v
        rm -rf "$fonts_temp"
        show_message "Fonts installed successfully!" "$GREEN"
    else
        show_message "Failed to clone fonts repository." "$YELLOW"
    fi
}

# ============================================================================
# FIREWALL SETUP
# ============================================================================
setup_firewall() {
    if ! command -v firewalld &> /dev/null; then
        show_message "No firewall detected." "$YELLOW"
        read -p "Do you want to install firewalld? (Yy/Nn): " choice
        
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            sudo pacman -S --noconfirm --needed firewalld
            sudo systemctl enable --now firewalld
            show_message "Firewalld installed and enabled." "$GREEN"
        fi
    else
        show_message "Firewalld is already installed." "$GREEN"
    fi
}

# ============================================================================
# BROWSER SETUP
# ============================================================================
setup_browser() {
    show_message "Checking default browser..." "$BLUE"
    
    local default_browser
    default_browser=$(xdg-settings get default-web-browser 2>/dev/null | sed 's/\.desktop$//' || echo "unknown")
    echo "Current default browser: $default_browser"
    
    read -p "Do you want to switch to a different browser? (y/n): " switch_choice
    
    if [[ "$switch_choice" =~ ^[Yy]$ ]]; then
        echo "Select a browser to install:"
        echo "1. Chromium"
        echo "2. Firefox"
        echo "3. Brave"
        echo "4. Microsoft Edge"
        echo "5. Vivaldi"
        read -p "Enter choice: " new_choice
        
        local new_browser=""
        case $new_choice in
            1) new_browser="chromium" ;;
            2) new_browser="firefox" ;;
            3) new_browser="brave-bin" ;;
            4) new_browser="microsoft-edge-stable-bin" ;;
            5) new_browser="vivaldi" ;;
            *) echo "Invalid choice."; return ;;
        esac
        
        if [[ "$new_browser" == *"-bin" ]]; then
            $AUR_HELPER -S --noconfirm --needed "$new_browser"
        else
            sudo pacman -S --noconfirm --needed "$new_browser"
        fi
        
        xdg-settings set default-web-browser "${new_browser}.desktop" 2>/dev/null || true
        echo "$new_browser is now the default browser."
    fi
}

# ============================================================================
# SYMLINK SETUP
# ============================================================================
setup_symlinks() {
    show_message "Setting up symlinks..." "$BLUE"
    
    local scripts_dir="$HOME/.config/hypr-welcome/scripts"
    
    # Ensure scripts directory exists
    if [ ! -d "$scripts_dir" ]; then
        show_message "Scripts directory not found: $scripts_dir" "$RED"
        return 1
    fi
    
    # Make scripts executable
    chmod +x "$scripts_dir"/*.sh 2>/dev/null || true
    chmod +x "$scripts_dir/hypr-welcome" 2>/dev/null || true
    chmod +x "$scripts_dir/hypr-eos-kill-yad-zombies" 2>/dev/null || true
    
    # Create symlinks in /usr/bin
    local symlinks=(
        "hypr-welcome"
        "hypr-eos-kill-yad-zombies"
        "hypr_check_updates"
    )
    
    for link in "${symlinks[@]}"; do
        local source_file="$scripts_dir/$link"
        local target="/usr/bin/$link"
        
        # Add .sh extension if needed
        if [ ! -f "$source_file" ] && [ -f "$scripts_dir/${link}.sh" ]; then
            source_file="$scripts_dir/${link}.sh"
        fi
        
        if [ -f "$source_file" ]; then
            sudo ln -sf "$source_file" "$target"
            echo "Created symlink: $target -> $source_file"
        fi
    done
    
    # Set XDG menu prefix
    echo 'XDG_MENU_PREFIX=arch-' | sudo tee -a /etc/environment >/dev/null 2>&1 || true
    
    show_message "Symlinks setup complete!" "$GREEN"
}

# ============================================================================
# SYSTEMD USER SERVICES
# ============================================================================
setup_user_services() {
    show_message "Enabling user services..." "$BLUE"
    
    # Enable hypridle if available
    if systemctl --user list-unit-files 2>/dev/null | grep -q "hypridle.service"; then
        systemctl --user enable --now hypridle.service 2>/dev/null || true
    fi
    
    show_message "User services setup complete!" "$GREEN"
}

# ============================================================================
# CLEANUP
# ============================================================================
cleanup() {
    show_message "Cleaning up installation files..." "$BLUE"
    
    # Remove installation artifacts from home directory
    rm -rf "$HOME/hyprland-installation" 2>/dev/null || true
    rm -f "$HOME/installation_log.txt" 2>/dev/null || true
    
    show_message "Cleanup complete!" "$GREEN"
}

# ============================================================================
# FINAL MESSAGE
# ============================================================================
show_completion_message() {
    echo -e "${RED}"
    cat <<"EOF"
░██╗░░░░░░░██╗███████╗██╗░░░░░░█████╗░░█████╗░███╗░░░███╗███████╗  ████████╗░█████╗░
░██║░░██╗░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗████╗░████║██╔════╝  ╚══██╔══╝██╔══██╗
░╚██╗████╗██╔╝█████╗░░██║░░░░░██║░░╚═╝██║░░██║██╔████╔██║█████╗░░  ░░░██║░░░██║░░██║
░░████╔═████║░██╔══╝░░██║░░░░░██║░░██╗██║░░██║██║╚██╔╝██║██╔══╝░░  ░░░██║░░░██║░░██║
░░╚██╔╝░╚██╔╝░███████╗███████╗╚█████╔╝╚█████╔╝██║░╚═╝░░██║███████╗  ░░░██║░░░╚█████╔╝
░░░╚═╝░░░╚═╝░╚══════╝╚══════╝╚════╝░╚════╝░╚═╝░░░░░╚═╝╚══════╝  ░░░╚═╝░░░░╚════╝░
EOF
    echo -e "${NC}"
    echo ""
    show_message "Your system is now configured with Hyprland!" "$GREEN"
    echo ""
    echo "Next steps:"
    echo "  1. Open ~/.config/hypr/hyprland.conf to change your keyboard layout (default: us)"
    echo "  2. Adjust your monitor configuration in ~/.config/hypr/conf/monitor.conf"
    echo "  3. Customize keybinds in ~/.config/hypr/conf/keybinds.conf"
    echo ""
    echo -e "${YELLOW}NVIDIA USERS:${NC}"
    echo "  - Open ~/.config/hypr/conf/env_var.conf"
    echo "  - Remove the comment (#) in front of NVIDIA env rules"
    echo "  - Add a comment (#) in front of: env=WLR_NO_HARDWARE_CURSORS=1"
    echo ""
    show_message "Reboot your system to complete the installation!" "$RED"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
main() {
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    cd "$SCRIPT_DIR" || exit 1
    
    # Show welcome banner
    show_banner
    
    # System checks
    check_cpu
    configure_bootloader
    
    # Setup AUR helper (must be before Nvidia installation)
    setup_aur_helper
    
    # Install Nvidia drivers (after AUR helper is ready)
    install_nvidia_drivers
    
    # Setup dotfiles
    setup_dotfiles
    
    # Install packages
    install_packages
    
    # Btrfs specific setup
    setup_btrfs
    
    # Setup SDDM
    setup_sddm
    
    # Install fonts
    install_fonts
    
    # Setup theming
    setup_theming
    
    # Setup firewall
    setup_firewall
    
    # Setup browser
    setup_browser
    
    # Setup symlinks
    setup_symlinks
    
    # Setup user services
    setup_user_services
    
    # Cleanup
    cleanup
    
    # Show completion message
    show_completion_message
}

# Run main function
main "$@"
