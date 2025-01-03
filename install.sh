#!/bin/bash

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

echo -e "${RED}"
cat <<"EOF"

██╗░░██╗██╗░░░██╗██████╗░██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░░░░░░░██████╗░██╗░░░░░██╗███████╗███████╗
██║░░██║╚██╗░██╔╝██╔══██╗██╔══██╗██║░░░░░██╔══██╗████╗░██║██╔══██╗░░░░░░██╔══██╗██║░░░░░██║╚════██║╚════██║
███████║░╚████╔╝░██████╔╝██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║█████╗██████╦╝██║░░░░░██║░░███╔═╝░░███╔═╝
██╔══██║░░╚██╔╝░░██╔═══╝░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║╚════╝██╔══██╗██║░░░░░██║██╔══╝░░██╔══╝░░
██║░░██║░░░██║░░░██║░░░░░██║░░██║███████╗██║░░██║██║░╚███║██████╔╝░░░░░░██████╦╝███████╗██║███████╗███████╗
╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░░░░░░░╚═════╝░╚══════╝╚═╝╚══════╝╚══════╝

░░░░░░  ██████╗░███████╗██████╗░██████╗░██╗░░░░░██╗███████╗░█████╗░██████╗░██████╗░  ░░░░░░
░░░░░░  ██╔══██╗██╔════╝██╔══██╗██╔══██╗██║░░░░░██║╚════██║██╔══██╗██╔══██╗██╔══██╗  ░░░░░░
█████╗  ██████╔╝█████╗░░██║░░██║██████╦╝██║░░░░░██║░░███╔═╝███████║██████╔╝██║░░██║  █████╗
╚════╝  ██╔══██╗██╔══╝░░██║░░██║██╔══██╗██║░░░░░██║██╔══╝░░██╔══██║██╔══██╗██║░░██║  ╚════╝
░░░░░░  ██║░░██║███████╗██████╔╝██████╦╝███████╗██║███████╗██║░░██║██║░░██║██████╔╝  ░░░░░░
░░░░░░  ╚═╝░░╚═╝╚══════╝╚═════╝░╚═════╝░╚══════╝╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░  ░░░░░░
EOF
echo -e "${NONE}"

echo "Install script version release 1.07"
echo "Developed by RedBlizard date 10 December 2023"

# ---------------------
# Set the log file path
# ---------------------
log_file="$HOME/installation_log.txt"

# --------------------------------------------------
# Redirect stdout (1) and stderr (2) to the log file
# --------------------------------------------------
exec > >(tee -i "$log_file") 2>&1

# ------------------------------------------------------
# Making a backup of main configs in .config
# ------------------------------------------------------

# Backup and copy .config folder

# Get the current username
username=$(whoami)

# Create a backup directory if it doesn't exist
backup_dir="/home/$username/.config/backup"
mkdir -p "$backup_dir"

# Function to backup a directory
backup() {
    local source_dir="$1"
    local dest_dir="$2"
    
    # Create the destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Copy the contents of the source directory to the destination directory
    cp -r "$source_dir" "$dest_dir"
}

# List of folders to backup
folders=("alacritty" "btop" "cava" "dunst" "hypr" "kitty" "Kvantum" "networkmanager-dmenu" "nwg-look" "pacseek" "pipewire" "qt6ct" "ranger" "sddm-config-editor" "systemd" "Thunar" "waybar" "wlogout" "wofi" "xsettingsd" "gtk-2.0" "gtk-3.0" "gtk-4.0" "starship")

# Backup and copy each folder
for folder in "${folders[@]}"; do
    folder_path="/home/$username/.config/$folder"
    backup_path="$backup_dir/$folder"
    
    # Check if the folder exists
    if [ -d "$folder_path" ]; then
        # Backup the folder
        backup "$folder_path" "$backup_path"
    else
        # Create the folder and then backup
        mkdir -p "$folder_path"
        backup "$folder_path" "$backup_path"
    fi
done

# Ensure the script is in the correct directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || { echo 'Failed to change directory to script directory.'; exit 1; }

# Redirect CPU info checks to /dev/null to hide the output

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Display welcome message
echo -e "${BLUE}Welcome to the Hyprland-Blizz installer!${NC}"

# Perform system checks
echo -e "${BLUE}Performing system checks...${NC}"

# Trim whitespaces from the CPU vendor
cpu_info=$(lscpu)

# Debug print to check CPU info
#echo "CPU Info: $cpu_info"

# ---------------------------------------------------------------------
# Check CPU vendor and execute AMD-specific code if AMD CPU is detected
# ---------------------------------------------------------------------

if [ "$cpu_vendor" == "AuthenticAMD" ]; then
    echo -e "${GREEN}AMD CPU detected.${NC} Running AMD-specific code..."

    # Check if amd-ucode is installed
    if echo "$cpu_info" | grep -qi "AuthenticAMD"; then
        echo "amd-ucode is installed."
        # Add your AMD-specific code here
    else
        echo "amd-ucode is not installed. Please install it for optimal performance."
        # Add code to install amd-ucode if desired
    fi
fi

# -------------------------------------------------------------------
# Check CPU vendor and execute INTEL-specific code if CPU is detected
# -------------------------------------------------------------------

if [ "$cpu_vendor" == "GenuineIntel" ]; then
    echo -e "${GREEN}INTEL CPU detected.${NC} Running INTEL-specific code..."

    # Check if intel-ucode is installed
    if pacman -Qi intel-ucode &> /dev/null; then
        echo "intel-ucode is installed."
        # Add your INTEL-specific code here
    else
        echo "intel-ucode is not installed. Please install it for optimal performance."
        # Add code to install intel-ucode if desired
    fi
fi

