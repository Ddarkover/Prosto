#!/bin/bash

# Установка имени пользователя
USERNAME="dark"

# Генерация случайного пароля без символов '='
PASSWORD=$(openssl rand -base64 16 | tr -d '=')

# Создание нового пользователя с заданным именем и случайным паролем, добавление его в группу sudo
sudo adduser --gecos "" --disabled-password "$USERNAME"
echo "$USERNAME:$PASSWORD" | sudo chpasswd
sudo usermod -aG sudo "$USERNAME"

# Вывод сгенерированного пароля для пользователя
echo "Сгенерированный пароль для пользователя $USERNAME: $PASSWORD"

# Поиск группы root с помощью getent
grep '^sudo:' /etc/group | cut -d: -f4 | tr ',' '\n'
