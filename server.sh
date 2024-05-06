#!/bin/bash

# Жёлтый цвет
YELLOW='\e[93m'
# Сброс цвета
RESET='\e[0m'

# Обновление ПО
echo -e "${YELLOW}Updating system packages...${RESET}"
apt update && apt upgrade -y

# Установка UFW
setup_ufw() {

# Установка UFW
echo -e "${YELLOW}Installing UFW...${RESET}"
apt install ufw -y

# Включение UFW
echo -e "${YELLOW}Enabling UFW...${RESET}"
echo "y" | sudo ufw enable
}
setup_ufw

# Установка nano
echo -e "${YELLOW}Installing nano...${RESET}"
apt install nano -y

# Защита SSH
setup_ssh_and_fail2ban() {

# Генерация случайного порта для SSH
RANDOM_SSH_PORT=$((10000 + RANDOM % 55536))
    
# Конфигурация SSH
echo -e "${YELLOW}Configuring SSH...${RESET}"
sudo sed -i "s/#Port 22/Port $RANDOM_SSH_PORT/" /etc/ssh/sshd_config
sudo ufw allow $RANDOM_SSH_PORT
sudo systemctl restart sshd
    
# Установка и настройка fail2ban
echo -e "${YELLOW}Installing and configuring fail2ban...${RESET}"
apt install fail2ban -y
touch /etc/fail2ban/jail.local
cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 217.118.91.0/24

[sshd]
enabled = true
filter = sshd
action = iptables-allports[name=SSH, port=$RANDOM_SSH_PORT, protocol=tcp]
logpath = /var/log/auth.log
findtime = 3600
maxretry = 2
bantime = 2592000
EOF
sudo systemctl restart fail2ban
}
setup_ssh_and_fail2ban

# Установка панели 3X-UI
install_3x_ui() {
    # Генерация случайных цифр
    RANDOM_NUMBERS=$(shuf -i 1000-9999 -n 1)

    # Генерация случайного порта для 3X-UI (не совпадающего с портом SSH)
    while :
    do
        RANDOM_PORT=$((10000 + RANDOM % 55536))
        if [ "$RANDOM_PORT" != "$RANDOM_SSH_PORT" ]; then
            break
        fi
    done

    # Формирование имени пользователя
    USERNAME="prosto$RANDOM_NUMBERS"

    # Генерация случайного пароля длиной 10 символов и удаление символов '='
    PASSWORD=$(openssl rand -base64 10 | tr -d '=')

    # Разрешение порта 3X-UI
    echo -e "${YELLOW}Allowing port $RANDOM_PORT for 3X-UI...${RESET}"
    sudo ufw allow $RANDOM_PORT

    # Отключение двухстороннего пинга
    echo -e "${YELLOW}Disabling ping...${RESET}"
    sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

    # Запуск скрипта установки 3X-UI с передачей сгенерированных данных
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) < <(echo -e "y\n$USERNAME\n$PASSWORD\n$RANDOM_PORT")
}
# Функция для запроса продолжения
continue_x-ui() {
    read -p "Do you want to continue with installing 3X-UI panel? [y/n]: " choice
    if [ "$choice" = "y" ]; then
        install_3x_ui
    else
        echo -e "${YELLOW}Skipping 3X-UI panel installation.${RESET}"
    fi
}
continue_x-ui

print_info() {
echo -e "${YELLOW}SSH Port:${RESET} $RANDOM_SSH_PORT"
echo -e "${YELLOW}Username:${RESET} $USERNAME"
echo -e "${YELLOW}Password:${RESET} $PASSWORD"
echo -e "${YELLOW}3X-UI Port:${RESET} $RANDOM_PORT"
}
print_info

# Функция для запроса продолжения
continue_end() {
    read -p "Do you want to continue with system update and cleanup? [y/n]: " choice
    if [ "$choice" = "y" ]; then
        # Обновление и очистка
        echo -e "${YELLOW}Updating system packages and cleaning up...${RESET}"
        apt update && apt upgrade -y && apt autoclean -y && apt clean -y && apt autoremove -y
    else
        echo -e "${YELLOW}Exiting without system update and cleanup.${RESET}"
    fi
}
continue_end