# ------------------------------------------------------
# Check if Nvidia GPU is present
# ------------------------------------------------------
if lspci | grep -i "NVIDIA" &> /dev/null; then
    echo -e "${GREEN}Nvidia GPU detected.${NC} Installing Nvidia packages..."

    # Install Nvidia-specific packages
    nvidia_packages=("libva" "libva-nvidia-driver-git")

    for package in "${nvidia_packages[@]}"; do
        if pacman -Qi "$package" &> /dev/null; then
            echo "$package is already installed. Skipping."
        else
            # Install the package
            if yay -S --noconfirm "$package"; then
                echo "$package installed."
            else
                echo "Failed to install $package. Manual intervention may be required."
                exit 1
            fi
        fi
    done
else
    echo "No Nvidia GPU detected. Skipping installation of Nvidia-specific packages."
fi

# ------------------------------------------------------
# Check bootloader type
# ------------------------------------------------------
loader_entries="/efi/loader/entries"
if [ -d "$loader_entries" ] && [ -n "$(ls -A "$loader_entries"/*.conf 2>/dev/null)" ]; then
    # Systemd-boot detected
    echo -e "${GREEN}Systemd-boot is in use.${NC}"

    # Add nvidia_drm.modeset=1 to the kernel parameters
    # This is an example, modify it based on your specific requirements
    sed -i 's/ options / options nvidia_drm.modeset=1 /' $loader_entries/*.conf

    echo "Configuration modified for systemd-boot."
elif [ -f "/etc/kernel/install.d/90-loaderentry.install" ]; then
    # Bootloader is systemd-boot, modify configuration
    echo -e "${GREEN}Detected systemd-boot.${NC} Modifying configuration..."

    # Add nvidia_drm.modeset=1 to the kernel parameters
    # This is an example, modify it based on your specific requirements
    sed -i 's/ options / options nvidia_drm.modeset=1 /' /boot/loader/entries/*.conf

    echo "Configuration modified for systemd-boot."
else
    # No systemd-boot detected, assuming GRUB or another bootloader
    echo -e "${GREEN}GRUB or another bootloader may be in use.${NC}"
fi

# -------------------------
# Check if Git is installed
# -------------------------
echo -e "${ORANGE}Checking if Git is installed...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${ORANGE}Git is not installed. Installing Git...${NC}"
    sudo pacman -Sy --noconfirm git || { echo 'Installation of Git failed.'; exit 1; }
else
    echo "Git is already installed."
fi


switch_shell() {
    read -p "Choose your new shell:
    1. Bash
    2. Zsh
    3. Fish
    Enter the corresponding number (1/2/3): " new_shell_choice

    case "$new_shell_choice" in
        1) new_shell="/bin/bash" ;;
        2) new_shell="/bin/zsh" ;;
        3) new_shell="/usr/bin/fish" ;;
        *) echo "Invalid option. Shell remains unchanged." ;;
    esac

    if [[ -n "$new_shell" ]]; then
        if ! command -v "${new_shell##*/}" &> /dev/null; then
            # Install the selected shell if not already installed
            sudo pacman -S --noconfirm "${new_shell##*/}"
        fi

        if chsh -s "$new_shell"; then
            echo "Shell changed successfully."
        else
            echo "Changing shell failed." >&2
        fi
    fi
}

# Function to switch root shell
switch_shell_as_root() {
    read -p "Choose the root shell:
    1. Bash
    2. Zsh
    3. Fish
    Enter the corresponding number (1/2/3): " new_root_shell_choice

    case "$new_root_shell_choice" in
        1) new_root_shell="/bin/bash" ;;
        2) new_root_shell="/bin/zsh" ;;
        3) new_root_shell="/usr/bin/fish" ;;
        *) echo "Invalid option. Root shell remains unchanged." ;;
    esac

    if [[ -n "$new_root_shell" ]]; then
        if sudo chsh -s "$new_root_shell" root; then
            echo "Root shell changed successfully."
        else
            echo "Changing root shell failed." >&2
        fi
    fi
}

# Prompt user to switch shell for the current user
echo -e "${BLUE}Now we are checking which shell is used on the system.${NC}"
current_shell=$(basename "$SHELL")
echo "Current shell: $current_shell"

# Prompt user to switch shell for the current user
read -p "Do you want to switch your shell? (y/n): " switch_user_shell
if [ "$switch_user_shell" == "y" ]; then
    switch_shell
fi

# Prompt for changing the root shell
read -p "Do you want to switch the root shell? (y/n): " switch_root_shell
if [ "$switch_root_shell" == "y" ]; then
    switch_shell_as_root
fi

#
# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

echo -e "${RED}"
cat <<"EOF"

████████╗██╗░░██╗███████╗
╚══██╔══╝██║░░██║██╔════╝
░░░██║░░░███████║█████╗░░
░░░██║░░░██╔══██║██╔══╝░░
░░░██║░░░██║░░██║███████╗
░░░╚═╝░░░╚═╝░░╚═╝╚══════╝

██╗███╗░░██╗░██████╗████████╗░█████╗░██╗░░░░░██╗░░░░░░█████╗░████████╗██╗░█████╗░███╗░░██╗  ██╗░██████╗
██║████╗░██║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║  ██║██╔════╝
██║██╔██╗██║╚█████╗░░░░██║░░░███████║██║░░░░░██║░░░░░███████║░░░██║░░░██║██║░░██║██╔██╗██║  ██║╚█████╗░
██║██║╚████║░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░░░░██╔══██║░░░██║░░░██║██║░░██║██║╚████║  ██║░╚═══██╗
██║██║░╚███║██████╔╝░░░██║░░░██║░░██║███████╗███████╗██║░░██║░░░██║░░░██║╚█████╔╝██║░╚███║  ██║██████╔╝
╚═╝╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝  ╚═╝╚═════╝░

