#!/bin/bash
# Скрипт для генерации нагрузки с использованием curl

URL="http://localhost"  # URL вашего сервера
REQUEST_COUNT=150  # Количество запросов

for ((i=1;i<=REQUEST_COUNT;i++)); do
  curl -s -o /dev/null $URL &
done

wait
echo "Отправлено $REQUEST_COUNT запросов на $URL"

