#!/bin/bash

# Директория для мониторинга
DIRECTORY="/home/danil/Downloads"

# Файл для хранения предыдущих хэшей
HASH_FILE="file_hashes2.md5"

# Функция для генерации хэшей текущих файлов
generate_hashes() {
    find "$DIRECTORY" -type f -exec md5sum {} \; > current_hashes.md5
}

# Если нет файла с предыдущими хэшами, создаём его
if [[ ! -f $HASH_FILE ]]; then
    echo "Файл с хэшами не найден, создаём новый..."
    generate_hashes
    mv current_hashes.md5 $HASH_FILE
    echo "Инициализация завершена."
    exit 0
fi

# Генерируем текущие хэши
generate_hashes

# Сравниваем текущие хэши с предыдущими
echo "Сравнение изменений файлов..."
diff_output=$(diff $HASH_FILE current_hashes.md5)

if [[ -z "$diff_output" ]]; then
    echo "Файлы не изменялись."
else
    echo "Найдены изменения в файлах:"
    echo "$diff_output"

    # Проверка изменений в содержимом файлов
    echo "Проверяем изменения содержимого файлов..."
    while read -r line; do
        file_path=$(echo "$line" | cut -d' ' -f3)
        if [[ -f "$file_path" ]]; then
            if [[ -f "${file_path}.bak" ]]; then
                diff "${file_path}.bak" "$file_path"
            fi
            cp "$file_path" "${file_path}.bak"
        fi
    done < current_hashes.md5
fi

# Обновляем файл с предыдущими хэшами
mv current_hashes.md5 $HASH_FILE