░██████╗████████╗░█████╗░██████╗░████████╗██╗███╗░░██╗░██████╗░░░░░░░░░░
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░░░░░░░░░░
╚█████╗░░░░██║░░░███████║██████╔╝░░░██║░░░██║██╔██╗██║██║░░██╗░░░░░░░░░░
░╚═══██╗░░░██║░░░██╔══██║██╔══██╗░░░██║░░░██║██║╚████║██║░░╚██╗░░░░░░░░░
██████╔╝░░░██║░░░██║░░██║██║░░██║░░░██║░░░██║██║░╚███║╚██████╔╝██╗██╗██╗
╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░╚═╝╚═╝╚═╝
EOF
echo -e "${NONE}"


echo ""
echo "   Please Backup existing configurations if needed !!"
echo ""

# -----------------------
# Getting in the dotfiles
# -----------------------

# Define colors for messages
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Function to show messages
show_message() {
    message=$1
    color=$2
    echo -e "${color}${message}${NC}"
}

echo -e "${BLUE}Now we are getting in the dotfiles. Please be patient, this might take a while.${NC}"

# Ensure the hyprland-dots directory exists
DOTFILES_DIR="$HOME/hyprland-dots"
mkdir -p "$DOTFILES_DIR"

# Repositories to clone
REPOS=(
    "https://github.com/RedBlizard/Hyprland-blizz.git"
    "https://github.com/RedBlizard/hypr-welcome.git"
    "https://github.com/RedBlizard/hypr-waybar.git"
)

# Set GIT_DISCOVERY_ACROSS_FILESYSTEM if needed
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# Clone or update the repositories
for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    repo_dir="$DOTFILES_DIR/$repo_name"

    if [ ! -d "$repo_dir" ]; then
        show_message "Cloning $repo_name repository..." "$BLUE"
        git clone "$repo" "$repo_dir" || { show_message "Failed to clone $repo_name repository." "$RED"; exit 1; }
    else
        cd "$repo_dir" || { show_message "Failed to change to directory $repo_dir." "$RED"; exit 1; }
        show_message "Pulling the latest changes from the $repo_name repository..." "$BLUE"
        if ! git pull origin main; then
            show_message "Failed to pull $repo_name repository." "$RED"
            exit 1
        fi
    fi
done

# Check for updates in each repository
updates_available=false
for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    repo_dir="$DOTFILES_DIR/$repo_name"

    if cd "$repo_dir" && git fetch origin main && [ "$(git rev-list --count HEAD..origin/main)" -gt 0 ]; then
        updates_available=true
        show_message "Updates are available for $repo_name repository." "$BLUE"
    fi
done

if [ "$updates_available" = true ]; then
    show_message "Updates are available for one or more repositories." "$BLUE"
else
    show_message "No updates available for the repositories." "$BLUE"
fi

read -rp "$(tput setaf 4)Do you want to start the installation? (Enter 'Yy' for yes or 'Nn' for no): $(tput sgr0)" update_choice

