#!/bin/bash
# ------------------------------------------------------
# developed by RedBlizard November 2023
# Install script version release 002
# ------------------------------------------------------

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
# Create the Hyprland-blizz-nvidia directory if not present
# ------------------------------------------------------

mkdir -p "$HOME/Hyprland-blizz-nvidia" || { echo 'Failed to create Hyprland-blizz-nvidia directory.'; exit 1; }

# ------------------------------------------------------
# Change into the Hyprland-blizz-nvidia directory
# ------------------------------------------------------

cd "$HOME/Hyprland-blizz-nvidia" || { echo 'Failed to change directory to Hyprland-blizz-nvidia.'; exit 1; }


# ------------------------------------------------------
# Clone the dotfiles repository
# ------------------------------------------------------

echo "Cloning dotfiles repository..."
git clone "https://github.com/RedBlizard/Hyprland-blizz-nvidia.git" . || { echo 'Failed to clone dotfiles repository.'; exit 1; }


# ------------------------------------------------------
# Copy dotfiles and directories to home directory
# ------------------------------------------------------
cp -r "$SCRIPT_DIR"/* ~/
cp -r .icons ~/
cp -r .Kvantum-themes ~/
cp -r .themes ~/
cp -r .local ~/
cp -r Pictures ~/

# ------------------------------------------------------
# Copy .config folder to home directory
# ------------------------------------------------------

cp -r .config ~/

# ------------------------------------------------------
# Check if Kvantum directory exists in user's .config
# ------------------------------------------------------

if [ ! -d "$HOME/.config/Kvantum" ]; then
    # If not, create it
    mkdir -p "$HOME/.config/Kvantum" || { echo 'Error creating Kvantum directory.'; exit 1; }   
    
fi

# --------------------------------------------------------------------------
# Copy and force overwrite Kvantum directory from dotfiles to user's .config
# --------------------------------------------------------------------------

cp -rf "$HOME/Hyprland-blizz-nvidia/.config/Kvantum" "$HOME/.config/" || { echo 'Error copying Kvantum directory.'; exit 1; }


# ------------------------------------------------------
# Check CPU vendor
# ------------------------------------------------------

echo "Don't worry, we need to check a few things before we can start the Hyprland installation..."
cpu_vendor=$(lscpu | grep -i "vendor" | awk '{print $2}')

# ---------------------------------------------------------------------
# Check CPU vendor and execute AMD-specific code if AMD CPU is detected
# ---------------------------------------------------------------------

if [ "$cpu_vendor" == "AuthenticAMD" ]; then
    echo "AMD CPU detected. Running AMD-specific code..."
else
    echo "Not an AMD CPU. Skipping AMD-specific code."
fi

# -------------------------------------------------------------------
# Check CPU vendor and execute INTEL-specific code if CPU is detected
# -------------------------------------------------------------------

if [ "$cpu_vendor" == "GenuineIntel" ]; then
    echo "INTEL CPU detected. Running INTEL-specific code..."
else
    echo "Not an INTEL CPU. Skipping INTEL-specific code."
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


echo ""
echo "WELCOME TO THE HYPRLAND STARTER INSTALLATION SCRIPT"
echo "------------------------------------------------------"
echo ""
echo "Please make sure that you run this script from /home/Hyprland-blizz-nvidia/"
echo "Backup existing configurations in .config if needed."
echo ""

# ------------------------------------------------------
# Change to the Hyprland-blizz-nvidia directory
# ------------------------------------------------------
cd "$HOME/Hyprland-blizz-nvidia/" || { echo 'Failed to change directory to Hyprland-blizz-nvidia.'; exit 1; }


# ----------------------------------
# Start of the Hyprland installation
# ----------------------------------

while true; do
    read -p "DO YOU WANT TO START THE HYPRLAND INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
            
            # --------------------------------------------------
            # Create the Hyprland-blizz-nvidia directory if not present
            # --------------------------------------------------
            
            mkdir -p "$HOME/Hyprland-blizz-nvidia-nvidia" || { echo 'Failed to create Hyprland-blizz-nvidia directory.'; exit 1; }
            
            # ----------------------------------------
            # Change into the Hyprland-blizz-nvidia directory
            # ----------------------------------------
            
            cd "$HOME/Hyprland-blizz-nvidia-nvidia" || { echo 'Failed to change directory to Hyprland-blizz-nvidia.'; exit 1; }

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

# -----------------------------------------------
# Copy dotfiles and directories to home directory
# -----------------------------------------------

echo "Copying dotfiles and directories to home directory..."
cp -r ~/Hyprland-blizz-nvidia/* ~/

# -------------------------------------
# Copy .config folder to home directory
# -------------------------------------

echo "Copying .config folder to home directory..."
cp -r ~/Hyprland-blizz-nvidia/.config ~/

# -------------------------------------------------
# Copy the following folders to home root directory
# -------------------------------------------------

echo "Copying folders to home root directory..."
sudo cp -r ~/.icons /root/
sudo cp -r ~/.Kvantum-themes /root/
sudo cp -r ~/.themes /root/

# Uncomment the following line if you need to copy the Noto fonts folder
# echo "Copying Noto fonts folder to /usr/share/fonts..."
# sudo cp -r ~/.local/share/fonts/Noto /usr/share/fonts/

# ----------------------------------------------------------------------
# Copy the following folders to the .config folder in the root directory
# ----------------------------------------------------------------------

echo "Copying folders to /root/.config/..."
sudo cp -r ~/.config/fish /root/.config/
sudo cp -r ~/.config/nwg-look /root/.config/
sudo cp -r ~/.config/xsettingsd /root/.config/
sudo cp -r ~/.config/qt5ct /root/.config/
sudo cp -r ~/.config/kvantum /root/.config/
sudo cp -r ~/.config/starship /root/.config/
sudo cp -r ~/.config/gtk-3.0 /root/.config/

# ---------------------------------------------------------------------
# Copy the individual files to the .config folder in the root directory
# ---------------------------------------------------------------------

echo "Copying individual files to /root/.config/..."
sudo cp ~/.config/starship.toml /root/.config/
sudo cp ~/.config/starship-endeavouros.toml /root/.config/

# -----------------------
# Copy sddm.conf to /etc/
# -----------------------

echo "Copying sddm.conf to /etc/..."
sudo cp -r ~/Hyprland-blizz-nvidia/sddm.conf /etc/

echo "Script execution completed."


            # -------------------------------            
            # Set the Qogir-dark cursor theme
            # -------------------------------
            
            xsetroot -cursor_name left_ptr 

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

            # ---------------------
            # Find the path to Fish
            # ---------------------
            
            fish_path=$(command -v fish)

            # -------------------------
            # Change user shell to Fish
            # -------------------------
            
            if sudo chsh -s "$fish_path" "$USER"; then
                echo "Shell changed to Fish successfully for the user."
            else
                echo "Changing shell to Fish failed for the user." >&2
                exit 1
            fi

            # ------------------------------------------------------  
            # Change root shell to Fish
            # ------------------------------------------------------
            
            if sudo chsh -s "$fish_path" root; then
                echo "Shell changed to Fish successfully for the root user."
            else
                echo "Changing shell to Fish failed for the root user." >&2
                exit 1
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
# -----------------------------------------
# Change directory to the script's location
# -----------------------------------------

cd "$HOME/hyprland-installation/"

if [ -f "packages-repository.txt" ]; then
    # --------------------------------------
    # Read package names from repository.txt
    # --------------------------------------
    packages=$(<packages-repository.txt)

    # -------------------------------------
    # Filter out already installed packages
    # -------------------------------------
    
    packages_to_install=()
    for package in $packages; do
        if ! pacman -Qi "$package" &> /dev/null; then
            packages_to_install+=("$package")
        fi
    done

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        echo "All packages are already installed. Nothing to do."
    else
    
        # ----------------------------------------------------
        # Use yay to install packages listed in repository.txt
        # ----------------------------------------------------
        
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
    # -------------------------------
    # Set Geany as the default editor
    # -------------------------------
    
    sudo update-alternatives --set editor /usr/bin/geany
    echo "Geany set as the default editor."
else
    echo "Geany is not installed. Installing Geany..."
    # ----------------------------------
    # Add installation command for Geany
    # ----------------------------------
    
    sudo pacman -Sy --noconfirm geany
    
    # ----------------------------------------
    # Check if the installation was successful
    # ----------------------------------------
    
    if command -v geany &> /dev/null; then
        echo "Geany installed successfully. Setting it as the default editor."
        sudo update-alternatives --set editor /usr/bin/geany
        echo "Geany set as the default editor."
    else
        echo "Failed to install Geany. Please install it manually and set it as the default editor."
        # -------------------------------------------------------------------
        # You may choose to exit the script here or continue with other tasks
        # -------------------------------------------------------------------
    fi
fi


# ------------------------------------------------------
# Remove unwanted folders from /usr/share/sddm/themes
# ------------------------------------------------------

sudo rm -rf /usr/share/sddm/themes/{elarun, maldives, maya} || { echo 'Removal of unwanted folders failed.'; exit 1; }

# ------------------------------------------------------
# Print debug information
# ------------------------------------------------------
echo "Contents of sddm-images directory:"
ls -la ~/Hyprland-blizz/sddm-images

# ------------------------------------------------------
# Copy sddm-images to /usr/share/sddm/themes/simplicity/images
# ------------------------------------------------------

echo "Copying sddm-images to /usr/share/sddm/themes/simplicity/images..."
sudo cp -r ~/Hyprland-blizz/sddm-images/* /usr/share/sddm/themes/simplicity/images || { echo 'Copy of images failed.'; exit 1; }

# ------------------------------------------------------
# Print debug information after copying
# ------------------------------------------------------
echo "Contents of /usr/share/sddm/themes/simplicity/images:"
ls -la /usr/share/sddm/themes/simplicity/images

# ------------------------------------------------------
# Set SDDM theme
# ------------------------------------------------------
sddm_theme="simplicity"

# ------------------------------------------------------
# Check if SDDM configuration file exists
# ------------------------------------------------------

sddm_conf="/etc/sddm.conf"
if [ -f "$sddm_conf" ]; then

    # -------------------------------------
    # Update or add the theme configuration
    # -------------------------------------
    
    if grep -q "^Current=" "$sddm_conf"; then
        sudo sed -i "s/^Current=.*/Current=$sddm_theme/" "$sddm_conf"
    else
        echo -e "[Theme]\nCurrent=$sddm_theme" | sudo tee -a "$sddm_conf" > /dev/null
    fi
    
    # --------------------------------------------------------------------------
    # Removed the restart command, as it will be done after the script completes
    # --------------------------------------------------------------------------
    
