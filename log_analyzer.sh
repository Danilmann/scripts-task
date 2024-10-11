#!/bin/bash

# Путь к лог-файлу
LOG_FILE="/var/log/nginx/access.log"

# Получаем текущее количество уникальных записей (например, по IP-адресам)
# Здесь можно выбрать нужный параметр, который вы хотите считать уникальным
# Например, уникальные IP-адреса:
UNIQUE_COUNT=$(grep -oP '(\d{1,3}\.){3}\d{1,3}' "$LOG_FILE" | sort | uniq | wc -l)

# Подготавливаем письмо
EMAIL="343416686790hg@gmail.com"
SUBJECT="Уникальные записи в nginx/access.log"
MESSAGE="На $(date), количество уникальных записей в $LOG_FILE: $UNIQUE_COUNT"

# Отправляем письмо
echo "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL"