if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # Copy dotfiles and directories from Hyprland-blizz to home directory
    show_message "Updating dotfiles from Hyprland-blizz..." "$BLUE"
    cp -r "$HOME/hyprland-dots/Hyprland-blizz"/* ~/ || { show_message "Failed to update dotfiles from Hyprland-blizz." "$RED"; exit 1; }
    cp -r "$HOME/hyprland-dots/Hyprland-blizz"/.icons ~/ || { show_message "Failed to update .icons from Hyprland-blizz." "$RED"; exit 1; }
    cp -r "$HOME/hyprland-dots/Hyprland-blizz"/.Kvantum-themes ~/ || { show_message "Failed to update .Kvantum-themes from Hyprland-blizz." "$RED"; exit 1; }
    cp -r "$HOME/hyprland-dots/Hyprland-blizz"/.local ~/ || { show_message "Failed to update .local from Hyprland-blizz." "$RED"; exit 1; }
    cp -r "$HOME/hyprland-dots/Hyprland-blizz"/Pictures ~/ || { show_message "Failed to update Pictures from Hyprland-blizz." "$RED"; exit 1; }
    cp -r "$HOME/hyprland-dots/Hyprland-blizz"/.config ~/ || { show_message "Failed to update .config from Hyprland-blizz." "$RED"; exit 1; }

    # Copy dotfiles and directories from hypr-welcome to home directory
    show_message "Updating dotfiles from hypr-welcome..." "$BLUE"
    cp -r "$HOME/hyprland-dots/hypr-welcome"/.config ~/ || { show_message "Failed to update .config from hypr-welcome." "$RED"; exit 1; }

    # Copy dotfiles and directories from hypr-waybar to home directory
    show_message "Updating dotfiles from hypr-waybar..." "$BLUE"
    cp -r "$HOME/hyprland-dots/hypr-waybar"/.config ~/ || { show_message "Failed to update .config from hypr-waybar." "$RED"; exit 1; }
else
    show_message "No dotfiles update performed." "$BLUE"
    exit 0
fi


# ------------------------------------------------------
# Check filesystem type
# ------------------------------------------------------
filesystem_type=$(findmnt -n -o FSTYPE /)

if [ "$filesystem_type" != "btrfs" ]; then
    echo "Filesystem is not Btrfs. Skipping installation of Btrfs-specific packages."
else
    # -------------------------------
    # Install Btrfs-specific packages
    # -------------------------------
    
    btrfs_packages=("snapper" "snap-pac" "snapper-rollback" "btrfs-assistant" "btrfsmaintenance")

    for package in "${btrfs_packages[@]}"; do
        if pacman -Qi "$package" &> /dev/null; then
            echo "$package is already installed. Skipping."
        else
        
            # -------------------
            # Install the package
            # -------------------
            if yay -S --noconfirm "$package"; then
                echo "$package installed."
            else
                echo "Failed to install $package. Manual intervention may be required."
                exit 1
            fi
        fi
    done
fi

# ------------------------------------------------------
# Check if plasma-desktop is installed
# ------------------------------------------------------

if pacman -Qs "plasma-desktop" &> /dev/null; then
    echo "Plasma desktop is installed. Skipping installation of breeze-icons."
else
    # ----------------------------------------------------
    # Install breeze-icons and breeze-default-cursor-theme
    # ----------------------------------------------------
    
    breeze_packages=("breeze-icons")

    for package in "${breeze_packages[@]}"; do
        if pacman -Qi "$package" &> /dev/null; then
            echo "$package is already installed. Skipping."
        else
           
            # -------------------
            # Install the package
            # -------------------
            
            if yay -S --noconfirm "$package"; then
                echo "$package installed."
            else
                echo "Failed to install $package. Manual intervention may be required."
                exit 1
            fi
        fi
    done
fi

# ------------------------------------------------------
# Check if GNOME desktop environment is installed
# ------------------------------------------------------

if pacman -Qs gnome &> /dev/null; then

    # ---------------------------------------
    # Check if GDM is installed and remove it
    # ---------------------------------------
    
    if pacman -Qi gdm &> /dev/null; then
        echo "GDM detected. Removing GDM..."
        sudo pacman -Rdd --noconfirm gdm

        # ---------------------
        # Install sddm from AUR
        # ---------------------
        
        if ! yay -Qi sddm &> /dev/null; then
            if yay -S --noconfirm sddm; then                
        echo -e "${BLUE}SDDM installed.${NC}"
            else
                echo "Failed to install sddm. Exiting."
                exit 1
            fi
        else
            echo "sddm is already installed."
        fi
    else
        echo "GDM not detected. Skipping removal and installation of sddm."
    fi
else
    echo "GNOME desktop environment not detected. Skipping removal and installation of sddm."
fi

# ---------------------------------------
# Check if SDDM configuration file exists
# ---------------------------------------
sddm_conf="/etc/sddm.conf"
if [ ! -f "$sddm_conf" ]; then

    # ----------------------
    # Install SDDM with yay
    # ---------------------
    
    if yay -S --noconfirm sddm; then
        echo "SDDM installed."
    else
        echo "Failed to install SDDM with yay. Exiting."
        exit 1
    fi
fi

#--------------------------------------------------
# Copy the following folders to home root directory
#--------------------------------------------------

echo -e "${BLUE}Copying folders to home root directory...${NC}"
sudo cp -r ~/.icons /root/
sudo cp -r ~/.Kvantum-themes /root/

# Uncomment the following line if you need to copy the Noto fonts folder
# echo "Copying Noto fonts folder to /usr/share/fonts..."
# sudo cp -r ~/.local/share/fonts/Noto /usr/share/fonts/

# Copy the following folders to the .config folder in the root directory
echo -e "${GREEN}Copying folders to /root/.config/...${NC}"
sudo cp -r ~/.config/fish /root/.config/            
sudo cp -r ~/.config/nwg-look /root/.config/            
sudo cp -r ~/.config/xsettingsd /root/.config/
sudo cp -r ~/.config/qt6ct /root/.config/
sudo cp -r ~/.config/starship /root/.config/
sudo cp -r ~/.config/gtk-3.0 /root/.config/

# Copy the individual files to the .config folder in the root directory
echo -e "${GREEN}Copying individual files to /root/.config/...${NC}"
sudo cp ~/.config/starship.toml /root/.config/
sudo cp ~/.config/starship-endeavouros.toml /root/.config/

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Clone the fonts repository
echo -e "${BLUE}Cloning fonts repository...${NC}"
git clone https://github.com/RedBlizard/hypr-blizz-fonts.git /tmp/hypr_blizz_fonts

# Copy fonts to /usr/share/fonts
echo -e "${BLUE}Copying fonts to /usr/share/fonts directory...${NC}"
sudo cp -r /tmp/hypr_blizz_fonts/* /usr/share/fonts

# Update font cache
echo -e "${BLUE}Updating font cache...${NC}"
sudo fc-cache -f -v

# Clean up
echo -e "${BLUE}Cleaning up...${NC}"
rm -rf /tmp/hypr_blizz_fonts

echo -e "${BLUE}Fonts installed successfully!${NC}"

# Copy sddm.conf to /etc/
echo -e "${GREEN}Copying sddm.conf to /etc/...${NC}"
sudo cp -r ~/hyprland-dots/Hyprland-blizz/sddm.conf /etc/

echo -e "${BLUE}Configuration files successfully copied to ~/ and ~/.config/${NC}"

# chmod all scripts needed         
chmod +x ~/.config/hypr/scripts/chmod_scripts.sh || { echo 'Making script executable failed.'; exit 1; }

echo -e "${RED}Now we will continue with the installation. We are halfway there.${RESET}"

# Change directory to the script's location
cd "$HOME/hyprland-installation/"

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# List of AUR helpers to check
aur_helpers=("yay" "trizen" "paru")

# Check if any AUR helper is installed
found=false
aur_helper=""

for helper in "${aur_helpers[@]}"; do
    if command -v "$helper" &> /dev/null; then
        aur_helper="$helper"
        found=true
        break
    fi
done

# Print yellow echo line if a default AUR helper is found
if $found; then
    echo -e "${GREEN}Default AUR helper found: $aur_helper${NC}"
else
    echo "No default AUR helper found."
fi

# Ask user to select an AUR helper if none found
if ! $found; then
    echo "Select an AUR helper:"
    select aur_helper_option in "${aur_helpers[@]}"; do
        case $REPLY in
            1)
                aur_helper="yay"
                echo -e "${BLUE}Installing yay...${NC}"
                yay_installation
                ;;
            2)
                aur_helper="trizen"
                echo -e "${BLUE}Installing trizen...${NC}"
                trizen_installation
                ;;
            3)
                aur_helper="paru"
                echo -e "${BLUE}Installing paru...${NC}"
                paru_installation
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
        break
    done
fi

# Function to check if yay is installed
yay_installation() {
    if ! command -v yay &>/dev/null; then
        echo "yay is not installed."
    else
        echo "yay is already installed."
    fi
}


# Function to install or remove trizen
trizen_installation() {
    if command -v trizen &>/dev/null; then
        echo "trizen is already installed. Do you want to remove it? (Yy/Nn)"
        read -r response
        if [[ $response =~ ^[Yy]$ ]]; then
            sudo pacman -Rs --noconfirm trizen
            echo "trizen has been removed."
        else
            echo "trizen is already installed."
        fi
    else
        echo "trizen is not installed."
        echo "Installing trizen..."
        yay -S --noconfirm trizen
    fi
}


# Function to install or remove paru
paru_installation() {
    if command -v paru &>/dev/null; then
        echo "paru is already installed. Do you want to remove it? (Yy/Nn)"
        read -r response
        if [[ $response =~ ^[Yy]$ ]]; then
            sudo pacman -Rs --noconfirm paru
            echo "paru has been removed."
        else
            echo "paru is already installed."
        fi
    else
        echo "paru is not installed."
        echo "Installing paru..."
        yay -S --noconfirm paru
    fi
}


# Function to install AUR packages
install_packages() {
    local aur_helper="$1"
    local packages="$2"

    # Install AUR packages using the specified AUR helper
    "$aur_helper" -S --noconfirm $packages
}

# Extract Arch package list from packages-repository.txt
arch_packages=$(awk '/^# AUR/ {exit} NF {print $0}' packages-repository.txt)

# Check if all Arch packages are installed
all_packages_installed=true
for package in $arch_packages; do
    if ! pacman -Qq "$package" &>/dev/null; then
        all_packages_installed=false
        break
    fi
done

# Print feedback based on results
if $all_packages_installed; then
    echo -e "${RED}All Arch packages are already installed. No further installation needed.${NC}"
else
    # Install Arch packages if needed
    if [ -n "$arch_packages" ]; then
        yay -Sy --noconfirm $arch_packages
        echo -e "${RED}Arch packages successfully installed.${NC}"
    else
        echo "No Arch packages found."
    fi
fi


# Extract AUR package list from packages-repository.txt
aur_packages=$(awk '/^# AUR/ {p=1; next} /^#/ {p=0} p' packages-repository.txt)

# Check if all AUR packages are installed
all_aur_packages_installed=true
for package in $aur_packages; do
    if ! yay -Qq "$package" &>/dev/null; then
        all_aur_packages_installed=false
        echo "$package is not installed"
        break
    fi
done

# Print feedback based on results
if $all_aur_packages_installed; then
    echo -e "${RED}All AUR packages are already installed. No further installation needed.${NC}"
else
    # Install AUR packages if needed
    if [ -n "$aur_packages" ]; then
        install_packages "$aur_helper" "$aur_packages"
        if yay -Qq $aur_packages &> /dev/null; then
            echo -e "${RED}AUR packages successfully installed.${NC}"
        else
            echo -e "${RED}Failed to install AUR packages.${NC}"
        fi
    else
        echo "No AUR packages found."
    fi
fi


# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Function to display the browser options
display_options() {
    echo "Select a browser to install:"
    echo "1. Chromium"
    echo "2. Firefox"
    echo "3. Brave"
    echo "4. Microsoft Edge"
    echo "5. Vivaldi"
}

# Function to handle invalid choice
handle_invalid_choice() {
    echo "Invalid choice. Exiting."
    exit 1
}

check_default_browser() {
    echo -e "${BLUE}Now we are checking which browser is installed as default...${NC}"
    default_browser_full=$(xdg-settings get default-web-browser)
    default_browser=$(basename "$default_browser_full" .desktop)
    echo "Default browser: $default_browser"

    # If default browser is 'brave-browser', set it as 'brave-browser' in the environment file
    if [ "$default_browser" = "brave" ]; then
        echo -e "${GREEN}Brave is already set as default browser.${NC}"
    else
        sudo sed -i "/^BROWSER=/s/.*/BROWSER=brave/" /etc/environment
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Brave set as default browser.${NC}"
        else
            echo -e "${RED}Failed to set Brave as default.${NC}"
        fi
    fi
}

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Function to prompt user for browser switch
prompt_browser_switch() {
    read -p "Do you want to switch to a different browser? (y/n): " switch_choice
    if [ "$switch_choice" == "y" ]; then
        display_options
        read -p "Enter the number corresponding to your choice: " new_choice

        case $new_choice in
            1) new_browser="chromium" ;;
            2) new_browser="firefox" ;;
            3) new_browser="brave-bin" ;;
            4) new_browser="microsoft-edge-stable-bin" ;;
            5) new_browser="vivaldi" ;;
            *) handle_invalid_choice ;;
        esac

        echo "Installing $new_browser..."
        if command -v yay &>/dev/null; then
            yay -S --noconfirm $new_browser
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm $new_browser
        else
            echo "Error: Package manager (yay or pacman) not found. Exiting."
            exit 1
        fi

        echo -e "${YELLOW}Setting $new_browser as default browser...${NC}"
        xdg-settings set default-web-browser $new_browser
        echo "$new_browser is now the default browser."
        echo -e "${BLUE}$new_browser is now the default browser.${NC}"
    else
        echo -e "${RED}Keeping the current default browser ($default_browser).${NC}"
    fi
}

