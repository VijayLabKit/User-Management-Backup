#!/bin/bash
# Script: User Management & Backup
# Author: Vijay
# Enhanced: Logging, Error Handling, Optional Email, Restore Backup

LOG_FILE="/var/log/user_mgmt.log"
BACKUP_DIR="/var/backups/custom_backup"
EMAIL="yourname@gmail.com"   # Change this if email alerts are set up

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a "$LOG_FILE"
}

add_user() {
    read -p "Enter username to add: " username
    if id "$username" &>/dev/null; then
        log_action "ERROR: User $username already exists."
    else
        sudo useradd -m "$username" && sudo passwd "$username"
        [ $? -eq 0 ] && log_action "SUCCESS: User $username added." || log_action "ERROR: Failed to add $username."
    fi
}

delete_user() {
    read -p "Enter username to delete: " username
    if id "$username" &>/dev/null; then
        sudo userdel -r "$username" && log_action "SUCCESS: User $username deleted." || log_action "ERROR: Failed to delete $username."
    else
        log_action "ERROR: User $username does not exist."
    fi
}

modify_user() {
    read -p "Enter username to modify: " username
    if id "$username" &>/dev/null; then
        read -p "Enter new shell (e.g., /bin/bash): " shell
        sudo usermod -s "$shell" "$username" && log_action "SUCCESS: $username shell changed to $shell." || log_action "ERROR: Failed to modify $username."
    else
        log_action "ERROR: User $username does not exist."
    fi
}

create_group() {
    read -p "Enter group name: " group
    if getent group "$group" >/dev/null; then
        log_action "ERROR: Group $group already exists."
    else
        sudo groupadd "$group" && log_action "SUCCESS: Group $group created." || log_action "ERROR: Failed to create group $group."
    fi
}

backup_directory() {
    read -p "Enter directory path to backup: " dir
    if [ ! -d "$dir" ]; then
        log_action "ERROR: Directory $dir does not exist."
        return
    fi
    timestamp=$(date +%F_%H-%M-%S)
    mkdir -p "$BACKUP_DIR"
    backup_file="$BACKUP_DIR/backup_$timestamp.tar.gz"
    tar -czf "$backup_file" "$dir"
    if [ $? -eq 0 ]; then
        log_action "SUCCESS: Backup of $dir completed at $backup_file"
        if command -v mail >/dev/null; then
            echo "Backup of $dir completed successfully." | mail -s "Backup Notification" "$EMAIL"
        fi
    else
        log_action "ERROR: Backup of $dir failed."
    fi
}

restore_backup() {
    echo "Available backups:"
    ls -1 "$BACKUP_DIR"
    read -p "Enter the backup file name to restore: " file
    if [ -f "$BACKUP_DIR/$file" ]; then
        read -p "Enter destination directory to restore into: " dest
        mkdir -p "$dest"
        tar -xzf "$BACKUP_DIR/$file" -C "$dest"
        [ $? -eq 0 ] && log_action "SUCCESS: Restored $file into $dest" || log_action "ERROR: Restore failed."
    else
        log_action "ERROR: Backup file not found."
    fi
}

while true; do
    echo -e "\n--- User Management & Backup Script ---"
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. Modify User"
    echo "4. Create Group"
    echo "5. Backup Directory"
    echo "6. Restore Backup"
    echo "7. Exit"
    read -p "Choose an option: " choice

    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) modify_user ;;
        4) create_group ;;
        5) backup_directory ;;
        6) restore_backup ;;
        7) log_action "INFO: Script exited by user."; exit 0 ;;
        *) echo "Invalid option. Try again." ;;
    esac
done
