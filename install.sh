#!/bin/bash

echo -e "${GREEN}"
cat <<"EOF"
██████╗░██╗░░░██╗  ██████╗░███████╗██████╗░██████╗░██╗░░░░░██╗███████╗░█████╗░██████╗░██████╗░
██╔══██╗╚██╗░██╔╝  ██╔══██╗██╔════╝██╔══██╗██╔══██╗██║░░░░░██║╚════██║██╔══██╗██╔══██╗██╔══██╗
██████╦╝░╚████╔╝░  ██████╔╝█████╗░░██║░░██║██████╦╝██║░░░░░██║░░███╔═╝███████║██████╔╝██║░░██║
██╔══██╗░░╚██╔╝░░  ██╔══██╗██╔══╝░░██║░░██║██╔══██╗██║░░░░░██║██╔══╝░░██╔══██║██╔══██╗██║░░██║
██████╦╝░░░██║░░░  ██║░░██║███████╗██████╔╝██████╦╝███████╗██║███████╗██║░░██║██║░░██║██████╔╝
╚═════╝░░░░╚═╝░░░  ╚═╝░░╚═╝╚══════╝╚═════╝░╚═════╝░╚══════╝╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
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

# Backup and copy .config folder
folders=("alacritty" "btop" "cava" "dunst" "hypr" "kitty" "Kvantum" "neofetch" "networkmanager-dmenu" "nwg-look" "pacseek" "pipewire" "qt6ct" "ranger" "sddm-config-editor" "swaylock" "Thunar" "waybar" "wlogout" "wofi" "xsettingsd" "gtk-2.0" "gtk-3.0" "gtk-4.0" "swaylock" "starship")

for folder in "${folders[@]}"; do
    folder_path="/home/$username/.config/$folder"
    backup_path="$backup_dir/$folder"
    
    # Backup the folder
    backup "$folder_path" "$backup_path"
done


# Ensure the script is in the correct directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || { echo 'Failed to change directory to script directory.'; exit 1; }

# Redirect CPU info checks to /dev/null to hide the output

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BLUE='\033[0;94m'
ORANGE='\033[0;33m'
PINK='\033[0;95m'
YELLOW='\033[0;93m'
NC='\033[0m' # No Color

# Display welcome message
echo -e "${GREEN}Welcome to the Hyprland-Blizz installer!${NC}"

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


# Function to switch shell for the current user
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
echo -e "${YELLOW}Now we are checking which shell is used on the system.${NC}"
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


# -----------------------
# Getting in the dotfiles
# -----------------------

echo -e "${BLUE}Now we are getting in the dotfiles. Please be patient, this might take a while.${NC}"

# Getting in the dotfiles
echo "Cloning dotfiles repository..."

# Create the Hyprland-blizz directory if not present
mkdir -p "$HOME/Hyprland-blizz" || { echo 'Failed to create Hyprland-blizz directory.'; exit 1; }

# Change into the Hyprland-blizz directory
cd "$HOME/Hyprland-blizz" || { echo 'Failed to change directory to Hyprland-blizz.'; exit 1; }

# Clone the dotfiles repository
git clone "https://github.com/RedBlizard/Hyprland-blizz.git" . || { echo 'Failed to clone dotfiles repository.'; exit 1; }

# Cloning of the dotfiles is donw now
echo -e "${PINK}Cloning of the dotfiles is done${NC}"


# ------------------------------------------------------
# Copy dotfiles and directories to home directory
# ------------------------------------------------------

echo -e "${BLUE}Don't worry, we're now copying the dotfile directories to the correct location.${NC}"

