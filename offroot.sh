#!/bin/bash

# Изменяем настройки в файле sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Перезапускаем службу SSH
systemctl restart sshd

echo "Настройки SSH обновлены. Теперь PermitRootLogin установлен в 'no'."