# Display welcome message
echo -e "${BLUE}One moment please, now we are checking which browser is installed as default.${NC}"

# Check default browser
check_default_browser

# Prompt user for browser switch
prompt_browser_switch

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Check if firewalld is installed
if ! command -v firewalld &> /dev/null; then
    echo -e "${orange}We detected no firewall installed.${NC}"

    # Prompt user for input
    echo -n "Do you want to install firewalld? (Yy/Nn): "
    read choice
    case "$choice" in
        [yY]|[yY][eE][sS]) 
            # Install firewalld
            sudo pacman -S --noconfirm firewalld
            # Enable firewalld at boot and start it
            sudo systemctl enable --now firewalld
            sudo systemctl start firewalld.service
            echo "Firewalld installed, enabled, and started."
            ;;
        *)
            echo "Firewalld not installed."
            ;;
    esac
else
    echo -e "${RED}Firewalld is already installed.${NC}"
fi

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Check if Geany is installed
if command -v geany &> /dev/null; then
    echo -e "${BLUE}Geany is already installed.${NC}"
    # Optionally, set Geany as the default editor for the current session
    #export VISUAL=geany
    #export EDITOR=geany
else
    echo -e "${RED}Geany is not installed. Installing Geany...${NC}"
    # Add installation command for Geany (for Arch Linux)
    sudo pacman -Sy --noconfirm geany

    # Check if the installation was successful
    if command -v geany &> /dev/null; then
        echo -e "${BLUE}Geany installed successfully.${NC}"
        # Optionally, set Geany as the default editor for the current session
        #export VISUAL=geany
        #export EDITOR=geany
    else
        echo -e "${RED}Failed to install Geany. Please install it manually and set it as the default editor.${NC}"
        # You may choose to exit the script here or continue with other tasks
    fi
