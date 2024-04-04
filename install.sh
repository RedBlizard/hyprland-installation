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

# Ensure the script is in the correct directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR" || { echo 'Failed to change directory to script directory.'; exit 1; }

# Redirect CPU info checks to /dev/null to hide the output
{
    # ------------------------------------------------------
    # Check if yay is installed
    # ------------------------------------------------------
    if ! command -v yay &> /dev/null; then
        echo "yay is not installed. Installing yay..."
        sudo pacman -Sy --noconfirm yay
    fi

    # ------------------------------------------------------
    # Check if Git is installed
    # ------------------------------------------------------
    echo "Checking if Git is installed..."
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Installing Git..."
        sudo pacman -Sy --noconfirm git || { echo 'Installation of Git failed.'; exit 1; }
    fi

    # Add more checks here as needed
} &>/dev/null &  # Redirect output to /dev/null and run in background


# ------------------------------------------------------
# Getting in the dotfiles
# ------------------------------------------------------

echo "Cloning dotfiles repository..."

# ------------------------------------------------------
# Create the Hyprland-blizz directory if not present
# ------------------------------------------------------

mkdir -p "$HOME/Hyprland-blizz" || { echo 'Failed to create Hyprland-blizz directory.'; exit 1; }

# ------------------------------------------------------
# Change into the Hyprland-blizz directory
# ------------------------------------------------------

cd "$HOME/Hyprland-blizz" || { echo 'Failed to change directory to Hyprland-blizz.'; exit 1; }

# ------------------------------------------------------
# Clone the dotfiles repository
# ------------------------------------------------------

git clone "https://github.com/RedBlizard/Hyprland-blizz.git" . || { echo 'Failed to clone dotfiles repository.'; exit 1; }


# ---------------------------------------------
# Check if Kvantum directory exists in dotfiles
# ---------------------------------------------
kvantum_source="$HOME/Hyprland-blizz/.config/Kvantum"
if [ -d "$kvantum_source" ]; then
    # If it exists, proceed with copying
    # Check if Kvantum directory exists in user's .config
    if [ ! -d "$HOME/.config/Kvantum" ]; then
        # If not, create it
        mkdir -p "$HOME/.config/Kvantum" || { echo 'Error creating Kvantum directory.'; exit 1; }
    fi
    
    # --------------------------------------------------------------------------
    # Copy and force overwrite Kvantum directory from dotfiles to user's .config
    # --------------------------------------------------------------------------
    cp -rf "$kvantum_source" "$HOME/.config/" || { echo 'Error copying Kvantum directory.'; exit 1; }
else
    echo 'Warning: Kvantum directory not found in dotfiles. Skipping Kvantum configuration.'
fi


