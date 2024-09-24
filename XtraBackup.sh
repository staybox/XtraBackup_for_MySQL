#!/bin/bash

# Настройки
BACKUP_DIR="/path/to/backup"  # Укажите путь к каталогу для резервных копий
MYSQL_USER="your_user"          # Укажите имя пользователя MySQL
MYSQL_PASSWORD="your_password"  # Укажите пароль пользователя MySQL
FULL_BACKUP_FLAG="/tmp/full_backup_done"  # Файл для отслеживания полного бэкапа

# Функция для выполнения полного бэкапа
perform_full_backup() {
    echo "Выполняется полный бэкап..."
    xtrabackup --backup --target-dir="$BACKUP_DIR/full_backup_$(date +%Y%m%d_%H%M%S)" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --parallel=4
    touch "$FULL_BACKUP_FLAG"
}

# Функция для выполнения инкрементального бэкапа
perform_incremental_backup() {
    echo "Выполняется инкрементальный бэкап..."
    if [ ! -f "$FULL_BACKUP_FLAG" ]; then
        echo "Ошибка: Не выполнен полный бэкап. Сначала выполните полный бэкап."
        exit 1
    fi

    LAST_BACKUP_DIR=$(ls -td "$BACKUP_DIR"/full_backup_* | head -1)
    xtrabackup --backup --target-dir="$BACKUP_DIR/incremental_backup_$(date +%Y%m%d_%H%M%S)" --incremental-basedir="$LAST_BACKUP_DIR" --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --parallel=4
}

# Основная логика
if [ "$1" == "full" ]; then
    perform_full_backup
elif [ "$1" == "incremental" ]; then
    perform_incremental_backup
else
    echo "Использование: $0 {full|incremental}"
    exit 1
fi

