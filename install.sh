#!/bin/bash
# ------------------------------------
# █▀█ █▀▀ █▀▄ █▄▄ █░░ █ ▀█ ▄▀█ █▀█ █▀▄
# █▀▄ ██▄ █▄▀ █▄█ █▄▄ █ █▄ █▀█ █▀▄ █▄▀
# ------------------------------------
echo "Install script version release 1.04"
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
cp -r .themes ~/
cp -r .local ~/
cp -r Pictures ~/

echo "Don't worry, we need to check a few things before we can start the Hyprland installation..."

# Trim whitespaces from the CPU vendor
cpu_info=$(lscpu)

# Debug print to check CPU info
echo "CPU Info: $cpu_info"

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

echo -e "${GREEN}"
cat <<"EOF"
█░█░█ █▀▀ █░░ █▀▀ █▀█ █▀▄▀█ █▀▀   ▀█▀ █▀█
▀▄▀▄▀ ██▄ █▄▄ █▄▄ █▄█ █░▀░█ ██▄   ░█░ █▄█


▀█▀ █░█ █▀▀
░█░ █▀█ ██▄


█░█ █▄█ █▀█ █▀█ █░░ ▄▀█ █▄░█ █▀▄ ▄▄ █▄▄ █░░ █ ▀█ ▀█
█▀█ ░█░ █▀▀ █▀▄ █▄▄ █▀█ █░▀█ █▄▀ ░░ █▄█ █▄▄ █ █▄ █▄


█ █▄░█ █▀ ▀█▀ ▄▀█ █░░ █░░ █▀▀ █▀█
█ █░▀█ ▄█ ░█░ █▀█ █▄▄ █▄▄ ██▄ █▀▄

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
            cp -r .themes ~/
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


# ------------------------------------------------------
# Check if SDDM configuration file exists
# ------------------------------------------------------

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
sudo cp -r ~/.config/qt5ct /root/.config/
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

echo "Script execution completed."


            # ----------------------------------------------------------------------------------------  
            # Install Nerd Fonts from Arch repositories
            # ----------------------------------------------------------------------------------------
            
            echo "Please see yess to all the fonts (enter) is for all  these are needed for nvim !..."
            sudo pacman -S nerd-fonts
                 

            # ------------------------------------------------------  
            # Check if Fish is installed
            # ------------------------------------------------------
            
            if ! command -v fish &> /dev/null; then
                echo "Fish is not installed. Installing Fish..."
                sudo pacman -Sy --noconfirm fish || { echo 'Installation of Fish failed.'; exit 1; }
            fi

            # ------------------------------------------------------
            # Change user shell to Fish (optional)
            # ------------------------------------------------------

            read -p "Do you want to switch your shell to Fish? (y/n): " switch_user_shell

            if [ "$switch_user_shell" == "y" ]; then
            if chsh -s "/usr/bin/fish"; then
            echo "Shell changed to Fish successfully for the user."
            else
            echo "Changing shell to Fish failed for the user." >&2
            exit 1
            fi
            else
            echo "User shell remains unchanged."
            fi

            # ------------------------------------------------------
            # Change root shell to Fish (optional)
            # ------------------------------------------------------

            read -p "Do you want to switch the root shell to Fish? (y/n): " switch_root_shell

            if [ "$switch_root_shell" == "y" ]; then
            if sudo chsh -s "/usr/bin/fish" root; then
            echo "Shell changed to Fish successfully for the root user."
            else
            echo "Changing shell to Fish failed for the root user." >&2
            exit 1
            fi
            else
            echo "Root shell remains unchanged."
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
        * ) echo "Please answer yes or no.";;
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

# ------------------------------------------------------
# Check if Brave is installed
# ------------------------------------------------------

if command -v brave &> /dev/null; then

    # --------------------------------
    # Set Brave as the default browser
    # --------------------------------
    
    xdg-settings set default-web-browser brave.desktop
    echo "Brave set as the default browser."
else
    echo "Brave is not installed. Please install Brave first."
    
    # ---------------------------------------------
    # Add installation command for Brave if needed
    # Example: sudo pacman -Sy --noconfirm brave
    # ---------------------------------------------
fi

# ------------------------------------------------------
# Check if Firefox is installed
# ------------------------------------------------------