cp -r "$SCRIPT_DIR"/* ~/
cp -r .config ~/
cp -r .icons ~/
cp -r .Kvantum-themes ~/
cp -r .local ~/
cp -r Pictures ~/

echo -e "${GREEN}"
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

# ------------------------------------------------------
# Change to the Hyprland-blizz directory
# ------------------------------------------------------
cd "$HOME/Hyprland-blizz/" || { echo 'Failed to change directory to Hyprland-blizz.'; exit 1; }


# ----------------------------------
# Start of the Hyprland installation
# ----------------------------------

while true; do
    read -p "$(tput setaf 4)DO YOU WANT TO START THE HYPRLAND INSTALLATION NOW? (Yy/Nn): $(tput sgr0)" yn
    case $yn in
        [Yy]* )
            echo "Installation started."
            
            # --------------------------------------------------
            # Create the Hyprland-blizz directory if not present
            # --------------------------------------------------
            
            mkdir -p "$HOME/Hyprland-blizz" || { echo 'Failed to create Hyprland-blizz directory.'; exit 1; }
            
            # ----------------------------------------
            # Change into the Hyprland-blizz directory
            # ----------------------------------------
            
            cd "$HOME/Hyprland-blizz" || { echo 'Failed to change directory to Hyprland-blizz.'; exit 1; }

            # -----------------------------------------------
            # Copy dotfiles and directories to home directory
            # -----------------------------------------------
            cp -r * ~/
            cp -r .icons ~/
            cp -r .Kvantum-themes ~/           
            cp -r .local ~/
            cp -r Pictures ~/

            # -------------------------------------
            # Copy .config folder to home directory
            # -------------------------------------
            cp -r .config ~/

            break;;
        [Nn]* )
            exit;
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

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

# Copy dotfiles and directories to home directory
echo -e "${BLUE}Copying dotfiles and directories to home directory...${NC}"
cp -r ~/Hyprland-blizz/* ~/

# Copy .config folder to home directory            
echo -e "${BLUE}Copying .config folder to home directory...${NC}"
cp -r ~/Hyprland-blizz/.config ~/

# Copy the following folders to home root directory
echo -e "${PINK}Copying folders to home root directory...${NC}"
sudo cp -r ~/.icons /root/
sudo cp -r ~/.Kvantum-themes /root/
sudo cp -r ~/.themes /root/

# Uncomment the following line if you need to copy the Noto fonts folder
# echo "Copying Noto fonts folder to /usr/share/fonts..."
# sudo cp -r ~/.local/share/fonts/Noto /usr/share/fonts/

# Copy the following folders to the .config folder in the root directory
echo -e "${PINK}Copying folders to /root/.config/...${NC}"
sudo cp -r ~/.config/fish /root/.config/            
sudo cp -r ~/.config/nwg-look /root/.config/            
sudo cp -r ~/.config/xsettingsd /root/.config/
sudo cp -r ~/.config/qt6ct /root/.config/
sudo cp -r ~/.config/starship /root/.config/
sudo cp -r ~/.config/gtk-3.0 /root/.config/

# Copy the individual files to the .config folder in the root directory
echo -e "${PINK}Copying individual files to /root/.config/...${NC}"
sudo cp ~/.config/starship.toml /root/.config/
sudo cp ~/.config/starship-endeavouros.toml /root/.config/

# Copy sddm.conf to /etc/
echo -e "${YELLOW}Copying sddm.conf to /etc/...${NC}"
sudo cp -r ~/Hyprland-blizz/sddm.conf /etc/

echo -e "${BLUE}Configuration files successfully copied to ~/ and ~/.config/${NC}"

# chmod all scripts needed         
chmod +x ~/.config/hypr/scripts/chmod_scripts.sh || { echo 'Making script executable failed.'; exit 1; }

echo -e "${YELLOW}Now we will continue with the installation. We are halfway there.${RESET}"


# Change directory to the script's location
cd "$HOME/hyprland-installation/"


# Change directory to the script's location
cd "$HOME/hyprland-installation/"

# Check if an AUR helper is present
echo -e "${PINK}Now we are checking if an AUR helper is present${NC}"

# List of AUR helpers to check
aur_helpers=("yay" "aurman" "trizen" "paru" "pacaur" "aura" "apacman" "bauerbill" "pikaur")

# Flag to indicate if any AUR helper is found
found=false
aur_helper=""

# Iterate through each AUR helper and check if it's present
for helper in "${aur_helpers[@]}"; do
    if command -v "$helper" &> /dev/null; then
        echo "AUR helper ($helper) is present."
        found=true
        aur_helper="$helper"
        break
    fi
done

# If no AUR helper is found
if ! $found; then
    echo "No AUR helper is present."
else
    # Ask user if they want to switch to another AUR helper
    read -p "Do you want to switch to another AUR helper? (y/n): " choice
    if [ "$choice" == "y" ]; then
        echo -e "${PINK}Please select an AUR helper to switch to:${NC}"
        select new_helper in "${aur_helpers[@]}"; do
            if [ -n "$new_helper" ]; then
                aur_helper="$new_helper"
                echo "Switching to $aur_helper..."
                break
            else
                echo "Invalid option. Please try again."
            fi
        done
    else
        echo "Keeping current AUR helper ($aur_helper)."
    fi
fi

echo "Using AUR helper: $aur_helper"

# Check if packages-repository.txt is present
if [ -f "packages-repository.txt" ]; then
    # Read package names from packages-repository.txt
    while IFS= read -r package; do
        # Skip empty lines and lines starting with #
        if [[ -n $package && $package != \#* ]]; then
            # Check if the package is available in the Arch repositories
            if pacman -Qi "$package" &> /dev/null; then
                echo -e "${BLUE}Packages are already installed.${NC}"
            else
                echo -e "${GREEN}Installing Arch repo packages...${NC}"
                sudo pacman -S --noconfirm "$package"
            fi
            # Check if the package is available in AUR
            if $aur_helper -Qi "$package" &> /dev/null; then
                echo -e "${BLUE}Packages are already installed.${NC}"
            else
                echo -e "${ORANGE}Installing AUR packages...${NC}"
                $aur_helper -S --noconfirm "$package"
            fi
        fi
    done < "packages-repository.txt"
    echo "Packages from packages-repository.txt installed."
else
    echo "Error: packages-repository.txt not found. Make sure the file exists and contains a list of package names."
    exit 1
fi


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

# Function to check default browser
check_default_browser() {
    echo -e "${BLUE}Now we are checking which browser is installed as default...${NC}"
    default_browser_full=$(xdg-settings get default-web-browser)
    default_browser=$(basename "$default_browser_full" .desktop)
    echo "Default browser: $default_browser"

    # If default browser is 'brave', set it as 'brave.desktop' in the environment file
    if [ "$default_browser" = "brave.desktop" ]; then
        sudo sed -i "/^BROWSER=/s/.*/BROWSER=brave.desktop/" /etc/environment
        if [ $? -eq 0 ]; then
            # If setting to brave.desktop was successful, change it to just 'brave'
            sudo sed -i "/^BROWSER=/s/brave\.desktop/brave/" /etc/environment
        fi
    fi
}

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

        echo "Setting $new_browser as default browser..."
        xdg-settings set default-web-browser $new_browser
        echo "$new_browser is now the default browser."
    else
        echo "Keeping the current default browser ($default_browser)."
    fi
}