fi


# Check if LightDM is installed and disable it if found
if command -v lightdm &> /dev/null; then
    echo "Disabling LightDM..."
    sudo systemctl disable lightdm
    echo "LightDM disabled."
fi

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    # SDDM is not installed, prompt user to install and enable
    echo "Just a friendly reminder: it is preferred to enable SDDM. Keep that in mind!"
    read -p "Do you want to enable SDDM? (Yy/Nn): " enable_sddm
    case $enable_sddm in
        [Yy]* )
            # Install SDDM
            if yay -S --noconfirm sddm; then
                echo "SDDM installed."
            else
                echo "Failed to install SDDM with yay. Exiting."
                exit 1
            fi
            ;;
        [Nn]* )
            echo "SDDM not enabled. You can enable it later by configuring /etc/sddm.conf."
            echo "Done!"
            exit 0
            ;;
        * )
            echo "Invalid choice. Please answer yes or no."
            exit 1
            ;;
    esac
fi

# Enable SDDM
echo "Enabling SDDM..."
sudo systemctl enable sddm
echo "SDDM enabled. Continuing with the rest of the script."

# Copy custom sddm.conf
sudo cp -rf "$HOME/hyprland-dots/Hyprland-blizz/sddm.conf" /etc/ || { echo 'Error copying sddm.conf.'; exit 1; }


# ------------------------------------------------------
# Set SDDM theme
# ------------------------------------------------------
sddm_theme="simplicity"

# Prompt user for confirmation before setting the theme
read -p "Do you want to set the SDDM theme to $sddm_theme? (Yy/Nn): " set_theme_confirmation
case $set_theme_confirmation in
    [Yy]* )
        if ! command -v sddm &> /dev/null; then
            echo "SDDM is not installed. The SDDM theme cannot be set."
            exit 1
        fi

        # Modify the SDDM configuration file to set the theme
        sudo sed -i "s/^Current=.*/Current=$sddm_theme/" /etc/sddm.conf
        echo "SDDM theme set to $sddm_theme."
        ;;
    [Nn]* )
        echo "SDDM theme not changed."
        ;;
    * )
        echo "Invalid choice. Please answer yes or no."
        exit 1
        ;;
esac

# ------------------------------------------------------
# Remove unwanted folders from /usr/share/sddm/themes
# ------------------------------------------------------

sudo rm -rf /usr/share/sddm/themes/{elarun, maldives, maya} || { echo 'Removal of unwanted folders failed.'; exit 1; }

# ------------------------------------------------------
# Check if the directory exists, if not, create it
# ------------------------------------------------------
if [ ! -d "/usr/share/sddm/themes/simplicity/images" ]; then
    sudo mkdir -p /usr/share/sddm/themes/simplicity/images
fi

# ------------------------------------------------------
# Print debug information
# ------------------------------------------------------
echo "Contents of sddm-images directory:"
ls -la ~/hyprland-dots/Hyprland-blizz/sddm-images