# ------------------------------------------------------
# Copy dotfiles and directories to home directory
# ------------------------------------------------------
cp -r "$SCRIPT_DIR"/* ~/
cp -r .config ~/
cp -r .icons ~/
cp -r .Kvantum-themes ~/
#cp -r .themes ~/
cp -r .local ~/
cp -r Pictures ~/

echo "Don't worry, we need to check a few things before we can start the Hyprland installation..."

# Trim whitespaces from the CPU vendor
cpu_info=$(lscpu)

# Debug print to check CPU info
#echo "CPU Info: $cpu_info"

# ---------------------------------------------------------------------
# Check CPU vendor and execute AMD-specific code if AMD CPU is detected
# ---------------------------------------------------------------------

if [ "$cpu_vendor" == "AuthenticAMD" ]; then
    echo "AMD CPU detected. Running AMD-specific code..."

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
    echo "INTEL CPU detected. Running INTEL-specific code..."

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
    echo "Nvidia GPU detected. Installing Nvidia packages..."

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
    echo "Systemd-boot is in use."

    # Add nvidia_drm.modeset=1 to the kernel parameters
    # This is an example, modify it based on your specific requirements
    sed -i 's/ options / options nvidia_drm.modeset=1 /' $loader_entries/*.conf

    echo "Configuration modified for systemd-boot."
elif [ -f "/etc/kernel/install.d/90-loaderentry.install" ]; then
    # Bootloader is systemd-boot, modify configuration
    echo "Detected systemd-boot, modifying configuration..."

    # Add nvidia_drm.modeset=1 to the kernel parameters
    # This is an example, modify it based on your specific requirements
    sed -i 's/ options / options nvidia_drm.modeset=1 /' /boot/loader/entries/*.conf

    echo "Configuration modified for systemd-boot."
else
    # No systemd-boot detected, assuming GRUB or another bootloader
    echo "GRUB or another bootloader may be in use."
fi

# ------------------------------------------------------
# Check if kvantum is already installed or not
# ------------------------------------------------------

if ! command -v kvantummanager &> /dev/null; then
    echo "Kvantum is not installed. Proceeding with installation..."
    # Your installation commands for Kvantum go here
else
    echo "Kvantum is already installed. Skipping installation..."
fi


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
    read -p "DO YOU WANT TO START THE HYPRLAND INSTALLATION NOW? (Yy/Nn): " yn
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
            # cp -r .themes ~/
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
    echo "Plasma desktop is installed. Skipping installation of breeze-icons and breeze-default-cursor-theme."
else
    # ----------------------------------------------------
    # Install breeze-icons and breeze-default-cursor-theme
    # ----------------------------------------------------
    
    breeze_packages=("breeze-icons" "breeze-default-cursor-theme")

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
                echo "sddm installed."
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

# ------------------------------------------------------
# Start of the Hyprland installation
# ------------------------------------------------------

while true; do
    read -p "DO YOU WANT TO START THE HYPRLAND INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."

# Copy dotfiles and directories to home directory
echo "Copying dotfiles and directories to home directory..."
cp -r ~/Hyprland-blizz/* ~/

# Copy .config folder to home directory            
echo "Copying .config folder to home directory..."
cp -r ~/Hyprland-blizz/.config ~/

# Copy the following folders to home root directory
echo "Copying folders to home root directory..."
sudo cp -r ~/.icons /root/
sudo cp -r ~/.Kvantum-themes /root/
sudo cp -r ~/.themes /root/

# Uncomment the following line if you need to copy the Noto fonts folder
# echo "Copying Noto fonts folder to /usr/share/fonts..."
# sudo cp -r ~/.local/share/fonts/Noto /usr/share/fonts/

# Copy the following folders to the .config folder in the root directory
echo "Copying folders to /root/.config/..."
sudo cp -r ~/.config/fish /root/.config/            
sudo cp -r ~/.config/nwg-look /root/.config/            
sudo cp -r ~/.config/xsettingsd /root/.config/
sudo cp -r ~/.config/qt6ct /root/.config/
sudo cp -r ~/.config/kvantum /root/.config/
sudo cp -r ~/.config/starship /root/.config/
sudo cp -r ~/.config/gtk-3.0 /root/.config/

# Copy the individual files to the .config folder in the root directory
echo "Copying individual files to /root/.config/..."
sudo cp ~/.config/starship.toml /root/.config/
sudo cp ~/.config/starship-endeavouros.toml /root/.config/

# Copy sddm.conf to /etc/
echo "Copying sddm.conf to /etc/..."
sudo cp -r ~/Hyprland-blizz/sddm.conf /etc/

# Copy environment to /etc/
#sudo cp -r ~/Hyprland-blizz/environment /etc/

#echo "Script execution completed."


            # ----------------------------------------------------------------------------------------  
            # Install Nerd Fonts from Arch repositories
            # ----------------------------------------------------------------------------------------
            
            #echo "Please see yess to all the fonts (enter) is for all  these are needed for nvim !..."
            #sudo pacman -S nerd-fonts
                 

change_shell() {
    local shell="$1"
    local user="$2"
    local password="$3"

    read -p "Do you want to switch the $user shell to $shell? (Yy/Nn): " switch_shell

    if [[ "$switch_shell" == [Yy] ]]; then
        if echo "$password" | sudo -S chsh -s "$shell" "$user"; then
            echo "Shell changed to $shell successfully for the $user user."
        else
            echo "Changing shell to $shell failed for the $user user." >&2
            exit 1
        fi
    else
        echo "$user shell remains unchanged."
    fi
}

install_shell() {
    local shell="$1"
    local package_name

    # Determine the package name based on the shell
    case "$shell" in
        "/bin/bash") package_name="bash" ;;
        "/bin/zsh") package_name="zsh" ;;
        "/bin/fish") package_name="fish" ;;
        *) echo "Invalid shell specified: $shell" >&2 && exit 1 ;;
    esac

    if ! command -v "$shell" &> /dev/null; then
        echo "$shell is not installed. Installing $package_name..."
        if ! yay -S --noconfirm "$package_name"; then
            echo "Installation of $shell failed."
            exit 1
        fi
    else
        echo "$shell is already installed. Proceeding..."
    fi
}

echo "Available shells:"
echo "1. Bash"
echo "2. Zsh"
echo "3. Fish"
read -p "Enter the number corresponding to your preferred shell: " user_choice

case $user_choice in
    1) shell="/bin/bash" ;;
    2) shell="/bin/zsh" ;;
    3) shell="/bin/fish" ;;
    *) echo "Invalid choice. Exiting." && exit 1 ;;
esac

install_shell "$shell"

read -s -p "Enter password for $USER: " password
echo

change_shell "$shell" "$USER" "$password"

if sudo -v &> /dev/null; then
    read -p "Do you want to switch the root shell? (Yy/Nn): " switch_root
    if [[ "$switch_root" == [Yy] ]]; then
        echo "Available shells for root user:"
        echo "1. Bash"
        echo "2. Zsh"
        echo "3. Fish"
        read -p "Enter the number corresponding to the desired root shell: " root_choice

        case $root_choice in
            1) root_shell="/bin/bash" ;;
            2) root_shell="/bin/zsh" ;;
            3) root_shell="/bin/fish" ;;
            *) echo "Invalid choice. Exiting." && exit 1 ;;
        esac

        install_shell "$root_shell"
        change_shell "$root_shell" "root" "$password"
    else
        echo "Root shell remains unchanged."
    fi
else
    echo "sudo is not installed. Cannot switch root shell without sudo."
fi




            # ------------------------------------
            # Make the specified script executable
            # ------------------------------------
            
            chmod +x ~/.config/hypr/scripts/chmod_scripts.sh || { echo 'Making script executable failed.'; exit 1; }

            echo "Configuration files successfully copied to ~/ and ~/.config/"
            break;;
        [Nn]* ) 
            exit;
            break;;
        * ) echo "Please answer Yy or Nn.";;
    esac
done

# -------------------------------------------
# Check if packages-repository.txt is present
# -------------------------------------------
#
# Change directory to the script's location
    cd "$HOME/hyprland-installation/"

    if [ -f "$HOME/hyprland-installation/packages-repository.txt" ]; then
    # Read package names from repository.txt
    packages=$(<packages-repository.txt)

    # Filter out already installed packages
    packages_to_install=()
    for package in $packages; do
        if ! pacman -Qi "$package" &> /dev/null; then
            packages_to_install+=("$package")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        echo "All packages are already installed. Nothing to do."
    else
        # Use yay to install packages listed in repository.txt
        yay -S --noconfirm "${packages_to_install[@]}" || { echo 'Installation of AUR packages failed.'; exit 1; }
        echo "Packages from packages-repository.txt installed."
    fi
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
    echo "5. vivaldi"
}

# Function to handle invalid choice
handle_invalid_choice() {
    echo "Invalid choice. Exiting."
    exit 1
}

# Function to set default browser in /etc/environment
set_default_browser() {
    echo "export BROWSER=$browser" | sudo tee -a /etc/environment >/dev/null
    source /etc/environment
}

# Prompt user for choice
display_options
read -p "Enter the number corresponding to your choice: " choice

# Install the selected browser based on user's choice
case $choice in
    1) browser="chromium" ;;
    2) browser="firefox" ;;
    3) browser="brave-bin" ;;
    4) browser="microsoft-edge-stable-bin" ;;
    4) browser="vivaldi" ;;
    *) handle_invalid_choice ;;
esac

# Install the selected browser
echo "Installing $browser..."
if command -v yay &>/dev/null; then
    yay -S --noconfirm $browser
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm $browser
else
    echo "Error: Package manager (yay or pacman) not found. Exiting."
    exit 1
fi

# Function to set brave as default browser in /etc/environment
set_chromium_default() {
    # Check if Brave is installed
    if command -v chromium &>/dev/null || command -v chromium &>/dev/null; then
        sudo sed -i '/^#BROWSER=chromium/s/^#//' /etc/environment
        echo "chromium is installed. Setting as default browser."
    else
        echo "chromium is not installed. Skipping setting as default browser."
    fi
}

# Call the function to set brave as default browser
set_chromium_default

# Function to set brave as default browser in /etc/environment
set_firefox_default() {
    # Check if Brave is installed
    if command -v firefox &>/dev/null || command -v firefox &>/dev/null; then
        sudo sed -i '/^#BROWSER=firefox/s/^#//' /etc/environment
        echo "firefox is installed. Setting as default browser."
    else
        echo "firefox is not installed. Skipping setting as default browser."
    fi
}

# Call the function to set brave as default browser
set_firefox_default

# Function to set brave as default browser in /etc/environment
set_brave_default() {
    # Check if Brave is installed
    if command -v brave &>/dev/null || command -v brave-bin &>/dev/null; then
        sudo sed -i '/^#BROWSER=brave/s/^#//' /etc/environment
        echo "Brave is installed. Setting as default browser."
    else
        echo "Brave is not installed. Skipping setting as default browser."
    fi
}

# Call the function to set brave as default browser
set_brave_default

# Function to set brave as default browser in /etc/environment
set_edge_default() {
    # Check if Brave is installed
    if command -v edge &>/dev/null || command -v microsoft-edge-stable-bin &>/dev/null; then
        sudo sed -i '/^#BROWSER=microsoft-edge-stable/s/^#//' /etc/environment
        echo "Edge is installed. Setting as default browser."
    else
        echo "Edge is not installed. Skipping setting as default browser."
    fi
}

# Call the function to set brave as default browser
set_edge_default

# Function to set brave as default browser in /etc/environment
set_vivaldi_default() {
    # Check if Brave is installed
    if command -v vivaldi &>/dev/null || command -v vivaldi &>/dev/null; then
        sudo sed -i '/^#BROWSER=vivaldi/s/^#//' /etc/environment
        echo "vivaldi is installed. Setting as default browser."
    else
        echo "vivaldi is not installed. Skipping setting as default browser."
    fi
}

# Call the function to set brave as default browser
set_vivaldi_default

# ------------------------------------------------------
# Check if Geany is installed
# ------------------------------------------------------

if command -v geany &> /dev/null; then
    # Set Geany as the default editor
    echo "export VISUAL=geany" | sudo tee -a /etc/environment
    echo "export EDITOR=geany" | sudo tee -a /etc/environment
    echo "Geany set as the default editor."
else
    echo "Geany is not installed. Installing Geany..."
    # Add installation command for Geany
    sudo pacman -Sy --noconfirm geany
    # Check if the installation was successful
    if command -v geany &> /dev/null; then
        echo "Geany installed successfully. Setting it as the default editor."
        echo "export VISUAL=geany" | sudo tee -a /etc/environment
        echo "export EDITOR=geany" | sudo tee -a /etc/environment
        echo "Geany set as the default editor."
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
rm  -rf $HOME/install.sh
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