# Display welcome message
echo -e "${GREEN}One moment please, now we are checking which browser is installed as default.${NC}"

# Check default browser
check_default_browser

# Prompt user for browser switch
prompt_browser_switch

# Define colors
orange='\033[0;33m'
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
    echo "Firewalld is already installed."
fi

# ------------------------------------------------------
# Check if Geany is installed
# ------------------------------------------------------

if command -v geany &> /dev/null; then
    # Set Geany as the default editor for the current session
    export VISUAL=geany
    export EDITOR=geany
    echo "Geany set as the default editor for the current session."

    # Optionally, you can set Geany as the default editor permanently
    #echo "export VISUAL=geany" | sudo tee -a /etc/environment
    #echo "export EDITOR=geany" | sudo tee -a /etc/environment
    #echo "Geany set as the default editor."
else
    echo "Geany is not installed. Installing Geany..."
    # Add installation command for Geany
    sudo pacman -Sy --noconfirm geany
    # Check if the installation was successful
    if command -v geany &> /dev/null; then
        echo "Geany installed successfully. Setting it as the default editor for the current session."
        export VISUAL=geany
        export EDITOR=geany
        echo "Geany set as the default editor for the current session."

        # Optionally, you can set Geany as the default editor permanently
        #echo "export VISUAL=geany" | sudo tee -a /etc/environment
        #echo "export EDITOR=geany" | sudo tee -a /etc/environment
        #echo "Geany set as the default editor."
    else
        echo "Failed to install Geany. Please install it manually and set it as the default editor."
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
sudo cp -rf "$HOME/Hyprland-blizz/sddm.conf" /etc/ || { echo 'Error copying sddm.conf.'; exit 1; }


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
# Print debug information
# ------------------------------------------------------
echo "Contents of sddm-images directory:"
ls -la ~/Hyprland-blizz/sddm-images