else
    echo "Error: $sddm_conf not found. Make sure SDDM is installed."
    exit 1
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

----------------------------------------------------
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
# Prompt user to enable SDDM
# ------------------------------------------------------

echo "just a friendly reminder it is (preferred) that you say yes to SDDM to be enabled keep that in mind!!!"

read -p "Do you want to enable SDDM? (yes/no): " enable_sddm
case $enable_sddm in
    [Yy]* )
    
        # -----------------------------
        # Check if LightDM is installed
        # -----------------------------
        
        if pacman -Qs "lightdm" &> /dev/null; then
        
            # ---------------
            # Disable LightDM
            # ---------------
            
            sudo systemctl disable lightdm
            echo "LightDM disabled."
        fi
        
        # -----------
        # Enable SDDM
        # -----------
        
        sudo systemctl enable sddm
        echo "SDDM enabled. Continuing with the rest of the script.";;
    [Nn]* )
        echo "SDDM not enabled. You can enable it later by configuring /etc/sddm.conf."
        echo "Done!";;
    * ) 
        echo "Invalid choice. Please answer yes or no."
        exit 1;;
esac

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

# ------------------------------------------------------
# Change Papirus folder colors for the user
# ------------------------------------------------------
papirus-folders -C cat-frappe-blue --theme Papirus-Dark

# ------------------------------------------------------
# Change Papirus folder colors for root
# ------------------------------------------------------
sudo papirus-folders -C cat-frappe-blue --theme Papirus-Dark

echo ""
echo "DONE!"
echo "Open ~/.config/hypr/hyprland.conf to change your keyboard layout (default is us) and your screen resolution best to change the moinitors to (default is preferred) and change keybinds if needed."
echo "Open ~/.config/waybar/conf/w1-config-desktop.jsonc and ~/.config/waybar/conf/w2-config-laptop.jsonc and edit the outputs."
echo "Open ~/.config/waybar/conf/w1-config-desktop.jsonc and ~/.config/waybar/conf/w2-config-laptop.jsonc and edit the network device see the traffic module!!!"
echo "Then reboot your system!"
