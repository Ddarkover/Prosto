#!/bin/bash

# Жёлтый цвет
YELLOW='\e[93m'
# Сброс цвета
RESET='\e[0m'

# Генерация случайного порта от 10000 до 65535
RANDOM_PORT=$((10000 + RANDOM % 55536))

# Обновление ПО
echo -e "${YELLOW}Updating system packages...${RESET}"
apt update && apt upgrade -y

# Установка UFW
echo -e "${YELLOW}Installing UFW...${RESET}"
apt install ufw -y

# Включение UFW
echo -e "${YELLOW}Enabling UFW...${RESET}"
echo "y" | sudo ufw enable

# Установка nano
echo -e "${YELLOW}Installing nano...${RESET}"
apt install nano -y

# SSH
echo -e "${YELLOW}Configuring SSH...${RESET}"
sudo sed -i "s/#Port 22/Port $RANDOM_PORT/" /etc/ssh/sshd_config
sudo ufw allow $RANDOM_PORT
sudo systemctl restart sshd

# fail2ban
echo -e "${YELLOW}Installing and configuring fail2ban...${RESET}"
apt install fail2ban -y
touch /etc/fail2ban/jail.local
cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 217.118.91.0/24

[sshd]
enabled = true
filter = sshd
action = iptables-allports[name=SSH, port=$RANDOM_PORT, protocol=tcp]
logpath = /var/log/auth.log
findtime = 3600
maxretry = 2
bantime = 2592000
EOF
sudo systemctl restart fail2ban

# Отключение двухстороннего пинга
echo -e "${YELLOW}Disabling ping...${RESET}"
sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

# Разрешение порта 4500
echo -e "${YELLOW}Allowing port 4500...${RESET}"
sudo ufw allow 4500
sudo ufw reload

# Установка панели 3X-UI
echo -e "${YELLOW}Installing 3X-UI panel...${RESET}"

# Генерация случайных цифр
RANDOM_NUMBERS=$(shuf -i 1000-9999 -n 1)

# Формирование имени пользователя
USERNAME="prosto$RANDOM_NUMBERS"

# Генерация случайного пароля длиной 10 символов и удаление символов '='
PASSWORD=$(openssl rand -base64 10 | tr -d '=')

# Порт для панели 3X-UI (постоянное значение)
PORT=4500

bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) < <(echo -e "y\n$USERNAME\n$PASSWORD\n$PORT")

# Вывод инфы
echo -e "${YELLOW}SSH Port:${RESET} $RANDOM_PORT"
echo -e "${YELLOW}Username:${RESET} $USERNAME"
echo -e "${YELLOW}Password:${RESET} $PASSWORD"
echo -e "${YELLOW}3X-UI Port:${RESET} $PORT"

# Запрос на продолжение
read -p "Do you want to continue with system update and cleanup? [y/n]: " choice
if [ "$choice" = "y" ]; then
    # Обновление и очистка
    echo -e "${YELLOW}Updating system packages and cleaning up...${RESET}"
    apt update && apt upgrade -y && apt autoclean -y && apt clean -y && apt autoremove -y
else
    echo -e "${YELLOW}Exiting without system update and cleanup.${RESET}"
fi
