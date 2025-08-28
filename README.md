# 🐧 User Management & Backup Script  

## 📌 Overview  
This project provides a **Linux shell script** to automate **user management** and **backup tasks**.  
It helps system administrators manage users/groups efficiently and ensures reliable backups of important directories.  

---

## ✨ Features  
- 👤 **User Management**
  - Add users (with password prompt)  
  - Delete users  
  - Modify user shell  

- 👥 **Group Management**
  - Create new groups  

- 💾 **Backup System**
  - Compress & archive any directory  
  - Store backups in `/var/backups/custom_backup/`  
  - Timestamped backup files for uniqueness  

- 🔄 **Restore System**
  - Restore backups into a chosen directory  

- 📝 **Logging**
  - All actions logged in `/var/log/user_mgmt.log`  

- 📧 **Email Alerts (Optional)**
  - Sends backup completion notifications (if `mail` is installed)  

---

## ⚙️ Requirements  
- Linux OS (Ubuntu/Debian recommended)  
- Bash shell  
- `tar` (default in Linux)  
- `mailutils` (optional, only if you want email alerts)  

---

## 🚀 How to Run  

1. Clone this repo:  
```bash
git clone https://github.com/VijayLabKit/User-Management-Backup.git
cd User-Management-Backup

