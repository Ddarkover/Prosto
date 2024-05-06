#!/bin/bash

# Создание нового пользователя dark
sudo adduser --gecos "" dark <<EOF
HRz3q]btP6hb.pxdo3F!9gj+c
HRz3q]btP6hb.pxdo3F!9gj+c
EOF

# Добавление пользователя в группу sudo
sudo usermod -aG sudo dark

# Поиск всех групп, начинающихся с "sudo" в файле /etc/group
grep -i '^sudo' /etc/group
