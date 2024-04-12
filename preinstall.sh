#!/bin/bash

# Function to reboot the system
reboot_system() {
    echo "Rebooting the system..."
    sleep 5
    reboot
}

# Check if /home entry exists in fstab
if grep -qs '/home' /etc/fstab; then
    # Remove existing /home entry from fstab
    sed -i '/\/home/d' /etc/fstab
    echo "Removed existing /home entry from /etc/fstab."
fi

# Generate UUID-based line for the new entry
new_entry=UUID=22bf653b-1b13-4468-90b2-1f40bb14aa6e /home btrfs subvol=/@home,noatime,space_cache=v2,discard=async,ssd,compress=zstd:3 0 2

# Add new entry to fstab
echo "$new_entry" >> /etc/fstab
echo "Added new entry for /home to /etc/fstab."

# Optionally, reboot the system
# Uncomment the line below to enable auto-reboot
# reboot_system
