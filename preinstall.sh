#!/bin/bash

# Function to reboot the system
reboot_system() {
    echo "Rebooting the system..."
    sleep 5
    reboot
}

# Check if /home exists and is mounted
if grep -qs '/home' /proc/mounts; then
    # Get the device path of /home
    home_device=$(df -P /home | awk 'NR==2 {print $1}')
    
    # Check if it's a Btrfs filesystem
    if blkid -o value -s TYPE "$home_device" | grep -q '^btrfs$'; then
        # Check if there's no subvolume specified
        if ! mount | grep -qs 'subvol='; then
            # Remove existing /home entry from fstab
            sed -i "\%$home_device%Id" /etc/fstab
            
            # Generate UUID-based line
            uuid=$(blkid -o value -s UUID "$home_device")
            new_entry="UUID=$uuid /home btrfs subvol=/@home,noatime,space_cache=v2,discard=async,ssd,compress=zstd:3 0 2"
            
            # Add new entry to fstab
            echo "$new_entry" >> /etc/fstab
            echo "Updated /etc/fstab with the new entry for /home."
            
            # Reboot the system
            reboot_system
        else
            echo "The /home partition already has a subvolume specified."
        fi
    else
        echo "The /home partition is not on a Btrfs filesystem."
    fi
else
    echo "The /home partition is not currently mounted."
fi
