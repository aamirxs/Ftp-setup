# Advanced Ubuntu FTP Server Installer

## Overview
This comprehensive bash script automates the installation and configuration of a secure FTP server on Ubuntu 22.04 and 24.04 LTS. Designed for system administrators and developers, the script provides a robust, secure, and easily deployable FTP solution.

## Features

### 🔒 Enhanced Security
- SSL/TLS Certificate Generation
- Fail2Ban Integration
- Advanced PAM Password Policies
- Strict Firewall Configuration
- Chroot User Isolation
- Connection Rate Limiting

### 🚀 Key Capabilities
- Automatic System Preparation
- Comprehensive Prerequisite Checks
- Interactive User Creation
- Passive Mode Configuration
- Detailed Logging
- Configuration Backup

## Prerequisites

### Supported Systems
- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS

### System Requirements
- Minimum 500MB Free Disk Space
- Root/Sudo Access
- Active Internet Connection

## Installation

### 1. Download the Script
```bash
wget https://github.com/aamirxs/Ftp-setup/install.sh
```

### 2. Make Executable
```bash
chmod +x advanced_ftp_install.sh
```

### 3. Run Installation
```bash
sudo ./advanced_ftp_install.sh
```

## Configuration Details

### Installed Components
- vsftpd (FTP Server)
- Fail2Ban (Intrusion Prevention)
- UFW Firewall
- SSL/TLS Support

### Default Configuration
- Disabled Anonymous Access
- SSL/TLS Encryption
- Strict User Chroot
- Logging Enabled
- Connection Limits

## Security Highlights

### 🔐 Authentication
- Mandatory Local User Authentication
- Strong Password Policies
- User Access Control List

### 🛡️ Network Protection
- Firewall Rules
- IP Connection Throttling
- Fail2Ban Dynamic Blocking

## Logging

### Log Locations
- Console Output: Real-time Installation Feedback
- Log File: `/var/log/ftp_install.log`
- Backup Configurations: `/var/backups/ftp-server/`

## Customization

### Modify Configuration
Edit the script directly to customize:
- SSL Certificate Details
- Connection Limits
- Firewall Rules
- User Creation Process

## Troubleshooting

### Common Issues
- Ensure Sufficient Disk Space
- Verify Root Permissions
- Check System Compatibility
- Review Log Files for Detailed Errors

## Post-Installation

### Recommended Steps
1. Review `/etc/vsftpd.conf`
2. Test FTP Connection
3. Configure Additional Users
4. Monitor Logs Regularly

## Disclaimer
- Use in Controlled Environments
- Review Security Settings
- Keep System Updated

## Contributing

# Created by Aamir