# ------------------------------------------------------------
# Copy sddm-images to /usr/share/sddm/themes/simplicity/images
# ------------------------------------------------------------
echo "Copying sddm-images to /usr/share/sddm/themes/simplicity/images..."
sudo cp -r ~/Hyprland-blizz/sddm-images/* /usr/share/sddm/themes/simplicity/images || { echo 'Copy of images failed.'; exit 1; }

# -------------------------------------
# Print debug information after copying
# -------------------------------------
echo "Contents of /usr/share/sddm/themes/simplicity/images:"
ls -la /usr/share/sddm/themes/simplicity/images



# ------------------------------------------------------
# Change qt6ct settings to use Kvantum theme for the user
# ------------------------------------------------------

echo "export QT_QPA_PLATFORMTHEME=qt6ct" >> ~/.bashrc || { echo 'Setting QT_QPA_PLATFORMTHEME for the user failed.'; exit 1; }
echo "export QT_STYLE_OVERRIDE=kvantum-dark" >> ~/.bashrc || { echo 'Setting QT_STYLE_OVERRIDE for the user failed.'; exit 1; }

echo "Just a friendly reminder, the Kvantum-themes directory is hidden!!"

# ------------------------------------------------------
# Use kvantummanager to set the theme
# ------------------------------------------------------
kvantummanager --set Catppuccin-Frappe-Blue

# ------------------------------------------------------
# Change qt6ct settings to use Kvantum theme for root
# ------------------------------------------------------

echo "export QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment || { echo 'Setting QT_QPA_PLATFORMTHEME for root failed.'; exit 1; }
echo "export QT_STYLE_OVERRIDE=kvantum-dark" | sudo tee -a /etc/environment || { echo 'Setting QT_STYLE_OVERRIDE for root failed.'; exit 1; }

  
echo "Just a friendly reminder, the Kvantum-themes directory is hidden on root to!!"

# ------------------------------------------------------
# Use kvantummanager to set the theme
# ------------------------------------------------------

sudo kvantummanager --set Catppuccin-Frappe-Blue


# ----------------------------
# Change GTK-Theme for the user
# ----------------------------

echo "Setting GTK theme..."
/usr/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Frappe-Standard-Blue-Dark'

# -----------------------------------------
# Change the default Icon-Theme for the user
# -----------------------------------------

echo "Setting icon theme..."
/usr/bin/gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# -------------------------------
# Change Window-Theme for the user
# -------------------------------

echo "Setting window theme..."
/usr/bin/gsettings set org.gnome.desktop.wm.preferences theme 'Catppuccin-Frappe-Standard-Blue-Dark'

# ------------------------------------------------------
# Change Papirus folder colors for the user
# ------------------------------------------------------
papirus-folders -C cat-frappe-blue --theme Papirus-Dark 

# ------------------------------------------------------
# Change Papirus folder colors for root
# ------------------------------------------------------
sudo papirus-folders -C cat-frappe-blue --theme Papirus-Dark


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

# Clean up
# -------------------------------------
echo "Cleaning up installation files."
# -------------------------------------
# Forcefully remove the directory
rm -rf "$HOME/hyprland-blizz"
echo "hyprland-blizz directory removed."

rm -rf $HOME/hyprland-installation
rm -rf $HOME/README.md
rm -rf $HOME/sddm-images
rm -rf $HOME/packages-repository.txt
rm -rf $HOME/install.sh
rm -rf $HOME/sddm.conf
rm -rf $HOME/LICENSE
rm -rf $HOME/environment

echo -e "${green}"
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


echo -e "${green}"
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

echo ""
echo "Open ~/.config/hypr/hyprland.conf to change your keyboard layout (default is us) and your screen resolution best to change the moinitors to (default is preferred) and change keybinds if needed."
echo ""

echo -e "${green}"
cat <<"EOF"

███╗░░██╗██╗░░░██╗██╗██████╗░██╗░█████╗░  ░█████╗░███╗░░██╗██╗░░░░░██╗░░░██╗  ██╗
████╗░██║██║░░░██║██║██╔══██╗██║██╔══██╗  ██╔══██╗████╗░██║██║░░░░░╚██╗░██╔╝  ██║
██╔██╗██║╚██╗░██╔╝██║██║░░██║██║███████║  ██║░░██║██╔██╗██║██║░░░░░░╚████╔╝░  ██║
██║╚████║░╚████╔╝░██║██║░░██║██║██╔══██║  ██║░░██║██║╚████║██║░░░░░░░╚██╔╝░░  ╚═╝
██║░╚███║░░╚██╔╝░░██║██████╔╝██║██║░░██║  ╚█████╔╝██║░╚███║███████╗░░░██║░░░  ██╗
╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═════╝░╚═╝╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚══╝╚══════╝░░░╚═╝░░░  ╚═╝

echo "Open ~/.config/hypr/hyprland.conf NVIDIA USERS PAY ATTENTION BY DEFAULT THE NVIDIA ENV RULES HAVE A COMMENT IN FRONT OF EACH LINE YOU NEED TO REMOVE THE COMMENT (#)"
echo "Open ~/.config/hypr/hyprland.conf NVIDIA USERS YOU NEED TO PLACE A COMMENT (#) IN FRONT OF THE FOLLOWING LINE env=WLR_NO_HARDWARE_CURSORS=1 !!!"
EOF
echo -e "${none}"

echo ""
# Now you are fully ready and can reboot your system / if you encounter any problems related to the configuration get in contact with RedBlizard
echo "DONE!"
echo "Then reboot your system!"
