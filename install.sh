#!/bin/bash

# Advanced FTP Server Automated Installation Script
# Supports Ubuntu 22.04 and 24.04
# Comprehensive Installation and Hardening

# Logging and Configuration
LOG_FILE="/var/log/ftp_install.log"
CONFIG_DIR="/etc/ftp-server"
BACKUP_DIR="/var/backups/ftp-server"

# Sophisticated Logging Function
log() {
    local log_level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Console output with color
    case "$log_level" in
        "INFO")
            echo -e "\e[34m[INFO]\e[0m $message"
            ;;
        "SUCCESS")
            echo -e "\e[32m[SUCCESS]\e[0m $message"
            ;;
        "WARNING")
            echo -e "\e[33m[WARNING]\e[0m $message"
            ;;
        "ERROR")
            echo -e "\e[31m[ERROR]\e[0m $message"
            ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$log_level] $message" >> "$LOG_FILE"
}

# Comprehensive Prerequisite Checks
prerequisites_check() {
    log "INFO" "Performing system prerequisite checks..."

    # Check root privileges
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root. Use sudo."
        exit 1
    fi

    # Check Ubuntu version
    source /etc/os-release
    if [[ "$ID" != "ubuntu" || ("$VERSION_ID" != "22.04" && "$VERSION_ID" != "24.04") ]]; then
        log "ERROR" "Unsupported Ubuntu version. Supports 22.04 and 24.04 only."
        exit 1
    fi

    # Check available disk space
    local required_space=500  # MB
    local available_space=$(df -m / | awk 'NR==2 {print $4}')
    if (( available_space < required_space )); then
        log "ERROR" "Insufficient disk space. Requires at least ${required_space}MB."
        exit 1
    fi

    log "SUCCESS" "All prerequisite checks passed"
}

# Advanced System Preparation
system_preparation() {
    log "INFO" "Preparing system for FTP server installation..."

    # Create necessary directories
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"

    # Update package lists and upgrade
    apt-get update -q
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q
    
    # Install essential utilities
    apt-get install -y software-properties-common curl wget net-tools

    log "SUCCESS" "System preparation completed"
}

# Advanced FTP Server Installation
install_ftp_server() {
    log "INFO" "Installing advanced FTP server (vsftpd)..."

    # Install vsftpd with additional security packages
    apt-get install -y vsftpd fail2ban libpam-pwquality

    # Configure strong password policy
    sed -i 's/^password.*requisite.*/password    requisite     pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

    log "SUCCESS" "FTP server and security packages installed"
}

# Generate SSL/TLS Certificate
generate_ssl_certificate() {
    log "INFO" "Generating SSL/TLS certificate for secure FTP..."

    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CONFIG_DIR/vsftpd.key" \
        -out "$CONFIG_DIR/vsftpd.crt" \
        -subj "/C=US/ST=ServerSecure/L=SecureCity/O=FTPOrg/CN=localhost"

    chmod 600 "$CONFIG_DIR/vsftpd.key"
    
    log "SUCCESS" "SSL/TLS certificate generated"
}

# Advanced vsftpd Configuration
configure_vsftpd() {
    log "INFO" "Configuring vsftpd with enhanced security..."

    # Backup original configuration
    cp /etc/vsftpd.conf "$BACKUP_DIR/vsftpd.conf.$(date +%Y%m%d_%H%M%S)"

    # Advanced configuration template
    cat > /etc/vsftpd.conf << EOL
# Advanced vsftpd Configuration

# Basic Settings
listen=YES
listen_ipv6=NO

# User Access Control
anonymous_enable=NO
local_enable=YES
write_enable=YES

# Security Enhancements
local_umask=077
disable_challtxt=YES
one_process_model=YES

# Chroot Isolation
chroot_local_user=YES
allow_writeable_chroot=NO
secure_chroot_dir=/var/run/vsftpd/empty

# SSL/TLS Configuration
ssl_enable=YES
ssl_tlsv1_2=YES
ssl_tlsv1_3=YES
ssl_ciphers=HIGH:!aNULL:!MD5
rsa_cert_file=$CONFIG_DIR/vsftpd.crt
rsa_private_key_file=$CONFIG_DIR/vsftpd.key

# Connection Limits
max_clients=50
max_per_ip=3

# Logging
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES

# Performance
idle_session_timeout=300
data_connection_timeout=120

# PAM Authentication
pam_service_name=vsftpd

# User Access Control
userlist_enable=YES
userlist_file=$CONFIG_DIR/allowed_users
userlist_deny=NO
EOL

    # Create empty allowed users file
    touch "$CONFIG_DIR/allowed_users"

    log "SUCCESS" "vsftpd configured with advanced security settings"
}

# Fail2Ban Configuration
configure_fail2ban() {
    log "INFO" "Configuring Fail2Ban for FTP protection..."

    cat > /etc/fail2ban/jail.local << EOL
[vsftpd]
enabled = true
port = ftp
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3
bantime = 3600
EOL

    systemctl restart fail2ban
    log "SUCCESS" "Fail2Ban configured to protect FTP server"
}

# Firewall Configuration
configure_firewall() {
    log "INFO" "Configuring firewall rules..."

    # Install UFW if not present
    apt-get install -y ufw

    # Allow FTP and FTPS ports
    ufw allow 20/tcp  # FTP data
    ufw allow 21/tcp  # FTP control
    ufw allow 990/tcp # FTPS
    ufw allow 40000:50000/tcp  # Passive mode ports

    # Enable firewall
    yes | ufw enable

    log "SUCCESS" "Firewall configured for FTP server"
}

# Create FTP User
create_ftp_user() {
    read -p "Enter FTP username: " ftpuser
    read -sp "Enter FTP user password: " ftppassword
    echo

    # Advanced user creation with home directory
    useradd -m -s /bin/false "$ftpuser"
    echo "$ftpuser:$ftppassword" | chpasswd
    
    # Add to allowed users
    echo "$ftpuser" >> "$CONFIG_DIR/allowed_users"

    # Set strict home directory permissions
    chmod 555 "/home/$ftpuser"

    log "SUCCESS" "FTP user $ftpuser created with restricted shell"
}

# Restart Services
restart_services() {
    log "INFO" "Restarting services..."
    systemctl restart vsftpd
    systemctl enable vsftpd
    log "SUCCESS" "FTP server services restarted"
}

# Main Execution
main() {
    clear
    echo "Advanced Ubuntu FTP Server Installer"
    echo "===================================="

    prerequisites_check
    system_preparation
    install_ftp_server
    generate_ssl_certificate
    configure_vsftpd
    configure_fail2ban
    configure_firewall
    create_ftp_user
    restart_services

    log "SUCCESS" "Advanced FTP Server Installation Complete!"
    echo "FTP Server is now secure and ready to use."
    echo "Log file: $LOG_FILE"
}

# Execute main function
main

exit 0
