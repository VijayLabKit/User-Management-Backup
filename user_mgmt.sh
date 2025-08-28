#!/bin/bash
# Script: User Management & Backup
# Author: You
# Enhanced with Logging, Error Handling, and Email Alerts

LOG_FILE="/var/log/user_mgmt.log"
BACKUP_DIR="/var/backups/custom_backup"
EMAIL="ishanchowdhury2018@gmail.com"   # Change this to your email

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" | tee -a "$LOG_FILE"
}
add_user() {
    read -p "Enter username to add: " username
    if id "$username" &>/dev/null; then
        log_action "ERROR: User $username already exists."
    else
        sudo useradd -m "$username"
        if [ $? -eq 0 ]; then
            sudo passwd "$username"   # this will ask you to type password interactively
            log_action "SUCCESS: User $username added with password set."
        else
            log_action "ERROR: Failed to add user $username."
        fi
    fi
}

delete_user() {
    read -p "Enter username to delete: " username
    if id "$username" &>/dev/null; then
        if sudo userdel -r "$username"; then
            log_action "SUCCESS: User $username deleted."
        else
            log_action "ERROR: Failed to delete user $username."
        fi
    else
        log_action "ERROR: User $username does not exist."
    fi
}

modify_user() {
    read -p "Enter username to modify: " username
    if id "$username" &>/dev/null; then
        read -p "Enter new shell (e.g., /bin/bash): " shell
        if sudo usermod -s "$shell" "$username"; then
            log_action "SUCCESS: User $username shell changed to $shell."
        else
            log_action "ERROR: Failed to modify user $username."
        fi
    else
        log_action "ERROR: User $username does not exist."
    fi
}

create_group() {
    read -p "Enter group name: " group
    if getent group "$group" >/dev/null; then
        log_action "ERROR: Group $group already exists."
    else
        if sudo groupadd "$group"; then
            log_action "SUCCESS: Group $group created."
        else
            log_action "ERROR: Failed to create group $group."
        fi
    fi
}

backup_directory() {
    read -p "Enter directory path to backup: " dir
    if [ ! -d "$dir" ]; then
        log_action "ERROR: Directory $dir does not exist."
        return
    fi
    timestamp=$(date +%F_%T)
    mkdir -p "$BACKUP_DIR"
    if tar -czf "$BACKUP_DIR/backup_$timestamp.tar.gz" "$dir"; then
        log_action "SUCCESS: Backup of $dir completed at $BACKUP_DIR/backup_$timestamp.tar.gz"
        # Send email notification (requires mailutils or postfix installed)
        echo "Backup of $dir completed successfully." | mail -s "Backup Notification" "$EMAIL"
    else
        log_action "ERROR: Backup of $dir failed."
    fi
}

while true; do
    echo -e "\n--- User Management & Backup Script ---"
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. Modify User"
    echo "4. Create Group"
    echo "5. Backup Directory"
    echo "6. Exit"
    read -p "Choose an option: " choice

    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) modify_user ;;
        4) create_group ;;
        5) backup_directory ;;
        6) log_action "INFO: Script exited by user."; exit 0 ;;
        *) echo "Invalid option. Try again." ;;
    esac
done
