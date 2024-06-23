#!/bin/bash

# Жёлтый цвет
YELLOW='\e[93m'
# Сброс цвета
RESET='\e[0m'

# Вывод сообщений с цветом
echo_yellow() {
    echo -e "${YELLOW}$1${RESET}"
}

# Обновление ПО
echo_yellow "Updating system packages..."
apt update && apt upgrade -y

# Установка UFW
echo_yellow "Installing and enabling UFW..."
apt install ufw -y
echo "y" | ufw enable

# Установка nano
echo_yellow "Installing nano..."
apt install nano -y

# Изменения порта SSH и установка fail2ban и его настройка
setup_ssh_and_fail2ban() {
    RANDOM_SSH_PORT=$((10000 + RANDOM % 55536))
    
    echo_yellow "Configuring SSH..."
    sed -i "s/#Port 22/Port $RANDOM_SSH_PORT/" /etc/ssh/sshd_config
    ufw allow "$RANDOM_SSH_PORT"
    systemctl restart sshd
    
    echo_yellow "Installing and configuring fail2ban..."
    apt install fail2ban -y
    cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
filter = sshd
action = iptables-allports[name=SSH, port=$RANDOM_SSH_PORT, protocol=tcp]
logpath = /var/log/auth.log
findtime = 24h
maxretry = 2
bantime = -1
EOF
    systemctl restart fail2ban
}
setup_ssh_and_fail2ban

# Установка панели 3X-UI
install_3x_ui() {
    echo_yellow "Allowing port 2053 for 3X-UI..."
    ufw allow 2053

    echo_yellow "Disabling ping..."
    sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) <<< "n"
}

# Запрос продолжения установки 3X-UI панели
read -rp "Do you want to continue with installing 3X-UI panel? [y/n]: " choice
if [ "$choice" = "y" ]; then
    install_3x_ui
else
    echo_yellow "Skipping 3X-UI panel installation."
fi

# Вывод информации
echo_yellow "SSH Port: $RANDOM_SSH_PORT"

# Запрос продолжения обновления и очистки системы
read -rp "Do you want to continue with system update and cleanup? [y/n]: " choice
if [ "$choice" = "y" ]; then
    echo_yellow "Updating system packages and cleaning up..."
    apt update && apt upgrade -y && apt autoclean -y && apt clean -y && apt autoremove -y
else
    echo_yellow "Exiting without system update and cleanup."
fi