# ------------------------------------------------------------
# Copy sddm-images to /usr/share/sddm/themes/simplicity/images
# ------------------------------------------------------------
echo "Copying sddm-images to /usr/share/sddm/themes/simplicity/images..."
sudo cp -r ~/hyprland-dots/Hyprland-blizz/sddm-images/* /usr/share/sddm/themes/simplicity/images || { echo 'Copy of images failed.'; exit 1; }

# -------------------------------------
# Print debug information after copying
# -------------------------------------
echo "Contents of /usr/share/sddm/themes/simplicity/images:"
ls -la /usr/share/sddm/themes/simplicity/images

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# Path to the environment file
ENV_FILE="/etc/environment"

#-----------------------------------------------------
# Function to update environment file for a given user
#-----------------------------------------------------
# Path to the environment file
ENV_FILE="/etc/environment"

# Function to update environment file for a given user
update_env_file() {
    local user="$1"
    local env_file="/home/$user/.bashrc"
    
    # Remove existing lines containing QT_QPA_PLATFORMTHEME and QT_STYLE_OVERRIDE
    sudo sed -i '/^#*QT_QPA_PLATFORMTHEME=/d' /etc/environment
    sudo sed -i '/^#*QT_STYLE_OVERRIDE=/d' /etc/environment
    
    # Add new lines without the # characters
    echo "QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment >/dev/null
    echo "QT_STYLE_OVERRIDE=kvantum" | sudo tee -a /etc/environment >/dev/null


    echo "Environment file updated for user $user."
}

# Check if the environment file exists
if [ -f "$ENV_FILE" ]; then
    # Update environment file for the current user
    update_env_file "$USER"
    
    # Update environment file for the root user
    update_env_file "root"

    echo -e "${BLUE}Environment files updated for both the current user and root.${NC}"
else
    echo -e "${RED}Environment file not found.${NC}"
fi

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

# ------------------------------------------------------
# Use kvantummanager to set the theme for the user
# ------------------------------------------------------

echo -e "${BLUE}Checking if kvantummanager is accessible...${NC}"
which kvantummanager

echo -e "${RED}Just a friendly reminder, the Kvantum-themes directory is hidden!!!${NC}"

kvantummanager --set Catppuccin-Frappe-Blue

echo -e "${BLUE}Kvantum theme for the user has been set.${NC}"

#------------------------------------------------------
# Use kvantummanager to set the theme for the root user
echo -e "${RED}Just a friendly reminder, the Kvantum-themes directory is hidden on root !!!${NC}"
sudo kvantummanager --set Catppuccin-Frappe-Blue

echo -e "${BLUE}Kvantum theme for the root user has been set.${NC}"

echo -e "${RED}Now we are going to install the themes and setting up nwg-look we are almost done now !!!${NC}"

# Define repository and destination
THEME_REPO="https://github.com/RedBlizard/Colloid-gtk-theme.git"
INSTALL_SCRIPT="install.sh"
DEST_DIR="/usr/share/themes"
DEFAULT_THEME="Colloid-Dark-Catppuccin"

# Define a temporary directory for cloning
TEMP_DIR="$HOME/Colloid-gtk-theme"

# Clone the repository (or update if already cloned)
if [ ! -d "$TEMP_DIR" ]; then
    echo "Cloning Colloid GTK theme repository..."
    git clone "$THEME_REPO" "$TEMP_DIR"

    if [ $? -ne 0 ]; then
        echo "Failed to clone GTK theme repository. Exiting."
        exit 1
    fi
else
    echo "Repository already exists. Pulling latest changes..."
    cd "$TEMP_DIR" && git pull
    if [ $? -ne 0 ]; then
        echo "Failed to update GTK theme repository. Exiting."
        exit 1
    fi
fi

# Run the install script with specified options
echo "Installing themes to $DEST_DIR..."
cd "$TEMP_DIR" || exit 1
sudo ./"$INSTALL_SCRIPT" --theme all --tweaks catppuccin --dest "$DEST_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to install themes. Exiting."
    exit 1
fi

# Set the default theme
echo "Setting window theme to: $DEFAULT_THEME"
gsettings set org.gnome.desktop.wm.preferences theme "$DEFAULT_THEME"

if [ $? -ne 0 ]; then
    echo "Error: Failed to set window theme."
    exit 1
fi

# Update .gtkrc-2.0.mine to prefer light themes
GTKRC_FILE="$HOME/.gtkrc-2.0.mine"

echo "Checking if $GTKRC_FILE exists..."
if [ ! -f "$GTKRC_FILE" ]; then
    echo "$GTKRC_FILE does not exist. Creating it..."
    touch "$GTKRC_FILE"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create $GTKRC_FILE. Exiting."
        exit 1
    fi
else
    echo "$GTKRC_FILE already exists. Updating it..."
fi

# Write the preference to the file
echo "Updating $GTKRC_FILE for NWG-Look preferences..."
echo "gtk-application-prefer-dark-theme=0" > "$GTKRC_FILE"

if [ $? -eq 0 ]; then
    echo "GTK preferences updated successfully in $GTKRC_FILE."
else
    echo "Error: Failed to update $GTKRC_FILE."
    exit 1
fi


echo "Themes installed successfully and default theme set to $DEFAULT_THEME."


# -----------------------------------------
# Change the default Icon-Theme for the user
# -----------------------------------------

echo "Setting icon theme..."
/usr/bin/gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# ------------------------------------------------------
# Change Papirus folder colors for the user
# ------------------------------------------------------
papirus-folders -C cat-frappe-blue --theme Papirus-Dark 

# ------------------------------------------------------
# Change Papirus folder colors for root
# ------------------------------------------------------
# sudo papirus-folders -C cat-frappe-blue --theme Papirus-Dark

# -------------------------------            
# Set the Qogir-dark cursor theme
# -------------------------------
echo "export XCURSOR_THEME=Qogir-dark" | sudo tee -a /etc/environment
echo "export XCURSOR_SIZE=24" | sudo tee -a /etc/environment
xsetroot -cursor_name left_ptr

# ---------------------------------------------------------------------------------------------------------------------------------------------
echo "Please be patient; we are doing a last check to see if GRUB is correctly configured for your hyprland installation with an NVIDIA GPU."
# ---------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
echo "For safety reasons, we are now making a backup of the GRUB configuration. See /etc/default/grub.bak"
# ------------------------------------------------------------------------------------------------
sudo cp /etc/default/grub /etc/default/grub.bak

# Check if the system has an NVIDIA GPU before attempting any changes
if lspci | grep -i "NVIDIA" > /dev/null; then
    # Check if the nvidia-drm.modeset=1 option is present in GRUB_CMDLINE_LINUX
    if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        # Append the option if it's not present
        sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 nvidia-drm.modeset=1"/' /etc/default/grub

        # Regenerate GRUB configuration
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        echo "Added nvidia-drm.modeset=1 to GRUB_CMDLINE_LINUX."

        # Update GRUB only if changes are made
        sudo update-grub
    else
        echo "GRUB_CMDLINE_LINUX already contains nvidia-drm.modeset=1. No changes needed."
    fi
else
    echo "No NVIDIA GPU detected. No changes needed for GRUB configuration."
fi

# Path to your welcome script
welcome_script="$HOME/.config/hypr/scripts/hypr-welcome"

# Path to the symlink in /usr/bin
symlink="/usr/bin/hypr-welcome"

# Check if the symlink exists
if [ -L "$symlink" ]; then
    echo "Old symlink found. Removing..."
    sudo rm "$symlink"
    echo "Old symlink removed."
fi

# Create new symlink
sudo ln -sf "$welcome_script" "$symlink"
echo "New symlink created."

echo "Hypr Welcome script installation complete."

# Set up environment variables
echo 'XDG_MENU_PREFIX=arch-' | sudo tee -a /etc/environment > /dev/null

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

echo -e "${BLUE}Now we are cleaning things up.${NC}"

# -------------------------------------
echo -e "${BLUE}Cleaning up installation files.${NC}"
# -------------------------------------

rm -rf $HOME/hyprland-installation
rm -rf $HOME/README.md
rm -rf $HOME/sddm-images
rm -rf $HOME/packages-repository.txt
rm -rf $HOME/install.sh
rm -rf $HOME/sddm.conf
rm -rf $HOME/LICENSE
rm -rf $HOME/environment

yay -Rns pavucontrol

echo -e "${RED}Cleaning up is done.${NC}"

echo -e "${RED}"
cat <<"EOF"

░██╗░░░░░░░██╗███████╗██╗░░░░░░█████╗░░█████╗░███╗░░░███╗███████╗  ████████╗░█████╗░
░██║░░██╗░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗████╗░████║██╔════╝  ╚══██╔══╝██╔══██╗
░╚██╗████╗██╔╝█████╗░░██║░░░░░██║░░╚═╝██║░░██║██╔████╔██║█████╗░░  ░░░██║░░░██║░░██║
░░████╔═████║░██╔══╝░░██║░░░░░██║░░██╗██║░░██║██║╚██╔╝██║██╔══╝░░  ░░░██║░░░██║░░██║
░░╚██╔╝░╚██╔╝░███████╗███████╗╚█████╔╝╚█████╔╝██║░╚═╝░██║███████╗  ░░░██║░░░╚█████╔╝
░░░╚═╝░░░╚═╝░░╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚══════╝  ░░░╚═╝░░░░╚════╝░

██╗░░██╗██╗░░░██╗██████╗░██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░
██║░░██║╚██╗░██╔╝██╔══██╗██╔══██╗██║░░░░░██╔══██╗████╗░██║██╔══██╗
███████║░╚████╔╝░██████╔╝██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║
██╔══██║░░╚██╔╝░░██╔═══╝░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║
██║░░██║░░░██║░░░██║░░░░░██║░░██║███████╗██║░░██║██║░╚███║██████╔╝
╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░
EOF
echo -e "${NONE}"

echo   "Your system is now configured with Hyprland."


echo -e "${GREEN}"
cat <<"EOF"

░██████╗███████╗████████╗  ██╗░░░██╗░█████╗░██╗░░░██╗██████╗░
██╔════╝██╔════╝╚══██╔══╝  ╚██╗░██╔╝██╔══██╗██║░░░██║██╔══██╗
╚█████╗░█████╗░░░░░██║░░░  ░╚████╔╝░██║░░██║██║░░░██║██████╔╝
░╚═══██╗██╔══╝░░░░░██║░░░  ░░╚██╔╝░░██║░░██║██║░░░██║██╔══██╗
██████╔╝███████╗░░░██║░░░  ░░░██║░░░╚█████╔╝╚██████╔╝██║░░██║
╚═════╝░╚══════╝░░░╚═╝░░░  ░░░╚═╝░░░░╚════╝░░╚═════╝░╚═╝░░╚═╝

░██████╗███████╗████████╗████████╗██╗███╗░░██╗░██████╗░░██████╗  ██╗
██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗░██║██╔════╝░██╔════╝  ██║
╚█████╗░█████╗░░░░░██║░░░░░░██║░░░██║██╔██╗██║██║░░██╗░╚█████╗░  ██║
░╚═══██╗██╔══╝░░░░░██║░░░░░░██║░░░██║██║╚████║██║░░╚██╗░╚═══██╗  ╚═╝
██████╔╝███████╗░░░██║░░░░░░██║░░░██║██║░╚███║╚██████╔╝██████╔╝  ██╗
╚═════╝░╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░╚═════╝░  ╚═╝
EOF
echo -e "${NONE}"         
echo -e "${BLUE}"
echo ""
echo "Open ~/.config/hypr/hyprland.conf to change your keyboard layout (default is us) and your screen resolution best to change the moinitors to (default is preferred) and change keybinds if needed."
echo ""

echo -e "${BLUE}"
cat <<"EOF"

███╗░░██╗██╗░░░██╗██╗██████╗░██╗░█████╗░  ░█████╗░███╗░░██╗██╗░░░░░██╗░░░██╗  ██╗
████╗░██║██║░░░██║██║██╔══██╗██║██╔══██╗  ██╔══██╗████╗░██║██║░░░░░╚██╗░██╔╝  ██║
██╔██╗██║╚██╗░██╔╝██║██║░░██║██║███████║  ██║░░██║██╔██╗██║██║░░░░░░╚████╔╝░  ██║
██║╚████║░╚████╔╝░██║██║░░██║██║██╔══██║  ██║░░██║██║╚████║██║░░░░░░░╚██╔╝░░  ╚═╝
██║░╚███║░░╚██╔╝░░██║██████╔╝██║██║░░██║  ╚█████╔╝██║░╚███║███████╗░░░██║░░░  ██╗
╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═════╝░╚═╝╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚══╝╚══════╝░░░╚═╝░░░  ╚═╝

echo "Open ~/.config/hypr/conf/monitor.conf NVIDIA USERS PAY ATTENTION BY DEFAULT THE NVIDIA ENV RULES HAVE A COMMENT IN FRONT OF EACH LINE YOU NEED TO REMOVE THE COMMENT (#)"
echo "Open ~/.config/hypr/conf/env_var.conf NVIDIA USERS YOU NEED TO PLACE A COMMENT (#) IN FRONT OF THE FOLLOWING LINE env=WLR_NO_HARDWARE_CURSORS=1 !!!"
EOF
echo -e "${none}"

# Define color codes
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[38;2;149;209;137m'
NC='\033[0m' # No Color

echo -e "${BLUE}DONE!${NC}"

echo ""
# Now you are fully ready and can reboot your system / if you encounter any problems related to the configuration get in contact with RedBlizard

echo -e "${RED}Then reboot your system!${NC}"
