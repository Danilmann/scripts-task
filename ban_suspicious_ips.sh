#!/bin/bash

# Файл логов (например, для nginx)
LOG_FILE="/var/log/nginx/access.log"

# Порог частоты запросов (например, 100 запросов)
THRESHOLD=100

# Время анализа в секундах (например, последние 60 секунд)
TIME_PERIOD=60

# Временной интервал, за который будут анализироваться логи (в формате '%d/%b/%Y:%H:%M:%S')
TIME=$(date --date="$TIME_PERIOD seconds ago" +%d/%b/%Y:%H:%M:%S)

# Функция для блокировки IP через iptables/ip6tables
ban_ip() {
    local ip=$1

    # Проверяем, является ли IP-адрес IPv6
    if [[ "$ip" =~ : ]]; then
        echo "Блокировка IPv6-адреса: $ip"
        sudo ip6tables -A INPUT -s $ip -j DROP
    else
        echo "Блокировка IPv4-адреса: $ip"
        sudo iptables -A INPUT -s $ip -j DROP
    fi
}

# Анализируем логи, находим IP, которые сделали больше $THRESHOLD запросов за последние $TIME_PERIOD секунд
suspicious_ips=$(awk -v threshold=$THRESHOLD -v time="$TIME" '
    $4 > "[" time { ip_count[$1]++ }
    END {
        for (ip in ip_count) {
            if (ip_count[ip] > threshold) {
                print ip
            }
        }
    }
' $LOG_FILE)

# Проходим по всем подозрительным IP и блокируем их
for ip in $suspicious_ips; do
    # Проверяем, заблокирован ли уже IP
    if ! sudo iptables -L INPUT -v -n | grep -q "$ip" && ! sudo ip6tables -L INPUT -v -n | grep -q "$ip"; then
        ban_ip "$ip"
    else
        echo "IP $ip уже заблокирован."
    fi
done