if command -v firefox &> /dev/null; then
    # -------------------------------------
    # Remove Firefox as the default browser
    # -------------------------------------
    
    xdg-settings set default-web-browser firefox.desktop
    echo "Firefox set as the secondary browser."
else
    echo "Firefox is not installed."
fi

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

# ------------------------------------------------------
# Check the current Waybar configuration path
# ------------------------------------------------------

CURRENT_CONFIG=$(readlink -f ~/.config/waybar/config.jsonc)

# ----------------------------------------------------------
# Define the paths for the desktop and laptop configurations
# ----------------------------------------------------------

DESKTOP_CONFIG_PATH=~/.config/waybar/conf/w1-config-desktop.jsonc
LAPTOP_CONFIG_PATH=~/.config/waybar/conf/w2-config-laptop.jsonc

# --------------------------------------------------
# Define the paths for the desktop and laptop styles
# --------------------------------------------------

DESKTOP_STYLE_PATH=~/.config/waybar/style/w1-style.css
LAPTOP_STYLE_PATH=~/.config/waybar/style/w2-style.css

# ----------------------------------------------------------
# Check the current configuration and switch to the opposite
# ----------------------------------------------------------

if [ "$CURRENT_CONFIG" = "$DESKTOP_CONFIG_PATH" ]; then
    ln -sf "$LAPTOP_CONFIG_PATH" ~/.config/waybar/config.jsonc
    ln -sf "$LAPTOP_STYLE_PATH" ~/.config/waybar/style.css
else
    ln -sf "$DESKTOP_CONFIG_PATH" ~/.config/waybar/config.jsonc
    ln -sf "$DESKTOP_STYLE_PATH" ~/.config/waybar/style.css
fi

# ------------------------------------------------------
# Check if SDDM is installed
# ------------------------------------------------------
if command -v sddm &> /dev/null; then
    # ------------------------------------------------------
    # SDDM is already installed, copy custom sddm.conf
    # ------------------------------------------------------
    sudo cp -rf "$HOME/Hyprland-blizz/sddm.conf" /etc/ || { echo 'Error copying sddm.conf.'; exit 1; }
else
    # ------------------------------------------------------
    # SDDM is not installed, prompt user to install and enable
    # ------------------------------------------------------

    echo "just a friendly reminder it is (preferred) that you say yes to SDDM to be enabled keep that in mind!!!"

    read -p "Do you want to enable SDDM? (yes/no): " enable_sddm
    case $enable_sddm in
        [Yy]* )

            # -----------------------------
            # Install and enable SDDM
            # -----------------------------

            if yay -S --noconfirm sddm; then
                echo "SDDM installed."
                sudo systemctl enable sddm
                echo "SDDM enabled. Continuing with the rest of the script."
                # Copy custom sddm.conf
                sudo cp -rf "$HOME/Hyprland-blizz/sddm.conf" /etc/ || { echo 'Error copying sddm.conf.'; exit 1; }
            else
                echo "Failed to install SDDM with yay. Exiting."
                exit 1
            fi
            ;;
        [Nn]* )
            echo "SDDM not enabled. You can enable it later by configuring /etc/sddm.conf."
            echo "Done!";;
        * )
            echo "Invalid choice. Please answer yes or no."
            exit 1;;
    esac
fi

# ------------------------------------------------------
# Set SDDM theme
# ------------------------------------------------------
sddm_theme="simplicity"

# Prompt user for confirmation before setting the theme
read -p "Do you want to set the SDDM theme to $sddm_theme? (yes/no): " set_theme_confirmation
case $set_theme_confirmation in
    [Yy]* )
        sudo kvantummanager --set "$sddm_theme"
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
# Change qt5ct settings to use Kvantum theme for the user
# ------------------------------------------------------

echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> ~/.bashrc || { echo 'Setting QT_QPA_PLATFORMTHEME for the user failed.'; exit 1; }
echo "export QT_STYLE_OVERRIDE=kvantum-dark" >> ~/.bashrc || { echo 'Setting QT_STYLE_OVERRIDE for the user failed.'; exit 1; }

echo "Just a friendly reminder, the Kvantum-themes directory is hidden!!"

# ------------------------------------------------------
# Use kvantummanager to set the theme
# ------------------------------------------------------
kvantummanager --set Catppuccin-Frappe-Blue

# ------------------------------------------------------
# Change qt5ct settings to use Kvantum theme for root
# ------------------------------------------------------

echo "export QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment || { echo 'Setting QT_QPA_PLATFORMTHEME for root failed.'; exit 1; }
echo "export QT_STYLE_OVERRIDE=kvantum-dark" | sudo tee -a /etc/environment || { echo 'Setting QT_STYLE_OVERRIDE for root failed.'; exit 1; }

  
echo "Just a friendly reminder, the Kvantum-themes directory is hidden on root to!!"

# ------------------------------------------------------
# Use kvantummanager to set the theme
# ------------------------------------------------------

sudo kvantummanager --set Catppuccin-Frappe-Blue


# ----------------------------
#Change GTK-Theme for the user
# ----------------------------

echo "Setting GTK theme..."
/usr/bin/gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Frappe-Standard-Blue-Dark'

# -----------------------------------------
#Change the default Icon-Theme for the user
# -----------------------------------------

echo "Setting icon theme..."
/usr/bin/gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# -------------------------------
#Change Window-Theme for the user
# -------------------------------

echo "Setting icon theme..."
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
rm -rf $HOME/hyprland-installation
rm -rf $HOME/hyprland-blizz
rm $HOME/README.md
rm -rf $HOME/sddm-images
rm $HOME/packages-repository.txt
rm $HOME/install.sh
rm $HOME/sddm.conf

echo -e "${green}"
cat <<"EOF"
█░█░█ █▀▀ █░░ █▀▀ █▀█ █▀▄▀█ █▀▀
▀▄▀▄▀ ██▄ █▄▄ █▄▄ █▄█ █░▀░█ ██▄


▀█▀ █▀█   █░█ █▄█ █▀█ █▀█ █░░ ▄▀█ █▄░█ █▀▄
░█░ █▄█   █▀█ ░█░ █▀▀ █▀▄ █▄▄ █▀█ █░▀█ █▄▀

EOF
echo -e "${NONE}"

echo   "Your system is now configured with Hyprland."

echo -e "${green}"
cat <<"EOF"
▄▀█ █░░ █░░   █░█ █▀ █▀▀ █▀█ █▀   █▀ █▀▀ ▀█▀   █▄█ █▀█ █░█ █▀█   █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀
█▀█ █▄▄ █▄▄   █▄█ ▄█ ██▄ █▀▄ ▄█   ▄█ ██▄ ░█░   ░█░ █▄█ █▄█ █▀▄   ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█

EOF
echo -e "${NONE}"         

echo ""
echo "Open ~/.config/hypr/hyprland.conf to change your keyboard layout (default is us) and your screen resolution best to change the moinitors to (default is preferred) and change keybinds if needed."
echo "Open ~/.config/waybar/conf/w1-config-desktop.jsonc and ~/.config/waybar/conf/w2-config-laptop.jsonc and edit the outputs if needed."
echo "Open ~/.config/waybar/conf/w1-config-desktop.jsonc and ~/.config/waybar/conf/w2-config-laptop.jsonc and edit the network device see the traffic module!!!"
echo ""

echo -e "${green}"
cat <<"EOF"
█▄░█ █░█ █ █▀▄ █ ▄▀█   █░█ █▀ █▀▀ █▀█ █▀
█░▀█ ▀▄▀ █ █▄▀ █ █▀█   █▄█ ▄█ ██▄ █▀▄ ▄█

echo "Open ~/.config/hypr/hyprland.conf NVIDIA USERS PAY ATTENTION BY DEFAULT THE NVIDIA ENV RULES HAVE A COMMENT IN FRONT OF EACH LINE YOU NEED TO REMOVE THE COMMENT (#)"
echo "Open ~/.config/hypr/hyprland.conf NVIDIA USERS YOU NEED TO PLACE A COMMENT (#) IN FRONT OF THE FOLLOWING LINE env=WLR_NO_HARDWARE_CURSORS=1 !!!"

EOF
echo -e "${none}"

echo ""
# Now you are fully ready and can reboot your system / if you encounter any problems related to the configuration get in contact with RedBlizard
echo "DONE!"
echo "Then reboot your system!"

